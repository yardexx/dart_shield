import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidWeakHashing extends AnalysisRule {
  AvoidWeakHashing()
    : super(name: 'avoid_weak_hashing', description: 'Some description');
  static const LintCode code = LintCode(
    'avoid_weak_hashing',
    'Using weak hashing algorithms can lead to security vulnerabilities.',
    correctionMessage:
        'Consider using stronger hashing algorithms like SHA-256 or SHA-3.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _WeakCryptoHashingVisitor(this, context);
    registry
      ..addMethodInvocation(this, visitor)
      ..addAssignmentExpression(this, visitor);
  }
}

class _WeakCryptoHashingVisitor extends SimpleAstVisitor<void> {
  _WeakCryptoHashingVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;
  final _unsafeHashes = ['md5', 'sha1'];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_isTargetWeakHash(node)) {
      rule.reportAtNode(node);
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
      rule.reportAtNode(node);
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
