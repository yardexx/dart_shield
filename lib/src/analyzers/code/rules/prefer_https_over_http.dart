import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferHttpsOverHttp extends AnalysisRule {
  PreferHttpsOverHttp()
    : super(
        name: 'prefer_https_over_http',
        description: 'Prefer HTTPS over HTTP for URLs in the code.',
      );

  static const LintCode code = LintCode(
    'prefer_https_over_http',
    'Prefer HTTPS over HTTP for URLs in the code.',
    correctionMessage:
        'Consider using HTTPS instead of HTTP for better '
        'security.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _PreferHttpsOverHttpVisitor(rule: this, context: context);
    registry
      ..addSimpleStringLiteral(this, visitor)
      ..addInstanceCreationExpression(this, visitor);
  }
}

class _PreferHttpsOverHttpVisitor extends SimpleAstVisitor<void> {

  _PreferHttpsOverHttpVisitor({required this.rule, required this.context});
  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    // Check if the string literal starts with "http:" (not "https:")
    final value = node.value;
    if (value.startsWith('http:') && !value.startsWith('https:')) {
      rule.reportAtNode(node);
    }
    super.visitSimpleStringLiteral(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Check for Uri.http() constructor calls
    if (node.beginToken.lexeme != 'Uri') {
      return;
    }

    if (_isUnsafeUriInstance(node)) {
      rule.reportAtNode(node);
    }

    super.visitInstanceCreationExpression(node);
  }

  bool _isUnsafeUriInstance(InstanceCreationExpression node) {
    final token = node.beginToken;
    final baseConstructor = token.lexeme;
    final constructorName = node.constructorName.name?.name;
    final constructorToken = token.next?.next?.lexeme;

    // Check if it's Uri.http() (not Uri.https())
    return baseConstructor == 'Uri' &&
        (constructorName == 'http' || constructorToken == 'http');
  }
}
