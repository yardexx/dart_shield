import 'package:collection/collection.dart';
import 'package:dart_shield/src/security_analyzer/report/report.dart';

class ProjectReport {
  ProjectReport({
    required this.path,
    required this.fileReports,
  });

  factory ProjectReport.empty(String path) {
    return ProjectReport(
      path: path,
      fileReports: [],
    );
  }

  final String path;
  final List<FileReport> fileReports;

  int get criticalCount => fileReports.map((report) => report.criticalCount).sum;
  int get warningCount => fileReports.map((report) => report.warningCount).sum;
  int get infoCount => fileReports.map((report) => report.infoCount).sum;

  Map<String, Object?> toJson() => {
        'path': path,
        'reports': fileReports.map((report) => report.toJson()).toList(),
      };

  void addLintReports(List<FileReport> reports) {
    fileReports.addAll(reports);
  }
}
