import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Detects potentially insecure JavaScript channels in WebViews.
///
/// JavaScript bridges can expose sensitive app functionality to web content
/// if not properly validated.
class AvoidWebviewJavascriptBridge extends AnalysisRule {
  AvoidWebviewJavascriptBridge()
    : super(
        name: 'avoid_webview_javascript_bridge',
        description:
            'JavaScript channels may expose sensitive app functionality.',
      );

  static const LintCode code = LintCode(
    'avoid_webview_javascript_bridge',
    'JavaScript channel may expose sensitive app functionality to web content.',
    correctionMessage:
        'Ensure the JavaScript channel validates all incoming messages '
        'and does not expose sensitive operations.',
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

  static const _sensitiveOperations = [
    'token',
    'password',
    'credential',
    'auth',
    'secret',
    'private',
    'key',
  ];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;

    // Check for addJavaScriptChannel or similar
    if (methodName == 'addJavaScriptChannel' ||
        methodName == 'addJavascriptChannel') {
      // Check if the channel name suggests sensitive data handling
      final args = node.argumentList.arguments;
      if (args.isNotEmpty) {
        final firstArg = args.first;
        if (firstArg is SimpleStringLiteral) {
          final channelName = firstArg.value.toLowerCase();
          if (_sensitiveOperations.any((op) => channelName.contains(op))) {
            rule.reportAtNode(node);
          }
        }
      }
    }
  }
}
