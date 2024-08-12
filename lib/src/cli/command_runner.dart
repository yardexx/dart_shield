import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:dart_shield/src/cli/commands/commands.dart';
import 'package:dart_shield/src/security_analyzer/exceptions/exceptions.dart';
import 'package:mason_logger/mason_logger.dart';

const executableName = 'dart_shield';
const packageName = 'dart_shield';
const description = '🔎 $packageName - security scout for Dart projects 🔎';

class ShieldCommandRunner extends CompletionCommandRunner<int> {
  ShieldCommandRunner({Logger? logger})
      : _logger = logger ?? Logger(),
        super(executableName, description) {

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
    } on InvalidConfigurationException catch (e) {
      // On invalid configuration errors, show the error message and
      // exit with an error code
      _logger.err(e.message);
      return ExitCode.config.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    // Fast track completion command
    if (topLevelResults.command?.name == 'completion') {
      await super.runCommand(topLevelResults);
      return ExitCode.success.code;
    }

    final code = super.runCommand(topLevelResults);
    return code;
  }
}
