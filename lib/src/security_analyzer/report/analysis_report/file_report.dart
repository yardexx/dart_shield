import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';

class FileReport {
  FileReport({
    required this.relativePath,
    required this.warnings,
    required this.infos,
  });

  factory FileReport.fromIssues(String relativePath, List<LintIssue> issues) {
    final warnings =
        issues.where((issue) => issue.severity == Severity.warning).toList();
    final infos =
        issues.where((issue) => issue.severity == Severity.info).toList();

    return FileReport(
      relativePath: relativePath,
      warnings: warnings,
      infos: infos,
    );
  }

  final String relativePath;
  final List<LintIssue> warnings;
  final List<LintIssue> infos;

  int get warningCount => warnings.length;

  int get infoCount => infos.length;

  Map<String, Object?> toJson() => {
        'relativePath': relativePath,
        'warnings': warnings.map((issue) => issue.toJson()).toList(),
        'infos': infos.map((issue) => issue.toJson()).toList(),
      };

  @override
  String toString() {
    final buffer = StringBuffer()..writeln('📄 $relativePath');
    for (final issue in warnings) {
      buffer.writeln(issue.toString());
    }
    return buffer.toString();
  }
}
