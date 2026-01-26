import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferSecureRandom extends AnalysisRule {
  PreferSecureRandom()
    : super(
        name: 'prefer_secure_random',
        description:
            'Prefer using SecureRandom for cryptographic purposes instead of '
            'the default Random class.',
      );

  static const LintCode code = LintCode(
    'prefer_secure_random',
    'Using Random for cryptographic purposes is insecure. Consider using '
        'SecureRandom instead.',
    correctionMessage: 'Replace Random with SecureRandom for better security.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _PreferSecureRandomVisitor(rule: this, context: context);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _PreferSecureRandomVisitor extends SimpleAstVisitor<void> {
  _PreferSecureRandomVisitor({required this.rule, required this.context});

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final token = node.beginToken;
    if (token.lexeme != 'Random') {
      return;
    }

    if (_isRandomUnsecure(node)) {
      rule.reportAtNode(node);
    }

    super.visitInstanceCreationExpression(node);
  }

  bool _isRandomUnsecure(InstanceCreationExpression node) {
    final baseConstructor = node.beginToken.lexeme;
    final constructorName = node.constructorName.name?.name;

    return baseConstructor == 'Random' && constructorName != 'secure';
  }
}
