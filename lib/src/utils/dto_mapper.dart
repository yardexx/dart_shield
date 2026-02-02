import 'package:dart_shield/src/analyzers/code/rules/rule_metadata.dart';
import 'package:dart_shield/src/utils/analyzer_result.dart';
import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/issue_context.dart';

extension DtoDiagnosticMapper on Diagnostic {
  AnalysisIssue? toAnalysisIssue() {
    // If location is missing, we can't really report it in a specific context
    // useful for the user in the same way. However, for now, we'll assume
    // location is required for a valid issue.
    if (location == null) return null;

    return AnalysisIssue(
      ruleId: code,
      severity: _mapSeverity(code),
      message: problemMessage,
      context: FileContext(
        filePath: location!.file,
        line: location!.range.start.line,
        column: location!.range.start.column,
      ),
    );
  }

  /// Maps the rule ID to its severity level from the rule metadata registry.
  ///
  /// Falls back to severity based on the diagnostic severity string if the
  /// rule is not found in the registry.
  Severity _mapSeverity(String ruleId) {
    // First, try to get severity from the rule metadata registry
    final metadata = getRuleMetadata(ruleId);
    if (metadata != null) {
      return metadata.severity;
    }

    // Fallback to diagnostic severity if rule not found
    switch (severity.toUpperCase()) {
      case 'ERROR':
        return Severity.high;
      case 'WARNING':
        return Severity.medium;
      case 'INFO':
        return Severity.low;
      default:
        return Severity.info;
    }
  }
}
