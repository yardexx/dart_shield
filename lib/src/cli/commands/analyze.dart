import 'dart:io';

import 'package:dart_shield/src/cli/commands/shield_command.dart';
import 'package:dart_shield/src/security_analyzer/configuration/shield_config.dart';
import 'package:dart_shield/src/security_analyzer/report/report.dart';
import 'package:dart_shield/src/security_analyzer/security_analyzer.dart';
import 'package:dart_shield/src/security_analyzer/workspace.dart';
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
    if (!_isEnvironmentHealthy()) {
      return ExitCode.usage.code;
    }

    final workspace = _createWorkspace();
    final config = _parseShieldConfig(workspace);
    final analysisResult = await _analyze(workspace, config);
    _processReport(analysisResult);
    return ExitCode.success.code;
  }

  bool _isEnvironmentHealthy() {
    final progress = logger.progress('Checking environment');
    if (!validWorkspace) {
      progress.fail('Environment is unhealthy.');
      logger.err('Root/Target directory missing or does not exist.');
      return false;
    }
    progress.complete('Environment is healthy.');
    return true;
  }

  Workspace _createWorkspace() {
    final progress = logger.progress('Creating workspace');

    final workspace = Workspace(
      analyzedPaths: argResults.rest,
      rootFolder: Directory.current.path,
    );

    progress.complete('Workspace created.');
    return workspace;
  }

  ShieldConfig _parseShieldConfig(Workspace workspace) {
    final progress = logger.progress('Parsing shield configuration');
    final config = ShieldConfig.fromFile(workspace.configPath);
    progress.complete('Configuration parsed.');
    return config;
  }

  Future<ProjectReport> _analyze(
    Workspace workspace,
    ShieldConfig config,
  ) async {
    final progress = logger.progress('Analyzing project');
    final report = await _analyzer.analyzeFromCli(workspace, config);
    progress.complete('Project analyzed.');
    return report;
  }

  void _processReport(ProjectReport report) {
    final progress = logger.progress('Processing report');
    final reporter = ConsoleReport();
    final output = reporter.report(report);
    progress.complete('Report processed');
    logger.info(output);
  }
}
