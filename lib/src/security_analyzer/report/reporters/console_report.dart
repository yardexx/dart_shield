import 'package:dart_shield/src/security_analyzer/extensions.dart';
import 'package:dart_shield/src/security_analyzer/report/report.dart';
import 'package:dart_shield/src/security_analyzer/report/reporters/issue_reporter.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/lint_issue.dart';

class ConsoleReport extends IssueReporter {
  final StringBuffer _buffer = StringBuffer();

  // Emoji symbols for report readability
  static const String criticalSymbol = '❌';
  static const String warningSymbol = '⚠️';
  static const String infoSymbol = 'ℹ️';
  static const String noIssuesSymbol = '🎉';
  static const String analyzedFilePrefix = '>>> Analyzed File:';

  @override
  String report(ProjectReport report) {
    _buffer.clear();
    _appendReportHeader(report);
    _appendFileReports(report.fileReports);
    return _buffer.toString();
  }

  // Appends the header section of the report
  void _appendReportHeader(ProjectReport projectReport) {
    _buffer
      ..writeln('=== [Analysis Summary] ===')
      ..writeln('📄 Files Analyzed: ${projectReport.fileReports.length}')
      ..writeln('$criticalSymbol Critical Issues: ${projectReport.criticalCount}')
      ..writeln('$warningSymbol Warnings: ${projectReport.warningCount}')
      ..writeln('$infoSymbol Infos: ${projectReport.infoCount}')
      ..linePadding();
  }

  // Appends file-specific reports
  void _appendFileReports(List<FileReport> fileReports) {
    _buffer
      ..writeln('=== [File Reports] ===')
      ..linePadding();

    if (fileReports.isEmpty) {
      _buffer.writeln('⚠️ No files analyzed. Check command or configuration.');
    } else {
      fileReports.forEach(_appendSingleFileReport);
    }
  }

  // Appends the report for a single file
  void _appendSingleFileReport(FileReport fileReport) {
    _buffer
      ..writeln('$analyzedFilePrefix ${fileReport.relativePath}')
      ..linePadding();

    if (!fileReport.hasIssues) {
      _buffer
        ..writeln('$noIssuesSymbol No issues found!')
        ..linePadding();
    } else {
      _appendIssues('Critical Issues', criticalSymbol, fileReport.criticals);
      _appendIssues('Warnings', warningSymbol, fileReport.warnings);
      _appendIssues('Infos', infoSymbol, fileReport.infos);
    }
  }

  // Appends issues of a specific severity type (Critical, Warning, Info)
  void _appendIssues(String title, String symbol, List<LintIssue> issues) {
    _buffer.writeln('--- [ $title ] ---');
    for (final issue in issues) {
      _buffer.writeln(
        '$symbol\t[${issue.ruleId}] ${issue.message}\n'
            '\t- Location: ${issue.location.string}\n',
      );
    }
  }
}

extension StringBufferExtension on StringBuffer {
  // Adds a new line for padding
  void linePadding() => writeln();
}
