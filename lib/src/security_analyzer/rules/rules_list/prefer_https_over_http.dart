import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:dart_shield/src/security_analyzer/extensions.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';

class PreferHttpsOverHttp extends LintRule {
  PreferHttpsOverHttp({required super.excludes})
      : super(
          id: RuleId.preferHttpsOverHttp,
          message: _message,
          severity: Severity.info,
        );

  static const _message = 'Prefer HTTPS over HTTP for URLs in the code.';

  @override
  List<SyntacticEntity> collectErrorNodes(ResolvedUnitResult source) {
    final visitor = _PreferHttpsOverHttpVisitor();
    source.unit.accept(visitor);
    return visitor.errorNodes;
  }
}

class _PreferHttpsOverHttpVisitor extends ErrorNodeCollector {
  final _packageName = 'dart:core';

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!node.belongsToPackage(_packageName)) {
      return super.visitInstanceCreationExpression(node);
    }

    if (node.beginToken.lexeme != 'Uri') {
      return;
    }

    if (_isUnsafeUriInstance(node)) {
      errorNodes.add(node);
    }

    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.beginToken.lexeme.startsWith('http:')) {
      errorNodes.add(node);
    }

    super.visitSimpleStringLiteral(node);
  }

  bool _isUnsafeUriInstance(InstanceCreationExpression node) {
    final token = node.beginToken;
    final baseConstructor = token.lexeme;
    final constructorName = node.constructorName.name?.name;
    final constructorToken = token.next?.next?.lexeme;

    return baseConstructor == 'Uri' &&
        (constructorName == 'http' || constructorToken == 'http');
  }
}
