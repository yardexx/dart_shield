import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Detects bypassing of certificate pinning/validation.
///
/// CWE-295: Improper Certificate Validation
class AvoidCertificatePinningBypass extends AnalysisRule {
  AvoidCertificatePinningBypass()
    : super(
        name: 'avoid_certificate_pinning_bypass',
        description: 'Avoid bypassing SSL certificate validation.',
      );

  static const LintCode code = LintCode(
    'avoid_certificate_pinning_bypass',
    'Avoid bypassing SSL certificate validation.',
    correctionMessage:
        'Implement proper certificate validation instead of '
        'returning true unconditionally.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(rule: this);
    registry.addAssignmentExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor({required this.rule});
  final AnalysisRule rule;

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    // Check for badCertificateCallback assignment
    final leftSide = node.leftHandSide;
    String? propertyName;

    if (leftSide is PropertyAccess) {
      propertyName = leftSide.propertyName.name;
    } else if (leftSide is PrefixedIdentifier) {
      propertyName = leftSide.identifier.name;
    }

    if (propertyName != 'badCertificateCallback') {
      return;
    }

    // Check if the right side is a function that returns true
    final rightSide = node.rightHandSide;
    if (_returnsTrueUnconditionally(rightSide)) {
      rule.reportAtNode(node);
    }
  }

  bool _returnsTrueUnconditionally(Expression expr) {
    if (expr is FunctionExpression) {
      final body = expr.body;
      if (body is ExpressionFunctionBody) {
        final expression = body.expression;
        if (expression is BooleanLiteral && expression.value) {
          return true;
        }
      }
    }
    return false;
  }
}
