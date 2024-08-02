import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:dart_shield/src/security_analyzer/extensions.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';
import 'package:glob/glob.dart';

class LintRule {
  LintRule({
    required this.id,
    required this.message,
    required this.severity,
    required this.excludes,
    this.status = RuleStatus.stable,
  });

  final RuleId id;
  final String message;
  final Severity severity;
  final Iterable<Glob> excludes;
  final RuleStatus status;

  Iterable<LintIssue> check(ResolvedUnitResult source) {
    final issues = collectErrorNodes(source);
    return issues
        .map(
          (item) => LintIssue.withRule(
            rule: this,
            message: message,
            location: SourceSpanX.fromNode(node: item, source: source),
          ),
        )
        .toList(growable: false);
  }

  List<SyntacticEntity> collectErrorNodes(ResolvedUnitResult source) {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.name,
      'message': message,
      'severity': severity.name,
      'excludes': excludes.map((glob) => glob.pattern).toList(),
    };
  }
}
