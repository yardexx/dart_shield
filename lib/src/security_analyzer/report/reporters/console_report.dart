import 'package:dart_shield/src/security_analyzer/extensions.dart';
import 'package:dart_shield/src/security_analyzer/report/report.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/lint_issue.dart';

class ConsoleReport extends IssueReporter {
  final StringBuffer _buffer = StringBuffer();

  @override
  String report(ProjectReport report) {
    _buffer.clear();
    _reportHeader(report);
    _reportFiles(report.fileReports);
    return _buffer.toString();
  }

  void _reportHeader(ProjectReport report) {
    _buffer
      ..writeln('[Analysis Summary]')
      ..writeln('⚠️ Total Warnings: ${report.warningCount}')
      ..writeln('ℹ️ Total Info: ${report.infoCount}')
      ..linePadding();
  }

  void _reportFiles(List<FileReport> reports) {
    _buffer.writeln('[File Reports]');
    if (reports.isEmpty) {
      _buffer.writeln('⚠️ No files analyzed. Check command or configuration.');
      return;
    }
    reports.forEach(_reportFile);
  }

  void _reportFile(FileReport report) {
    _buffer.writeln('Analyzed file: ${report.relativePath}');
    if (report.warnings.isEmpty && report.infos.isEmpty) {
      _buffer
        ..writeln('✅ No issues found')
        ..linePadding();
      return;
    }

    for (final issue in report.warnings) {
      _reportWarning(report.relativePath, issue);
    }

    for (final issue in report.infos) {
      _reportInfo(report.relativePath, issue);
    }

    _buffer.linePadding();
  }

  void _reportWarning(String filePath, LintIssue issue) {
    _buffer.writeln(
      '⚠️ [${issue.ruleId}] ${issue.message} ${issue.location.string}',
    );
  }

  void _reportInfo(String filePath, LintIssue issue) {
    _buffer.writeln(
      'ℹ️ [${issue.ruleId}] ${issue.message} ${issue.location.string}',
    );
  }
}

extension on StringBuffer {
  void linePadding() => writeln();
}
