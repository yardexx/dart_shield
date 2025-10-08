import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:dart_shield/src/security_analyzer/extensions.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';
import 'package:glob/glob.dart';

abstract class LintRule {
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

  /// Collects AST nodes that violate this rule.
  /// 
  /// This method must be implemented by concrete rule implementations.
  /// It should traverse the provided [source] and identify all AST nodes
  /// that represent security violations according to this rule's logic.
  /// 
  /// Returns a list of [SyntacticEntity] nodes where violations were found.
  /// An empty list indicates no violations were detected in the source.
  /// 
  /// Example implementation:
  /// ```dart
  /// @override
  /// List<SyntacticEntity> collectErrorNodes(ResolvedUnitResult source) {
  ///   final visitor = _MyRuleVisitor();
  ///   source.unit.accept(visitor);
  ///   return visitor.errorNodes;
  /// }
  /// ```
  List<SyntacticEntity> collectErrorNodes(ResolvedUnitResult source);

  Map<String, dynamic> toJson() {
    return {
      'id': id.name,
      'message': message,
      'severity': severity.name,
      'excludes': excludes.map((glob) => glob.pattern).toList(),
    };
  }
}
