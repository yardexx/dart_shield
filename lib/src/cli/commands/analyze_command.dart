import 'package:dart_shield/src/cli/commands/shield_command.dart';
import 'package:dart_shield/src/core/analyzer_factory.dart';
import 'package:dart_shield/src/core/shield_run_config.dart';
import 'package:dart_shield/src/core/shield_runner.dart';

class AnalyzeCommand extends ShieldCommand {
  AnalyzeCommand({super.logger}) {
    argParser
      ..addOption(
        'reporter',
        abbr: 'r',
        allowed: ['console', 'json', 'sarif'],
        defaultsTo: 'console',
        help: 'Select the output format.',
      )
      ..addOption(
        'min-severity',
        abbr: 's',
        allowed: ['info', 'low', 'medium', 'high'],
        defaultsTo: 'info',
        help: 'Minimum severity level to report.',
      )
      ..addMultiOption(
        'only',
        allowed: AnalyzerFactory.availableIds,
        help: 'Run only specific analyzers (ignores config file settings).',
      )
      ..addMultiOption(
        'exclude',
        allowed: AnalyzerFactory.availableIds,
        help: 'Exclude specific analyzers.',
      );
  }

  @override
  String get description =>
      'Analyzes path for possible security-related issues.';

  @override
  String get name => 'analyze';

  @override
  Future<int> run() async {
    final severityStr = argResults['min-severity'] as String? ?? 'info';
    final config = ShieldRunConfig(
      paths: argResults.rest.isEmpty ? ['.'] : argResults.rest,
      only: argResults['only'] as List<String>? ?? [],
      exclude: argResults['exclude'] as List<String>? ?? [],
      reporterMode: argResults['reporter'] as String? ?? 'console',
      minSeverity: ShieldRunConfig.parseSeverity(severityStr),
    );

    final runner = ShieldRunner(logger: logger);
    return runner.run(config);
  }
}
