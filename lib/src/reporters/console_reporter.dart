import 'dart:io';

import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:dart_shield/src/domain/issue_context.dart';
import 'package:dart_shield/src/reporters/reporter.dart';

class ConsoleReporter implements Reporter {
  @override
  String get id => 'console';

  @override
  Future<void> report(List<AnalyzerResult> results) async {
    final buffer = StringBuffer()
      ..writeln('\n🛡️  SHIELD ANALYSIS REPORT')
      ..writeln('==================================================');

    for (final result in results) {
      _writeResult(buffer, result);
    }

    final totalIssues = results.whereType<AnalysisSuccess>().fold(
      0,
      (sum, r) => sum + r.issues.length,
    );

    buffer
      ..writeln('==================================================')
      ..writeln('Total Issues Found: $totalIssues\n');

    stdout.write(buffer.toString());
  }

  void _writeResult(StringBuffer buffer, AnalyzerResult result) {
    if (result is AnalysisFailure) {
      buffer
        ..writeln(
          '❌ [${result.analyzerId}] FAILED '
          '(${result.duration.inMilliseconds}ms)',
        )
        ..writeln('   Error: ${result.errorMessage}');
      if (result.stackTrace != null) {
        buffer.writeln('   Trace: ${result.stackTrace}');
      }
      buffer.writeln();
      return;
    }

    if (result is AnalysisSuccess) {
      final icon = result.issues.isEmpty ? '✅' : '⚠️ ';
      buffer.writeln(
        '$icon [${result.analyzerId}] found ${result.issues.length} issues '
        '(${result.duration.inMilliseconds}ms)',
      );

      for (final issue in result.issues) {
        _writeIssue(buffer, issue);
      }

      if (result.issues.isNotEmpty) buffer.writeln();
    }
  }

  void _writeIssue(StringBuffer buffer, AnalysisIssue issue) {
    const indent = '   ';

    final icon = switch (issue.severity) {
      Severity.high => '🔴',
      Severity.medium => '🟠',
      Severity.low => '🟡',
      Severity.info => '🔵',
    };

    buffer.writeln('$indent$icon ${issue.message} [${issue.ruleId}]');

    final location = switch (issue.context) {
      FileContext(filePath: final p, line: final l, column: final c) =>
        '$p:$l:$c',
    };

    buffer.writeln('$indent   📍 $location');
  }
}
