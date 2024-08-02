import 'dart:io';

import 'package:dart_shield/src/cli/commands/shield_command.dart';
import 'package:dart_shield/src/security_analyzer/configuration/shield_config.dart';
import 'package:dart_shield/src/security_analyzer/project_workspace.dart';
import 'package:dart_shield/src/security_analyzer/report/reporters/console_report.dart';
import 'package:dart_shield/src/security_analyzer/security_analyzer.dart';
import 'package:mason_logger/mason_logger.dart';

class AnalyzeCommand extends ShieldCommand {
  AnalyzeCommand({super.logger}) : _analyzer = SecurityAnalyzer();

  final SecurityAnalyzer _analyzer;

  @override
  String get description =>
      'Analyzes path for possible security-related issues.';

  @override
  String get name => 'analyze';

  @override
  Future<int> run() async {
    Progress progress;

    progress = logger.progress('Checking environment');
    if (!validWorkspace) {
      return ExitCode.usage.code;
    }
    progress.complete('Environment is healthy');

    progress = logger.progress('Parsing configuration');
    final workspace = Workspace(
      analyzedPaths: argResults.rest,
      rootFolder: Directory.current.path,
    );
    final config = ShieldConfig.fromFile(workspace.configPath);
    progress.complete('Configuration parsed');

    progress = logger.progress('Performing analysis');
    final analysisResult = await _analyzer.analyzeFromCli(workspace, config);
    progress.complete('Analysis complete');

    progress = logger.progress('Preparing report');
    final reporter = ConsoleReport();
    final report = reporter.report(analysisResult);
    progress.complete('Report ready');

    logger.info(report);
    return ExitCode.success.code;
  }
}
