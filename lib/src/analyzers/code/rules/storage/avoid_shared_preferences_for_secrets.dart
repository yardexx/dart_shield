import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Detects storing sensitive data in SharedPreferences.
///
/// CWE-312: Cleartext Storage of Sensitive Information
class AvoidSharedPreferencesForSecrets extends AnalysisRule {
  AvoidSharedPreferencesForSecrets()
    : super(
        name: 'avoid_shared_preferences_for_secrets',
        description:
            'Avoid storing sensitive data in SharedPreferences as it '
            'is not encrypted.',
      );

  static const LintCode code = LintCode(
    'avoid_shared_preferences_for_secrets',
    'Avoid storing sensitive data in SharedPreferences (unencrypted).',
    correctionMessage:
        'Use flutter_secure_storage or similar encrypted '
        'storage for sensitive data.',
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

  static const _sensitiveKeyPatterns = [
    'password',
    'passwd',
    'token',
    'secret',
    'apikey',
    'api_key',
    'credential',
    'privatekey',
    'private_key',
    'auth',
    'accesstoken',
    'access_token',
  ];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;

    // Only check setString, setInt, etc. (write operations)
    if (!methodName.startsWith('set')) {
      return;
    }

    // Check if this is on SharedPreferences type
    final target = node.target;
    if (target == null) return;

    final targetType = target.staticType?.toString() ?? '';
    if (!targetType.contains('SharedPreferences')) {
      return;
    }

    // Check the first argument (key) for sensitive patterns
    final args = node.argumentList.arguments;
    if (args.isEmpty) return;

    final firstArg = args.first;
    if (firstArg is SimpleStringLiteral) {
      final keyValue = firstArg.value.toLowerCase();
      if (_sensitiveKeyPatterns.any((p) => keyValue.contains(p))) {
        rule.reportAtNode(node);
      }
    }
  }
}
