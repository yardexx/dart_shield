import 'dart:convert';

import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:dart_shield/src/domain/issue_context.dart';
import 'package:dart_shield/src/reporters/sarif/sarif_reporter.dart';
import 'package:test/test.dart';

void main() {
  group('SarifReporter', () {
    late SarifReporter reporter;

    setUp(() {
      reporter = SarifReporter();
    });

    test('has correct id', () {
      expect(reporter.id, 'sarif');
    });

    test('generates valid SARIF 2.1.0 schema', () {
      final results = [
        AnalysisSuccess(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          issues: [],
        ),
      ];

      final output = reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;

      expect(sarif[r'$schema'], contains('sarif'));
      expect(sarif['version'], '2.1.0');
      expect(sarif['runs'], isA<List>());
    });

    test('includes tool information', () {
      final results = [
        AnalysisSuccess(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          issues: [],
        ),
      ];

      final output = reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;
      final tool = sarif['runs'][0]['tool']['driver'] as Map<String, dynamic>;

      expect(tool['name'], 'dart_shield');
      expect(tool['informationUri'], contains('github.com'));
      expect(tool['rules'], isA<List>());
    });

    test('maps issues to SARIF results', () {
      final results = [
        AnalysisSuccess(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          issues: [
            AnalysisIssue(
              ruleId: 'avoid_hardcoded_secrets',
              severity: Severity.high,
              message: 'Hardcoded secret detected: AWS credentials',
              context: FileContext(
                filePath: 'lib/src/api.dart',
                line: 10,
                column: 5,
              ),
            ),
          ],
        ),
      ];

      final output = reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;
      final sarifResults = sarif['runs'][0]['results'] as List;

      expect(sarifResults, hasLength(1));
      expect(sarifResults[0]['ruleId'], 'avoid_hardcoded_secrets');
      expect(sarifResults[0]['level'], 'error'); // high -> error
      expect(sarifResults[0]['message']['text'], contains('AWS'));
    });

    test('maps severity correctly', () {
      // high -> error
      // medium -> warning
      // low -> note
      // info -> note
      final results = [
        AnalysisSuccess(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          issues: [
            AnalysisIssue(
              ruleId: 'rule1',
              severity: Severity.high,
              message: 'High severity',
              context: FileContext(filePath: 'a.dart', line: 1, column: 1),
            ),
            AnalysisIssue(
              ruleId: 'rule2',
              severity: Severity.medium,
              message: 'Medium severity',
              context: FileContext(filePath: 'a.dart', line: 2, column: 1),
            ),
            AnalysisIssue(
              ruleId: 'rule3',
              severity: Severity.low,
              message: 'Low severity',
              context: FileContext(filePath: 'a.dart', line: 3, column: 1),
            ),
            AnalysisIssue(
              ruleId: 'rule4',
              severity: Severity.info,
              message: 'Info severity',
              context: FileContext(filePath: 'a.dart', line: 4, column: 1),
            ),
          ],
        ),
      ];

      final output = reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;
      final sarifResults = sarif['runs'][0]['results'] as List;

      expect(sarifResults[0]['level'], 'error');
      expect(sarifResults[1]['level'], 'warning');
      expect(sarifResults[2]['level'], 'note');
      expect(sarifResults[3]['level'], 'note');
    });

    test('includes physical location with URI', () {
      final results = [
        AnalysisSuccess(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          issues: [
            AnalysisIssue(
              ruleId: 'test_rule',
              severity: Severity.medium,
              message: 'Test message',
              context: FileContext(
                filePath: 'lib/src/service.dart',
                line: 42,
                column: 10,
              ),
            ),
          ],
        ),
      ];

      final output = reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;
      final location = sarif['runs'][0]['results'][0]['locations'][0]
          as Map<String, dynamic>;
      final physicalLocation =
          location['physicalLocation'] as Map<String, dynamic>;

      expect(
        physicalLocation['artifactLocation']['uri'],
        'lib/src/service.dart',
      );
      expect(physicalLocation['region']['startLine'], 42);
      expect(physicalLocation['region']['startColumn'], 10);
    });

    test('handles empty results', () {
      final results = <AnalyzerResult>[];

      final output = reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;

      expect(sarif['runs'], hasLength(1));
      expect(sarif['runs'][0]['results'], isEmpty);
    });

    test('handles multiple analysis successes', () {
      final results = [
        AnalysisSuccess(
          analyzerId: 'analyzer1',
          duration: Duration(milliseconds: 50),
          issues: [
            AnalysisIssue(
              ruleId: 'rule1',
              severity: Severity.high,
              message: 'Issue from analyzer 1',
              context: FileContext(filePath: 'a.dart', line: 1, column: 1),
            ),
          ],
        ),
        AnalysisSuccess(
          analyzerId: 'analyzer2',
          duration: Duration(milliseconds: 75),
          issues: [
            AnalysisIssue(
              ruleId: 'rule2',
              severity: Severity.medium,
              message: 'Issue from analyzer 2',
              context: FileContext(filePath: 'b.dart', line: 2, column: 2),
            ),
          ],
        ),
      ];

      final output = reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;
      final sarifResults = sarif['runs'][0]['results'] as List;

      expect(sarifResults, hasLength(2));
      expect(sarifResults[0]['ruleId'], 'rule1');
      expect(sarifResults[1]['ruleId'], 'rule2');
    });

    test('handles analysis failures gracefully', () {
      final results = [
        AnalysisFailure(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          errorMessage: 'Failed to analyze',
          stackTrace: StackTrace.current,
        ),
      ];

      final output = reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;

      // Should still produce valid SARIF with empty results
      expect(sarif['version'], '2.1.0');
      expect(sarif['runs'][0]['results'], isEmpty);
    });

    test('handles mixed success and failure results', () {
      final results = [
        AnalysisSuccess(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          issues: [
            AnalysisIssue(
              ruleId: 'test_rule',
              severity: Severity.medium,
              message: 'Test issue',
              context: FileContext(filePath: 'a.dart', line: 1, column: 1),
            ),
          ],
        ),
        AnalysisFailure(
          analyzerId: 'broken',
          duration: Duration(milliseconds: 50),
          errorMessage: 'Something went wrong',
        ),
      ];

      final output = reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;
      final sarifResults = sarif['runs'][0]['results'] as List;

      // Only the successful analysis issue should appear
      expect(sarifResults, hasLength(1));
      expect(sarifResults[0]['ruleId'], 'test_rule');
    });

    test('registers unique rules in tool driver', () {
      final results = [
        AnalysisSuccess(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          issues: [
            AnalysisIssue(
              ruleId: 'avoid_hardcoded_secrets',
              severity: Severity.high,
              message: 'Secret 1',
              context: FileContext(filePath: 'a.dart', line: 1, column: 1),
            ),
            AnalysisIssue(
              ruleId: 'avoid_hardcoded_secrets',
              severity: Severity.high,
              message: 'Secret 2',
              context: FileContext(filePath: 'b.dart', line: 2, column: 2),
            ),
            AnalysisIssue(
              ruleId: 'prefer_https_over_http',
              severity: Severity.medium,
              message: 'HTTP used',
              context: FileContext(filePath: 'c.dart', line: 3, column: 3),
            ),
          ],
        ),
      ];

      final output = reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;
      final rules =
          sarif['runs'][0]['tool']['driver']['rules'] as List<dynamic>;

      // Should have 2 unique rules
      expect(rules, hasLength(2));

      final ruleIds = rules.map((r) => r['id'] as String).toSet();
      expect(ruleIds, contains('avoid_hardcoded_secrets'));
      expect(ruleIds, contains('prefer_https_over_http'));
    });
  });
}
