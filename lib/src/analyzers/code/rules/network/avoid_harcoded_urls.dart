import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidHardcodedUrls extends AnalysisRule {
  AvoidHardcodedUrls()
    : super(
        name: 'avoid_hardcoded_urls',
        description:
            'Avoid using hardcoded URLs in the codebase for better '
            'maintainability and '
            'security.',
      );

  static const LintCode code = LintCode(
    'avoid_hardcoded_urls',
    'Using hardcoded URLs can lead to security and maintainability issues.',
    correctionMessage:
        'Consider using configuration files or environment variables to manage '
        'URLs.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _AvoidHardcodedUrls(rule: this, context: context);
    registry.addSimpleStringLiteral(this, visitor);
  }
}

class _AvoidHardcodedUrls extends SimpleAstVisitor<void> {
  _AvoidHardcodedUrls({required this.rule, required this.context});

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.value.startsWith('http:') || node.value.startsWith('https:')) {
      rule.reportAtNode(node);
    }
    super.visitSimpleStringLiteral(node);
  }
}
