import 'dart:io';

import 'package:dart_shield/src/cli/commands/shield_command.dart';
import 'package:dart_shield/src/security_analyzer/project_workspace.dart';
import 'package:mason_logger/mason_logger.dart';

class InitCommand extends ShieldCommand {

  InitCommand({super.logger}) {
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Force initialization even if already initialized. This will '
          'overwrite existing configuration.',
      negatable: false,
    );
  }

  final _packageName = 'dart_shield';

  @override
  String get description =>
      'Initialize $_packageName with default config in the current directory.';

  @override
  String get name => 'init';

  @override
  Future<int> run() async {
    final progress = logger.progress('Initializing $_packageName');

    final workspace = Workspace(
      analyzedPaths: [],
      rootFolder: Directory.current.path,
    );

    if (workspace.configExists) {
      progress.update('$_packageName is already initialized');
      final force = argResults['force'] as bool;

      if (!force) {
        progress.fail('Initialization failed');
        logger.err('Use -f to overwrite existing configuration');
        return ExitCode.usage.code;
      }

      progress.update('Force allowed - overwriting existing configuration');
    }

    workspace.createDefaultConfig();
    progress.complete('$_packageName initialized');
    return ExitCode.success.code;
  }
}
