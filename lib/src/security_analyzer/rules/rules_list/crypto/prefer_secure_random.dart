import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:dart_shield/src/security_analyzer/extensions.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/error_node_collector.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/lint_rule.dart';

class PreferSecureRandom extends LintRule {
  PreferSecureRandom({required super.excludes})
      : super(
          id: RuleId.preferSecureRandom,
          message: _message,
          severity: Severity.info,
          status: RuleStatus.experimental,
        );

  static const _message =
      'Random() is not cryptographically safe. Use Random.secure() for '
      'security-sensitive use cases.';

  @override
  List<SyntacticEntity> collectErrorNodes(ResolvedUnitResult source) {
    final visitor = _PreferSecureRandomVisitor();
    source.unit.accept(visitor);
    return visitor.errorNodes;
  }
}

class _PreferSecureRandomVisitor extends ErrorNodeCollector {
  final _packageName = 'dart:math';

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!node.belongsToPackage(_packageName)) {
      return super.visitInstanceCreationExpression(node);
    }

    final token = node.beginToken;
    if (token.lexeme != 'Random') {
      return;
    }

    if (_isRandomUnsecure(node)) {
      errorNodes.add(node);
    }

    super.visitInstanceCreationExpression(node);
  }

  bool _isRandomUnsecure(InstanceCreationExpression node) {
    final token = node.beginToken;
    final baseConstructor = token.lexeme;
    final constructorName = node.constructorName.name?.name;
    final constructorToken = token.next?.next?.lexeme;

    return baseConstructor == 'Random' &&
        (constructorName == 'secure' || constructorToken == 'secure');
  }
}
