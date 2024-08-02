import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';

class AvoidHardcodedUrls extends LintRule {
  AvoidHardcodedUrls({required super.excludes})
      : super(
          id: RuleId.avoidHardcodedUrls,
          message: _message,
          severity: Severity.warning,
          status: RuleStatus.experimental,
        );

  static const _message =
      'Avoid hardcoding URLs in the code. Use configuration files or '
      'environment variables instead.';

  @override
  List<SyntacticEntity> collectErrorNodes(ResolvedUnitResult source) {
    final visitor = _AvoidHardcodedUrlsVisitor();
    source.unit.accept(visitor);
    return visitor.errorNodes;
  }
}

class _AvoidHardcodedUrlsVisitor extends ErrorNodeCollector {
  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.value.startsWith('http:') || node.value.startsWith('https:')) {
      errorNodes.add(node);
    }
    super.visitSimpleStringLiteral(node);
  }
}
