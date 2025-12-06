import 'package:dart_shield/src/analyzers/utils/analyzer_result.dart';
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
      severity: _mapSeverity(severity),
      message: problemMessage,
      context: FileContext(
        filePath: location!.file,
        line: location!.range.start.line,
        column: location!.range.start.column,
      ),
    );
  }

  Severity _mapSeverity(String severity) {
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
