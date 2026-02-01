import 'dart:io';

import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:dart_shield/src/domain/issue_context.dart';
import 'package:dart_shield/src/reporters/reporter.dart';
import 'package:dart_shield/src/utils/pubspec.dart';

import 'package:meta/meta.dart';
import 'package:sarif/sarif.dart';

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
  @visibleForTesting
  String generateSarif(List<AnalyzerResult> results) {
    final builder = SarifBuilder(
      toolName: 'dart_shield',
      toolVersion: Pubspec.version(),
      toolUri: 'https://github.com/yardexx/dart_shield',
    );

    // Extract all issues from successful analyses and add them to builder
    results
        .whereType<AnalysisSuccess>()
        .expand((r) => r.issues)
        .forEach((issue) => _addIssue(builder, issue));

    return builder.buildJson();
  }

  /// Add an [AnalysisIssue] to the SARIF builder.
  void _addIssue(SarifBuilder builder, AnalysisIssue issue) {
    final FileContext(:filePath, :line, :column) = issue.context as FileContext;

    builder.addResult(
      ruleId: issue.ruleId,
      message: issue.message,
      level: _mapSeverity(issue.severity),
      filePath: filePath,
      line: line,
      column: column,
    );
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
}
