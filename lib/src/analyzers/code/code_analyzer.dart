// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:dart_shield/src/analyzers/analyzer.dart';
import 'package:dart_shield/src/analyzers/code/rules/rules.dart';
import 'package:dart_shield/src/analyzers/utils/diagnostic_mapper.dart';
import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:dart_shield/src/utils/path.dart';

class CodeAnalyzer implements Analyzer {
  CodeAnalyzer({
    required this.analyzedPaths,
    String? rootFolder,
  }) : rootFolder = rootFolder ?? Directory.current.path;

  final List<String> analyzedPaths;
  final String rootFolder;

  late final Set<String> _shieldRuleNames = rules
      .map((r) => r.name.toLowerCase())
      .toSet();

  @override
  String get id => 'dart_shield_code';

  @override
  Future<AnalyzerResult> analyze() async {
    final stopWatch = Stopwatch()..start();

    try {
      final collection = _createCollection();
      final allIssues = <AnalysisIssue>[];

      for (final context in collection.contexts) {
        final issues = await _analyzeContext(context);
        allIssues.addAll(issues);
      }

      return AnalysisSuccess(
        analyzerId: id,
        duration: stopWatch.elapsed,
        issues: allIssues,
      );
    } catch (e, trace) {
      return AnalysisFailure(
        analyzerId: id,
        duration: stopWatch.elapsed,
        errorMessage: 'Analysis crashed: $e',
        stackTrace: trace,
      );
    }
  }

  AnalysisContextCollection _createCollection() {
    final normalizedPaths = analyzedPaths
        .map((p) => normalize(p, rootFolder))
        .toList();

    return AnalysisContextCollection(includedPaths: normalizedPaths);
  }

  Future<List<AnalysisIssue>> _analyzeContext(AnalysisContext context) async {
    final issues = <AnalysisIssue>[];
    final filesToAnalyze = context.contextRoot.analyzedFiles();

    for (final file in filesToAnalyze) {
      if (!file.endsWith('.dart')) continue;

      try {
        final result = await context.currentSession.getResolvedUnit(file);
        // Delegate the logic to a pure function
        final analysisIssues = _analyzeResult(result, file);
        issues.addAll(analysisIssues);
      } catch (e) {
        // TODO: Log this to a verbose logger if you have one
        // print('Failed to analyze $file: $e');
      }
    }

    return issues;
  }

  List<AnalysisIssue> _analyzeResult(
    SomeResolvedUnitResult result,
    String file,
  ) {
    if (result is! ResolvedUnitResult) return [];

    return result.diagnostics
        .where(_isShieldRule)
        .map((d) => d.toAnalysisIssue(file, result.lineInfo))
        .toList();
  }

  bool _isShieldRule(Diagnostic diagnostic) {
    final codeName = diagnostic.diagnosticCode.name.toLowerCase();
    return _shieldRuleNames.contains(codeName);
  }
}
