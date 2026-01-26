import 'package:dart_shield/src/domain/analyzer_result.dart';

abstract interface class Analyzer {
  String get id;

  Future<AnalyzerResult> analyze();
}
