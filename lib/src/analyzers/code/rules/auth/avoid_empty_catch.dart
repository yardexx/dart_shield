import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Detects empty catch blocks that silently swallow exceptions.
///
/// Empty catch blocks can hide security issues and make debugging difficult.
class AvoidEmptyCatch extends AnalysisRule {
  AvoidEmptyCatch()
    : super(
        name: 'avoid_empty_catch',
        description:
            'Avoid empty catch blocks that silently swallow exceptions.',
      );

  static const LintCode code = LintCode(
    'avoid_empty_catch',
    'Empty catch block silently swallows exceptions.',
    correctionMessage:
        'Handle the exception, log it, or rethrow it. '
        'Never silently ignore exceptions.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(rule: this);
    registry.addCatchClause(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor({required this.rule});
  final AnalysisRule rule;

  @override
  void visitCatchClause(CatchClause node) {
    final body = node.body;
    final statements = body.statements;

    // Check if the catch block is empty or contains only comments
    if (statements.isEmpty) {
      rule.reportAtNode(node);
      return;
    }

    // Check if all statements are empty statements or just have no effect
    final hasEffectiveStatement = statements.any((stmt) {
      // Empty statement
      if (stmt is EmptyStatement) return false;

      // Expression statement with just a variable reference (no effect)
      if (stmt is ExpressionStatement) {
        final expr = stmt.expression;
        // Check for rethrow, throw, return, method calls, etc.
        if (expr is RethrowExpression) return true;
        if (expr is ThrowExpression) return true;
        if (expr is MethodInvocation) return true;
        if (expr is FunctionExpressionInvocation) return true;
        if (expr is AssignmentExpression) return true;
        // Simple identifier alone has no effect
        if (expr is SimpleIdentifier) return false;
      }

      if (stmt is ReturnStatement) return true;
      if (stmt is IfStatement) return true;
      if (stmt is Block) return true;
      if (stmt is VariableDeclarationStatement) return true;

      return false;
    });

    if (!hasEffectiveStatement) {
      rule.reportAtNode(node);
    }
  }
}
