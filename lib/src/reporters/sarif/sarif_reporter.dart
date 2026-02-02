import 'dart:io';

import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:dart_shield/src/domain/issue_context.dart';
import 'package:dart_shield/src/reporters/reporter.dart';
import 'package:dart_shield/src/reporters/sarif/sarif_builder.dart';
import 'package:dart_shield/src/reporters/sarif/sarif_document.dart';

/// SARIF reporter that adapts dart_shield results to SARIF format.
///
/// This is a thin adapter - all SARIF logic lives in [SarifBuilder].
class SarifReporter implements Reporter {
  @override
  String get id => 'sarif';

  @override
  Future<void> report(List<AnalyzerResult> results) async {
    final sarif = generateSarif(results);
    stdout.writeln(sarif);
  }

  /// Generate SARIF JSON from analysis results.
  ///
  /// Exposed for testing.
  String generateSarif(List<AnalyzerResult> results) {
    final builder = SarifBuilder(
      toolName: 'dart_shield',
      toolVersion: '0.1.0', // TODO: Read from pubspec
      toolUri: 'https://github.com/yardexx/dart_shield',
    );

    // Extract all issues from successful analyses
    final issues = results.whereType<AnalysisSuccess>().expand((r) => r.issues);

    for (final issue in issues) {
      builder.addResult(
        ruleId: issue.ruleId,
        message: issue.message,
        level: _mapSeverity(issue.severity),
        filePath: _getFilePath(issue.context),
        line: _getLine(issue.context),
        column: _getColumn(issue.context),
        // TODO: Add rule descriptions from metadata
      );
    }

    return builder.buildJson();
  }

  /// Map dart_shield Severity to SARIF Level.
  SarifLevel _mapSeverity(Severity severity) {
    return switch (severity) {
      Severity.high => SarifLevel.error,
      Severity.medium => SarifLevel.warning,
      Severity.low => SarifLevel.note,
      Severity.info => SarifLevel.note,
    };
  }

  String _getFilePath(IssueContext context) {
    return switch (context) {
      FileContext(:final filePath) => filePath,
    };
  }

  int _getLine(IssueContext context) {
    return switch (context) {
      FileContext(:final line) => line,
    };
  }

  int _getColumn(IssueContext context) {
    return switch (context) {
      FileContext(:final column) => column,
    };
  }
}
