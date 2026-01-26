import 'package:dart_shield/src/domain/issue_context.dart';

enum Severity { high, medium, low, info }

class AnalysisIssue {
  AnalysisIssue({
    required this.ruleId,
    required this.severity,
    required this.message,
    required this.context,
  });

  final String ruleId;
  final Severity severity;
  final String message;

  final IssueContext context;

  Map<String, dynamic> toJson() {
    return {
      'ruleId': ruleId,
      'severity': severity.name,
      'message': message,
      'context': context.toJson(),
    };
  }
}
