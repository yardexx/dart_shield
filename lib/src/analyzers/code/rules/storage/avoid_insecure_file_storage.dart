import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Detects writing sensitive data to files with sensitive names.
///
/// CWE-922: Insecure Storage of Sensitive Information
class AvoidInsecureFileStorage extends AnalysisRule {
  AvoidInsecureFileStorage()
    : super(
        name: 'avoid_insecure_file_storage',
        description:
            'Avoid storing sensitive data in files with names that '
            'suggest sensitive content.',
      );

  static const LintCode code = LintCode(
    'avoid_insecure_file_storage',
    'Avoid writing sensitive data to files without encryption.',
    correctionMessage:
        'Encrypt sensitive data before writing to files, or use '
        'a secure storage solution.',
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

  static const _sensitiveFilePatterns = [
    'password',
    'passwd',
    'secret',
    'credential',
    'token',
    'key',
    'private',
    'auth',
  ];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Check if this is a File constructor
    final constructorName = node.constructorName.type.element?.name;
    if (constructorName != 'File') return;

    // Check the file path argument for sensitive patterns
    final args = node.argumentList.arguments;
    if (args.isEmpty) return;

    final firstArg = args.first;
    if (firstArg is SimpleStringLiteral) {
      final filePath = firstArg.value.toLowerCase();
      if (_sensitiveFilePatterns.any((p) => filePath.contains(p))) {
        rule.reportAtNode(node);
      }
    }
  }
}
