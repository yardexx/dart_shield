import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_shield/src/cli/cli.dart';
import 'package:mason_logger/mason_logger.dart';

abstract class ShieldCommand extends Command<int> {
  ShieldCommand({Logger? logger}) : _logger = logger;

  @override
  ArgResults get argResults {
    final results = super.argResults;
    if (results == null) {
      throw StateError('Unexpected empty args parse result');
    }

    return results;
  }

  // rootFolderExists && targetsExist && configExists
  bool get validWorkspace => true;

  bool get rootFolderExists {
    final rootPath = argResults[Flags.rootFolder.name] as String;
    return Directory(rootPath).existsSync();
  }

  bool get targetsExist => argResults.rest.isNotEmpty;

  Logger get logger => _logger ??= Logger();

  Logger? _logger;
}
