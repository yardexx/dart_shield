import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';

class FileReport {
  FileReport({
    required this.relativePath,
    required this.criticals,
    required this.warnings,
    required this.infos,
  });

  factory FileReport.fromIssues(String relativePath, List<LintIssue> issues) {
    final criticals=
        issues.where((issue) => issue.severity == Severity.critical).toList();
    final warnings =
        issues.where((issue) => issue.severity == Severity.warning).toList();
    final infos =
        issues.where((issue) => issue.severity == Severity.info).toList();

    return FileReport(
      relativePath: relativePath,
      criticals: criticals,
      warnings: warnings,
      infos: infos,
    );
  }

  final String relativePath;
  final List<LintIssue> criticals;
  final List<LintIssue> warnings;
  final List<LintIssue> infos;

  int get criticalCount => criticals.length;

  int get warningCount => warnings.length;

  int get infoCount => infos.length;

  bool get hasIssues => criticalCount > 0 || warningCount > 0 || infoCount > 0;

  Map<String, Object?> toJson() => {
        'relativePath': relativePath,
        'criticals': criticals.map((issue) => issue.toJson()).toList(),
        'warnings': warnings.map((issue) => issue.toJson()).toList(),
        'infos': infos.map((issue) => issue.toJson()).toList(),
      };
}
