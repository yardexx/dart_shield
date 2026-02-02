import 'package:analyzer/diagnostic/diagnostic.dart' as analyzer;
import 'package:analyzer/source/line_info.dart';
import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/issue_context.dart';

extension DiagnosticMapper on analyzer.Diagnostic {
  AnalysisIssue toAnalysisIssue(String filePath, LineInfo lineInfo) {
    final offset = problemMessage.offset;
    final location = lineInfo.getLocation(offset);

    return AnalysisIssue(
      ruleId: diagnosticCode.lowerCaseName,
      severity: _mapSeverity(severity),
      message: problemMessage.messageText.toString(),
      context: FileContext(
        filePath: filePath,
        line: location.lineNumber,
        column: location.columnNumber,
      ),
    );
  }

  Severity _mapSeverity(analyzer.Severity severity) {
    switch (severity) {
      case analyzer.Severity.error:
        return Severity.high;
      case analyzer.Severity.warning:
        return Severity.medium;
      case analyzer.Severity.info:
        return Severity.low;
    }
  }
}
