// lib/src/security_analyzer/rules/rules_list/flow_based/detect_command_injection.dart
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:dart_shield/src/security_analyzer/extensions.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/flow_analysis_engine.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/data_flow/taint_analysis.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';
import 'package:source_span/source_span.dart';

/// Rule for detecting command injection vulnerabilities
class DetectCommandInjection extends LintRule {
  DetectCommandInjection({required super.excludes})
      : super(
    id: RuleId.detectCommandInjection,
    message: _message,
    severity: Severity.critical,
    status: RuleStatus.experimental,
  );

  static const _message =
      'Potential command injection vulnerability detected.';

  @override
  Iterable<LintIssue> check(ResolvedUnitResult source) {
    final config = _createCommandInjectionConfig();
    final engine = FlowAnalysisEngine();
    final result = engine.analyzeUnit(source);

    final issues = <LintIssue>[];

    for (final vulnerability in result.allVulnerabilities) {
      if (_isCommandSink(vulnerability.sink)) {
        final location = SourceSpanX.fromNode(
          node: vulnerability.location,
          source: source,
        );

        final detailedMessage = _buildCommandInjectionMessage(vulnerability);

        issues.add(LintIssue.withRule(
          rule: this,
          message: detailedMessage,
          location: location,
        ));
      }
    }

    return issues;
  }

  @override
  List<SyntacticEntity> collectErrorNodes(ResolvedUnitResult source) {
    final engine = FlowAnalysisEngine();
    final result = engine.analyzeUnit(source);

    return result.allVulnerabilities
        .where((v) => _isCommandSink(v.sink))
        .map((v) => v.location)
        .toList();
  }

  TaintAnalysisConfig _createCommandInjectionConfig() {
    return TaintAnalysisConfig(
      sources: {
        // HTTP input
        'request.body',
        'request.query',
        'request.params',
        'request.headers',

        // File input
        'File.readAsString',
        'File.readAsLines',
        'stdin.readLineSync',

        // Environment
        'Platform.environment',
        'Platform.executable',

        // Network input
        'Socket.connect',
        'HttpClient.get',
      },
      sinks: {
        // Process execution
        'Process.run',
        'Process.start',
        'Process.runSync',

        // Shell commands
        'shell',
        'exec',
        'system',

        // Platform-specific
        'Platform.isWindows ? "cmd" : "bash"',

        // Dart:io process methods
        'ProcessResult.run',
        'ProcessResult.runSync',
      },
      sanitizers: {
        // Argument validation
        'validate',
        'sanitize',
        'escape',
        'shellescape',

        // Whitelisting
        'isValidCommand',
        'isAllowedPath',

        // Argument arrays (safer than string concatenation)
        'List<String>',
        'ProcessStartInfo.arguments',
      },
      propagators: {
        'toString',
        'join',
        '+',
        'substring',
        'trim',
        'replaceAll',
      },
    );
  }

  bool _isCommandSink(String sink) {
    final commandSinks = {
      'Process.run', 'Process.start', 'Process.runSync',
      'shell', 'exec', 'system',
      'ProcessResult.run', 'ProcessResult.runSync',
    };

    return commandSinks.any((cmdSink) => sink.contains(cmdSink));
  }

  String _buildCommandInjectionMessage(dynamic vulnerability) {
    return 'Command injection vulnerability: User input from "${vulnerability.source}" '
        'reaches command execution "${vulnerability.sink}" without proper validation. '
        'Use argument arrays or proper input validation to prevent command injection attacks.';
  }
}
