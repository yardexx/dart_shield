import 'package:dart_shield/src/analyzers/analyzer.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';

class AnalyzerEngine {
  AnalyzerEngine(this._analyzers);

  final List<Analyzer> _analyzers;

  Future<List<AnalyzerResult>> runAll() async {
    final tasks = _analyzers.map((analyzer) => analyzer.analyze());
    return Future.wait(tasks);
  }
}
