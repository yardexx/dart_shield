import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/models/models.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';

class AvoidHardcodedSecrets extends LintRule {
  AvoidHardcodedSecrets({required super.excludes})
      : super(
          id: RuleId.avoidHardcodedSecrets,
          message: _message,
          severity: Severity.critical,
          status: RuleStatus.stable,
        );

  static const _message =
      'Avoid hardcoding credentials/keys in the code. Use configuration files '
      'or environment variables instead.';

  @override
  List<SyntacticEntity> collectErrorNodes(ResolvedUnitResult source) {
    final secrets = ShieldSecrets.preset();
    final visitor = _AvoidHardcodedCredentialsVisitor(secrets: secrets);
    source.unit.accept(visitor);
    return visitor.errorNodes;
  }
}

class _AvoidHardcodedCredentialsVisitor extends ErrorNodeCollector {
  _AvoidHardcodedCredentialsVisitor({required this.secrets});

  final ShieldSecrets secrets;

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    final valueToCheck = node.value;
    if (secrets.containsSecret(valueToCheck)) {
      errorNodes.add(node);
    }
    super.visitSimpleStringLiteral(node);
  }
}
