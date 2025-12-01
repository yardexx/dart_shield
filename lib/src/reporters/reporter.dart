import 'package:dart_shield/src/domain/analyzer_result.dart';

abstract interface class Reporter {
  String get id;

  Future<void> report(List<AnalyzerResult> results);
}
