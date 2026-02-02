import 'dart:io';

import 'package:dart_shield/src/baseline/baseline_manager.dart';
import 'package:dart_shield/src/cli/commands/shield_command.dart';
import 'package:dart_shield/src/configuration/shield_config.dart';
import 'package:dart_shield/src/core/analyzer_engine.dart';
import 'package:dart_shield/src/core/analyzer_factory.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:mason_logger/mason_logger.dart';

/// Default baseline file path following Dart conventions.
const defaultBaselinePath = '.dart_tool/dart_shield/baseline.yaml';

/// Command to create or update a baseline file for existing issues.
///
/// This allows teams to adopt dart_shield in existing projects without
/// being overwhelmed by legacy issues.
class BaselineCommand extends ShieldCommand {
  BaselineCommand({super.logger}) {
    argParser
      ..addOption(
        'output',
        abbr: 'o',
        defaultsTo: defaultBaselinePath,
        help:
            'Output path for the baseline file. '
            'Defaults to $defaultBaselinePath',
      )
      ..addFlag(
        'update',
        abbr: 'u',
        help: 'Update existing baseline with current issues.',
      );
  }

  @override
  String get name => 'baseline';

  @override
  String get description =>
      'Create or update a baseline file for existing issues.';

  @override
  Future<int> run() async {
    final outputPath = argResults['output'] as String;
    final update = argResults['update'] as bool;
    final paths = argResults.rest.isEmpty ? ['.'] : argResults.rest;

    try {
      // Check if baseline exists when not updating
      final checkFile = File(outputPath);
      if (checkFile.existsSync() && !update) {
        logger.err(
          'Baseline file already exists: $outputPath\n'
          'Use --update to merge with existing baseline.',
        );
        return ExitCode.usage.code;
      }

      // Load configuration
      final config = await ShieldConfig.load();

      // Resolve analyzers
      final analyzers = AnalyzerFactory.resolve(
        paths: paths,
        config: config,
        only: [],
        exclude: [],
      );

      if (analyzers.isEmpty) {
        logger.warn('No analyzers selected.');
        return ExitCode.config.code;
      }

      // Run analysis
      logger
        ..info('🛡️  Running analysis to create baseline...')
        ..info('   Analyzing ${paths.join(', ')}');

      final engine = AnalyzerEngine(analyzers);
      final results = await engine.runAll();

      // Extract all issues
      final issues = results
          .whereType<AnalysisSuccess>()
          .expand((r) => r.issues)
          .toList();

      // Ensure parent directory exists
      final baselineFile = File(outputPath);
      final parentDir = baselineFile.parent;
      if (!parentDir.existsSync()) {
        parentDir.createSync(recursive: true);
      }

      // Create baseline
      final manager = BaselineManager(outputPath);
      await manager.createBaseline(issues);

      logger
        ..success('✅ Baseline created: $outputPath')
        ..info('   ${issues.length} issues recorded');

      return ExitCode.success.code;
    } on Object catch (e, stack) {
      logger
        ..err('Failed to create baseline: $e')
        ..detail('$stack');
      return ExitCode.software.code;
    }
  }
}
