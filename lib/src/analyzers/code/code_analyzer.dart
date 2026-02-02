import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_shield/src/analyzers/analyzer.dart';
import 'package:dart_shield/src/analyzers/code/rules/rules.dart';
import 'package:dart_shield/src/utils/analyzer_result.dart';
import 'package:dart_shield/src/utils/dto_mapper.dart';
import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:dart_shield/src/domain/exceptions.dart';
import 'package:path/path.dart' as path;

class CodeAnalyzer implements Analyzer {
  CodeAnalyzer({required this.analyzedPaths, String? rootFolder})
    : rootFolder = rootFolder ?? Directory.current.path;

  final List<String> analyzedPaths;
  final String rootFolder;

  @override
  String get id => 'code';

  @override
  Future<AnalyzerResult> analyze() async {
    final stopwatch = Stopwatch()..start();

    try {
      final issues = <AnalysisIssue>[];
      final knownRuleIds = rules.map((r) => r.name).toSet();

      for (final targetPath in analyzedPaths) {
        final target = path.join(rootFolder, targetPath);

        ProcessResult result;
        try {
          result = await Process.run('dart', [
            'analyze',
            '--format=json',
            target,
          ], runInShell: true);
        } on ProcessException catch (e) {
          throw ShieldProcessException(
            'Failed to execute dart analyze.',
            'Ensure the Dart SDK is installed and accessible in your PATH.\n'
                'Original error: ${e.message}',
          );
        }

        final output = result.stdout as String;

        // `dart analyze` may output impure json (should be fixed by now)
        // https://github.com/invertase/dart_custom_lint/issues/224
        final jsonString = output
            .split('\n')
            .firstWhereOrNull((e) => e.trim().startsWith('{'));

        if (jsonString == null) {
          throw ShieldProcessException(
            'dart analyze did not return valid JSON output.',
            'This usually means the analysis command crashed or '
                'encountered a fatal error.\nOutput: $output',
          );
        }

        final analyzeResult = AnalyzeResult.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>,
        );

        for (final diagnostic in analyzeResult.diagnostics) {
          if (knownRuleIds.contains(diagnostic.code)) {
            final issue = diagnostic.toAnalysisIssue();
            if (issue != null) {
              issues.add(issue);
            }
          }
        }
      }

      stopwatch.stop();

      return AnalysisSuccess(
        analyzerId: id,
        duration: stopwatch.elapsed,
        issues: issues,
      );
    } on Object catch (e, stack) {
      return AnalysisFailure(
        analyzerId: id,
        duration: stopwatch.elapsed,
        errorMessage: 'Failed to run code analysis: $e',
        stackTrace: stack,
      );
    }
  }
}
