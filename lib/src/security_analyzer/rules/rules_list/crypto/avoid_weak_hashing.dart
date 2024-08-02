import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';

class AvoidWeakHashing extends LintRule {
  AvoidWeakHashing({required super.excludes})
      : super(
          id: RuleId.avoidWeakHashing,
          message: _message,
          severity: Severity.warning,
          status: RuleStatus.experimental,
        );

  static const _message =
      'Avoid using weak hashing algorithms such as MD5 or SHA-1.';

  @override
  List<SyntacticEntity> collectErrorNodes(ResolvedUnitResult source) {
    final visitor = _WeakCryptoHashingVisitor();
    source.unit.accept(visitor);
    return visitor.errorNodes;
  }
}

class _WeakCryptoHashingVisitor extends ErrorNodeCollector {
  final _unsafeHashes = ['md5', 'sha1'];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_isTargetWeakHash(node)) {
      errorNodes.add(node);
    }

    super.visitMethodInvocation(node);
  }

  bool _isTargetWeakHash(MethodInvocation node) {
    final target = node.target;
    if (target == null) {
      return false;
    }

    if (target is! SimpleIdentifier) {
      return false;
    }

    return _isIdentifierWeakHash(target);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (_isAssignmentWeakHash(node)) {
      errorNodes.add(node);
    }
  }

  bool _isAssignmentWeakHash(AssignmentExpression node) {
    final rhs = node.rightHandSide;

    if (rhs is SimpleIdentifier) {
      return _isIdentifierWeakHash(rhs);
    }

    return false;
  }

  bool _isIdentifierWeakHash(SimpleIdentifier identifier) {
    return _unsafeHashes.any((weakHash) => weakHash == identifier.name) &&
        identifier.staticType?.getDisplayString() == 'Hash';
  }
}
