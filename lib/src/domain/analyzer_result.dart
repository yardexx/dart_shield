import 'package:dart_shield/src/domain/analysis_issue.dart';

sealed class AnalyzerResult {
  String get analyzerId;

  Duration get duration;
}

class AnalysisSuccess extends AnalyzerResult {
  AnalysisSuccess({
    required this.analyzerId,
    required this.duration,
    required this.issues,
  });

  @override
  final String analyzerId;
  @override
  final Duration duration;

  final List<AnalysisIssue> issues;
}

class AnalysisFailure extends AnalyzerResult {
  AnalysisFailure({
    required this.analyzerId,
    required this.duration,
    required this.errorMessage,
    this.stackTrace,
  });

  @override
  final String analyzerId;
  @override
  final Duration duration;

  final String errorMessage;
  final StackTrace? stackTrace;
}
