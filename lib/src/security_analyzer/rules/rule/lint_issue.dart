import 'package:dart_shield/src/security_analyzer/extensions.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';
import 'package:source_span/source_span.dart';

class LintIssue {
  LintIssue({
    required this.ruleId,
    required this.severity,
    required this.message,
    required this.location,
  });

  factory LintIssue.withRule({
    required LintRule rule,
    required String message,
    required SourceSpan location,
  }) {
    return LintIssue(
      ruleId: rule.id.name,
      severity: rule.severity,
      message: message,
      location: location,
    );
  }

  final String ruleId;
  final Severity severity;
  final String message;
  final SourceSpan location;

  Map<String, Object?> toJson() => {
        'ruleId': ruleId,
        'severity': severity.name,
        'message': message,
        'location': location.toJson(),
      };
}
