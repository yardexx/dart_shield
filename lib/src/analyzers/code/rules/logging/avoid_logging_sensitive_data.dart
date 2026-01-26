import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Detects logging/printing of sensitive data.
///
/// CWE-532: Insertion of Sensitive Information into Log File
class AvoidLoggingSensitiveData extends AnalysisRule {
  AvoidLoggingSensitiveData()
    : super(
        name: 'avoid_logging_sensitive_data',
        description: 'Avoid logging sensitive data like passwords or tokens.',
      );

  static const LintCode code = LintCode(
    'avoid_logging_sensitive_data',
    'Avoid logging sensitive data like passwords or tokens.',
    correctionMessage:
        'Remove sensitive data from log statements or use '
        'redaction before logging.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(rule: this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor({required this.rule});
  final AnalysisRule rule;

  static const _sensitivePatterns = [
    'password',
    'passwd',
    'token',
    'secret',
    'apikey',
    'api_key',
    'credential',
    'privatekey',
    'private_key',
    'accesstoken',
    'access_token',
    'authtoken',
    'auth_token',
    'auth',
  ];

  static const _loggingFunctions = [
    'print',
    'debugPrint',
    'log',
    'logger',
    'info',
    'debug',
    'warning',
    'error',
    'severe',
  ];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name.toLowerCase();

    // Check if this is a logging function
    if (!_loggingFunctions.any((f) => methodName.contains(f))) {
      return;
    }

    // Check arguments for sensitive variable names
    for (final arg in node.argumentList.arguments) {
      if (arg is SimpleIdentifier) {
        final argName = arg.name.toLowerCase();
        if (_sensitivePatterns.any((p) => argName.contains(p))) {
          rule.reportAtNode(node);
          return;
        }
      }
    }
  }
}
