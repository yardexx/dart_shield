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
import 'package:dart_shield/src/reporters/sarif_reporter.dart';
import 'package:mason_logger/mason_logger.dart';

/// The main orchestrator for running security analysis on Dart/Flutter projects.
///
/// [ShieldRunner] coordinates the entire analysis pipeline:
/// 1. Configures logging based on the output format
/// 2. Loads project configuration from the configuration file
/// 3. Resolves which analyzers to run based on configuration and CLI flags
/// 4. Executes all selected analyzers via [AnalyzerEngine]
/// 5. Filters results by minimum severity threshold
/// 6. Reports findings using the specified reporter (console, JSON, or SARIF)
/// 7. Determines the appropriate exit code based on results
///
/// Example usage:
/// ```dart
/// final runner = ShieldRunner();
/// final exitCode = await runner.run(
///   ShieldRunConfig(
///     paths: ['lib/'],
///     reporterMode: 'console',
///     minSeverity: Severity.warning,
///   ),
/// );
/// ```
class ShieldRunner {
  /// Creates a new [ShieldRunner] instance.
  ///
  /// If [logger] is not provided, a default [Logger] instance is created.
  /// The logger is used for progress information and error reporting.
  ShieldRunner({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  /// Executes the security analysis pipeline.
  ///
  /// Takes a [runConfig] containing all runtime configuration options including:
  /// - Target paths to analyze
  /// - Reporter mode (console, json, sarif)
  /// - Minimum severity threshold
  /// - Analyzer include/exclude filters
  ///
  /// Returns an exit code indicating the result:
  /// - `0` ([ExitCode.success]) - Analysis completed with no issues
  /// - `64` ([ExitCode.config]) - Configuration error (e.g., no analyzers selected)
  /// - `70` ([ExitCode.software]) - Issues found or analysis failure
  ///
  /// Handles exceptions gracefully:
  /// - [ShieldException] subclasses are logged with appropriate exit codes
  /// - Unexpected errors are logged with stack traces
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

  /// Filters analysis results to include only issues meeting the severity
  /// threshold.
  ///
  /// For each [AnalysisSuccess] result, removes issues with severity below
  /// [minSeverity]. [AnalysisFailure] results pass through unchanged.
  ///
  /// Severity comparison uses index ordering where lower index = higher
  /// severity (e.g., `error` < `warning` < `info`).
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

  /// Returns the list of reporters for the specified output [mode].
  ///
  /// Supported modes:
  /// - `'json'` - Outputs results as JSON for programmatic consumption
  /// - `'sarif'` - Outputs results in SARIF format for CI/CD integration
  /// - `'console'` - Human-readable console output (default)
  ///
  /// Falls back to [ConsoleReporter] for unrecognized modes.
  List<Reporter> _getReporters(String mode) {
    return switch (mode) {
      'json' => [JsonReporter()],
      'sarif' => [SarifReporter()],
      'console' => [ConsoleReporter()],
      _ => [ConsoleReporter()],
    };
  }

  /// Determines the appropriate exit code based on analysis [results].
  ///
  /// Returns:
  /// - [ExitCode.software] (70) if any analyzer failed to complete
  /// - [ExitCode.software] (70) if any security issues were found
  /// - [ExitCode.success] (0) if all analyzers completed with no issues
  ///
  /// This exit code strategy allows CI/CD pipelines to fail builds when
  /// security vulnerabilities are detected.
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
