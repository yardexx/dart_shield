import 'package:dart_shield/src/configuration/shield_config.dart';
import 'package:dart_shield/src/core/analyzer_engine.dart';
import 'package:dart_shield/src/core/analyzer_factory.dart';
import 'package:dart_shield/src/core/shield_run_config.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:dart_shield/src/reporters/console_reporter.dart';
import 'package:dart_shield/src/reporters/json_reporter.dart';
import 'package:dart_shield/src/reporters/reporter.dart';
import 'package:mason_logger/mason_logger.dart';

class ShieldRunner {
  final Logger _logger;

  ShieldRunner({Logger? logger}) : _logger = logger ?? Logger();

  Future<int> run(ShieldRunConfig runConfig) async {
    // 1. Logger Hygiene
    if (runConfig.reporterMode == 'json') {
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
    final results = await engine.runAll();

    // 5. Reporting
    final reporters = _getReporters(runConfig.reporterMode);
    await Future.wait(reporters.map((r) => r.report(results)));

    // 6. Exit Logic
    return _calculateExitCode(results);
  }

  List<Reporter> _getReporters(String mode) {
    return switch (mode) {
      'json' => [JsonReporter()],
      'both' => [ConsoleReporter(), JsonReporter()],
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
