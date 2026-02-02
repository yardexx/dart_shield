import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Detects potential deep link parameter handling without validation.
///
/// Deep link parameters from external sources should be validated
/// before being used in sensitive operations.
class AvoidUnvalidatedDeepLink extends AnalysisRule {
  AvoidUnvalidatedDeepLink()
    : super(
        name: 'avoid_unvalidated_deep_link',
        description:
            'Deep link parameters should be validated before use in '
            'sensitive operations.',
      );

  static const LintCode code = LintCode(
    'avoid_unvalidated_deep_link',
    'Deep link parameter used without apparent validation.',
    correctionMessage:
        'Validate deep link parameters before using them in navigation, '
        'database queries, or API calls.',
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

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;

    // Check for getInitialLink or linkStream handlers
    if (methodName == 'getInitialLink' ||
        methodName == 'getInitialUri' ||
        methodName == 'getLatestLink' ||
        methodName == 'getLatestUri') {
      // This is a detection point - warn about potential misuse
      // In real usage, this would integrate with data flow analysis
      rule.reportAtNode(node);
    }
  }
}
