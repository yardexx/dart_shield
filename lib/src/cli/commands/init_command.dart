// ignore_for_file: avoid_catches_without_on_clauses
import 'package:dart_shield/src/cli/commands/shield_command.dart';
import 'package:dart_shield/src/configuration/config_manager.dart';
import 'package:mason_logger/mason_logger.dart';

class InitCommand extends ShieldCommand {
  InitCommand({super.logger}) {
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Overwrite existing dart_shield configuration if present.',
      negatable: false,
    );
  }

  @override
  String get description => 'Initialize Dart Shield in the current project.';

  @override
  String get name => 'init';

  @override
  Future<int> run() async {
    final force = argResults['force'] as bool? ?? false;
    final progress = logger.progress('Initializing Shield...');

    try {
      final manager = ConfigManager();

      if (!manager.exists) {
        progress.fail('Initialization failed.');
        logger
          ..err(
            'Could not find analysis_options.yaml in the current directory.',
          )
          ..info(
            'Please run this command from the root of your Dart/Flutter project.',
          );
        return ExitCode.config.code;
      }

      progress.update('Updating analysis_options.yaml...');
      await manager.applyShieldConfig(force: force);

      progress.complete('Shield initialized successfully! 🛡️');
      return ExitCode.success.code;
    } catch (e, s) {
      progress.fail('Initialization failed.');
      logger
        ..err('$e')
        ..detail('$s');
      return ExitCode.software.code;
    }
  }
}
