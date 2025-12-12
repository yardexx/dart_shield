import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:dart_shield/src/analyzers/code/rules/secrets/rule_provider.dart';
import 'package:dart_shield/src/analyzers/utils/shannon_entropy.dart';

class AvoidHardcodedSecrets extends AnalysisRule {
  AvoidHardcodedSecrets()
      : super(
          name: 'avoid_hardcoded_secrets',
          description: 'Detects hardcoded secrets, API keys, and tokens.',
        );

  static const LintCode code = LintCode(
    'avoid_hardcoded_secrets',
    'Hardcoded secret detected: {0}',
    correctionMessage:
        'Store secrets in environment variables or a secure vault.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry.addSimpleStringLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    final value = node.value;
    // Ignore short strings to save CPU and reduce noise
    if (value.length < 8) return;

    // Context Analysis (Variable Name, Map Key)
    final contextString = _getContextString(node).toLowerCase();

    final rules = RuleProvider.getRules();

    for (final secretRule in rules) {
      // 1. Keyword Check (Optimization & Context Validation)
      // If the rule has keywords, at least one must exist in value OR context.
      if (secretRule.keywords.isNotEmpty) {
        final valueLower = value.toLowerCase();
        final hasKeywordInValue =
            secretRule.keywords.any(valueLower.contains);
        final hasKeywordInContext =
            secretRule.keywords.any(contextString.contains);

        if (!hasKeywordInValue && !hasKeywordInContext) {
          continue;
        }
      }

      // 2. Regex Check
      if (!secretRule.pattern.hasMatch(value)) continue;

      // 3. Entropy Check
      if (secretRule.minEntropy > 0) {
        final entropy = ShannonEntropy.calculate(value);
        if (entropy < secretRule.minEntropy) continue;
      }

      // 4. Report
      rule.reportAtNode(node, arguments: [secretRule.description]);
      // Stop after first match per string to avoid duplicate noise
      return;
    }
  }

  /// Extracts relevant context strings (variable names, keys) from the AST.
  String _getContextString(SimpleStringLiteral node) {
    final parent = node.parent;

    // Case: const apiKey = "..."
    if (parent is VariableDeclaration) {
      return parent.name.lexeme;
    }

    // Case: var config = { 'apiKey': '...' }
    if (parent is MapLiteralEntry && parent.value == node) {
      final key = parent.key;
      if (key is SimpleStringLiteral) {
        return key.value;
      }
    }

    // Case: apiKey: "..." (Named parameter)
    if (parent is NamedExpression) {
      return parent.name.label.name;
    }

    return '';
  }
}
