import 'package:dart_shield/src/security_analyzer/report/report.dart';

// Will be extended in the future.
// ignore: one_member_abstracts
abstract class IssueReporter {
  String report(ProjectReport report);
}
