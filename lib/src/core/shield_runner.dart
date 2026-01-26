import 'package:dart_shield/src/baseline/baseline_manager.dart';
import 'package:dart_shield/src/configuration/shield_config.dart';
import 'package:dart_shield/src/core/analyzer_engine.dart';
import 'package:dart_shield/src/core/analyzer_factory.dart';
import 'package:dart_shield/src/core/shield_run_config.dart';
import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:dart_shield/src/domain/exceptions.dart';
import 'package:dart_shield/src/reporters/console_reporter.dart';
import 'package:dart_shield/src/reporters/json_reporter.dart';
import 'package:dart_shield/src/reporters/reporter.dart';
import 'package:dart_shield/src/reporters/sarif/sarif_reporter.dart';
import 'package:mason_logger/mason_logger.dart';

class ShieldRunner {
  ShieldRunner({Logger? logger}) : _logger = logger ?? Logger();
  final Logger _logger;

  Future<int> run(ShieldRunConfig runConfig) async {
    try {
      // 1. Logger Hygiene
      if (runConfig.reporterMode == 'json' ||
          runConfig.reporterMode == 'sarif') {
        _logger.level = Level.error;
      }

      // 2. Load Configuration
      final fileConfig = await ShieldConfig.load();

      // 3. Resolve Analyzers
      final analyzers = AnalyzerFactory.resolve(
        paths: runConfig.paths,
        config: fileConfig,
        only: runConfig.only,
        exclude: runConfig.exclude,
      );

      if (analyzers.isEmpty) {
        _logger.warn('No analyzers selected.');
        return ExitCode.config.code;
      }

      // 4. Execution
      _logger.info('🛡️  Running ${analyzers.length} analyzers...');
      final engine = AnalyzerEngine(analyzers);
      var results = await engine.runAll();

      // 5. Filter by minimum severity
      results = _filterBySeverity(results, runConfig.minSeverity);

      // 5.5. Filter baselined issues
      if (runConfig.baselinePath != null) {
        results = await _filterBaselined(results, runConfig.baselinePath!);
      }

      // 6. Reporting
      final reporters = _getReporters(runConfig.reporterMode);
      await Future.wait(reporters.map((r) => r.report(results)));

      // 7. Exit Logic
      return _calculateExitCode(results);
    } on ShieldException catch (e) {
      _logger.err(e.toString());
      if (e is ConfigException) return ExitCode.config.code;
      return ExitCode.software.code;
    } on Object catch (e, stack) {
      _logger
        ..err('Unexpected error: $e')
        ..detail('$stack');
      return ExitCode.software.code;
    }
  }

  /// Filters analysis results to only include issues at or above the minimum
  /// severity level.
  List<AnalyzerResult> _filterBySeverity(
    List<AnalyzerResult> results,
    Severity minSeverity,
  ) {
    return results.map((result) {
      if (result is AnalysisSuccess) {
        final filteredIssues = result.issues
            .where((issue) => issue.severity.index <= minSeverity.index)
            .toList();
        return AnalysisSuccess(
          analyzerId: result.analyzerId,
          issues: filteredIssues,
          duration: result.duration,
        );
      }
      return result;
    }).toList();
  }

  /// Filters analysis results to exclude issues that are in the baseline.
  Future<List<AnalyzerResult>> _filterBaselined(
    List<AnalyzerResult> results,
    String baselinePath,
  ) async {
    final manager = BaselineManager(baselinePath);

    final filtered = <AnalyzerResult>[];
    for (final result in results) {
      if (result is AnalysisSuccess) {
        final filteredIssues = await manager.filterBaselined(result.issues);
        filtered.add(
          AnalysisSuccess(
            analyzerId: result.analyzerId,
            issues: filteredIssues,
            duration: result.duration,
          ),
        );
      } else {
        filtered.add(result);
      }
    }
    return filtered;
  }

  List<Reporter> _getReporters(String mode) {
    return switch (mode) {
      'json' => [JsonReporter()],
      'sarif' => [SarifReporter()],
      'console' => [ConsoleReporter()],
      _ => [ConsoleReporter()],
    };
  }

  int _calculateExitCode(List<AnalyzerResult> results) {
    if (results.any((r) => r is AnalysisFailure)) {
      return ExitCode.software.code;
    }
    if (results.any((r) => r is AnalysisSuccess && r.issues.isNotEmpty)) {
      return ExitCode.software.code;
    }
    return ExitCode.success.code;
  }
}
