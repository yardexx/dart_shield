import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
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

  bool get validWorkspace => rootFolderExists && targetsExist;

  bool get rootFolderExists {
    return Directory.current.existsSync();
  }

  bool get targetsExist {
    return argResults.rest.length == 1 &&
        Directory(argResults.rest.first).existsSync();
  }

  Logger get logger => _logger ??= Logger();

  Logger? _logger;
}
