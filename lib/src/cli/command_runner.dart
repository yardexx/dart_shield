import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:dart_shield/src/cli/commands/commands.dart';
import 'package:mason_logger/mason_logger.dart';

const executableName = 'dart_shield';
const packageName = 'dart_shield';
const description = '🔎 $packageName - security scout for Dart projects 🔎';

class ShieldCommandRunner extends CompletionCommandRunner<int> {
  ShieldCommandRunner({Logger? logger})
      : _logger = logger ?? Logger(),
        super(executableName, description) {
    // Add root options and flags
    argParser.addFlags();

    // Add sub commands
    addCommand(AnalyzeCommand(logger: _logger));
    addCommand(InitCommand(logger: _logger));
  }

  @override
  void printUsage() => _logger.info(usage);

  final Logger _logger;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final topLevelResults = parse(args);
      if (topLevelResults['verbose'] == true) {
        _logger.level = Level.verbose;
      }
      return await runCommand(topLevelResults) ?? ExitCode.success.code;
    } on FormatException catch (e, stackTrace) {
      // On format errors, show the commands error message, root usage and
      // exit with an error code
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      // On usage errors, show the commands usage message and
      // exit with an error code
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    // Fast track completion command
    if (topLevelResults.command?.name == 'completion') {
      await super.runCommand(topLevelResults);
      return ExitCode.success.code;
    }

    // Verbose logs
    _logger
      ..detail('Argument information:')
      ..detail('  Top level options:');
    for (final option in topLevelResults.options) {
      if (topLevelResults.wasParsed(option)) {
        _logger.detail('  - $option: ${topLevelResults[option]}');
      }
    }
    if (topLevelResults.command != null) {
      final commandResult = topLevelResults.command!;
      _logger
        ..detail('  Command: ${commandResult.name}')
        ..detail('    Command options:');
      for (final option in commandResult.options) {
        if (commandResult.wasParsed(option)) {
          _logger.detail('    - $option: ${commandResult[option]}');
        }
      }
    }

    final code = super.runCommand(topLevelResults);
    return code;
  }
}

extension on ArgParser {
  void addFlags() {
    addFlag(
      'verbose',
      help: 'Noisy logging, including all shell commands executed.',
    );
  }
}
