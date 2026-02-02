import 'dart:convert';
import 'dart:io';

import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:dart_shield/src/reporters/reporter.dart';
import 'package:mason_logger/mason_logger.dart';

class JsonReporter implements Reporter {
  JsonReporter({this.outputPath = 'shield_report.json', Logger? logger})
    : _logger = logger ?? Logger();

  final String outputPath;
  final Logger _logger;

  @override
  String get id => 'json';

  @override
  Future<void> report(List<AnalyzerResult> results) async {
    final data = results.map((result) {
      return switch (result) {
        final AnalysisSuccess s => {
          'type': 'success',
          'analyzer': s.analyzerId,
          'duration_ms': s.duration.inMilliseconds,
          'issues': s.issues.map((i) => i.toJson()).toList(),
        },
        final AnalysisFailure f => {
          'type': 'failure',
          'analyzer': f.analyzerId,
          'duration_ms': f.duration.inMilliseconds,
          'error': f.errorMessage,
        },
      };
    }).toList();

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    final file = File(outputPath);
    await file.writeAsString(jsonStr);

    // Small feedback so the user knows the file was created
    _logger.info('💾 JSON report generated at: ${file.absolute.path}');
  }
}
