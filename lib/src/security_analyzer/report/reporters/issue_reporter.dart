import 'package:dart_shield/src/security_analyzer/report/report.dart';

// ignore: one_member_abstracts
abstract class IssueReporter {
  String report(ProjectReport report);
}
