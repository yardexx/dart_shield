import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Detects insecure WebView settings in Flutter apps.
///
/// WebViews with unrestricted JavaScript mode can be exploited
/// for cross-site scripting (XSS) attacks.
class AvoidInsecureWebviewSettings extends AnalysisRule {
  AvoidInsecureWebviewSettings()
    : super(
        name: 'avoid_insecure_webview_settings',
        description: 'Avoid enabling unrestricted JavaScript mode in WebViews.',
      );

  static const LintCode code = LintCode(
    'avoid_insecure_webview_settings',
    'WebView has unrestricted JavaScript mode enabled.',
    correctionMessage:
        'Consider using JavaScriptMode.disabled or implement '
        'proper content security policies.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(rule: this);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor({required this.rule});
  final AnalysisRule rule;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.element?.name;

    // Check for WebView or WebViewWidget with unsafe settings
    if (typeName == 'WebView' || typeName == 'WebViewWidget') {
      for (final arg in node.argumentList.arguments) {
        if (arg is NamedExpression) {
          final name = arg.name.label.name;
          if (name == 'javascriptMode' || name == 'javaScriptMode') {
            final expr = arg.expression;
            if (expr is PrefixedIdentifier) {
              final value = expr.identifier.name;
              if (value == 'unrestricted') {
                rule.reportAtNode(node);
                return;
              }
            }
          }
        }
      }
    }
  }
}
