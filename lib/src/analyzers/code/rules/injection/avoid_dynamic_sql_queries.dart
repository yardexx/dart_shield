import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Detects dynamic SQL queries with string interpolation.
///
/// CWE-89: SQL Injection
class AvoidDynamicSqlQueries extends AnalysisRule {
  AvoidDynamicSqlQueries()
    : super(
        name: 'avoid_dynamic_sql_queries',
        description:
            'Avoid dynamic SQL queries with string interpolation to '
            'prevent SQL injection.',
      );

  static const LintCode code = LintCode(
    'avoid_dynamic_sql_queries',
    'Avoid dynamic SQL queries with string interpolation.',
    correctionMessage:
        'Use parameterized queries or prepared statements '
        'instead of string interpolation.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(rule: this);
    registry.addStringInterpolation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor({required this.rule});
  final AnalysisRule rule;

  static const _sqlKeywords = [
    'SELECT',
    'INSERT',
    'UPDATE',
    'DELETE',
    'DROP',
    'CREATE',
    'ALTER',
    'TRUNCATE',
  ];

  @override
  void visitStringInterpolation(StringInterpolation node) {
    // Get the full string content
    final buffer = StringBuffer();
    for (final element in node.elements) {
      if (element is InterpolationString) {
        buffer.write(element.value);
      } else if (element is InterpolationExpression) {
        buffer.write('\${}'); // Placeholder for interpolation
      }
    }
    final stringValue = buffer.toString().toUpperCase();

    // Check if the string looks like a SQL query
    final hasSqlKeyword = _sqlKeywords.any(
      (keyword) => stringValue.contains(keyword),
    );

    // Check if it has interpolation (not just a static SQL string)
    final hasInterpolation =
        node.elements.any((e) => e is InterpolationExpression);

    if (hasSqlKeyword && hasInterpolation) {
      rule.reportAtNode(node);
    }
  }
}
