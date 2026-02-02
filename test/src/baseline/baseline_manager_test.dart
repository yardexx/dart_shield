import 'dart:io';

import 'package:dart_shield/src/baseline/baseline_manager.dart';
import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/issue_context.dart';
import 'package:test/test.dart';

void main() {
  group('BaselineManager', () {
    late Directory tempDir;
    late File baselineFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('baseline_test_');
      baselineFile = File('${tempDir.path}/shield_baseline.yaml');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('creates baseline file from issues', () async {
      final manager = BaselineManager(baselineFile.path);
      final issues = [
        AnalysisIssue(
          ruleId: 'avoid_hardcoded_secrets',
          severity: Severity.high,
          message: 'Secret detected',
          context: FileContext(filePath: 'lib/api.dart', line: 10, column: 5),
        ),
      ];

      await manager.createBaseline(issues);

      expect(baselineFile.existsSync(), isTrue);
      final content = baselineFile.readAsStringSync();
      expect(content, contains('avoid_hardcoded_secrets'));
      expect(content, contains('lib/api.dart'));
      expect(content, contains('10')); // line number
    });

    test('loads existing baseline', () async {
      baselineFile.writeAsStringSync('''
baseline:
  - rule_id: avoid_hardcoded_secrets
    file: lib/api.dart
    line: 10
    fingerprint: abc123def456
''');

      final manager = BaselineManager(baselineFile.path);
      final baseline = await manager.loadBaseline();

      expect(baseline, hasLength(1));
      expect(baseline.first.ruleId, 'avoid_hardcoded_secrets');
      expect(baseline.first.file, 'lib/api.dart');
      expect(baseline.first.line, 10);
      expect(baseline.first.fingerprint, 'abc123def456');
    });

    test('filters out baselined issues', () async {
      // Create a manager to get the fingerprint
      final manager = BaselineManager(baselineFile.path);

      final baselinedIssue = AnalysisIssue(
        ruleId: 'avoid_hardcoded_secrets',
        severity: Severity.high,
        message: 'Secret detected',
        context: FileContext(filePath: 'lib/api.dart', line: 10, column: 5),
      );

      // Generate the fingerprint for the baselined issue
      final fingerprint = manager.generateFingerprint(baselinedIssue);

      baselineFile.writeAsStringSync('''
baseline:
  - rule_id: avoid_hardcoded_secrets
    file: lib/api.dart
    line: 10
    fingerprint: $fingerprint
''');

      final issues = [
        // This should be filtered (in baseline)
        baselinedIssue,
        // This should NOT be filtered (new issue)
        AnalysisIssue(
          ruleId: 'prefer_https_over_http',
          severity: Severity.high,
          message: 'HTTP detected',
          context: FileContext(
            filePath: 'lib/client.dart',
            line: 20,
            column: 3,
          ),
        ),
      ];

      final filtered = await manager.filterBaselined(issues);

      expect(filtered, hasLength(1));
      expect(filtered.first.ruleId, 'prefer_https_over_http');
    });

    test('generates stable fingerprint', () {
      final manager = BaselineManager(baselineFile.path);

      final issue = AnalysisIssue(
        ruleId: 'test_rule',
        severity: Severity.medium,
        message: 'Test message',
        context: FileContext(filePath: 'lib/test.dart', line: 5, column: 1),
      );

      final fp1 = manager.generateFingerprint(issue);
      final fp2 = manager.generateFingerprint(issue);

      expect(fp1, equals(fp2));
    });

    test('fingerprint changes when line changes', () {
      final manager = BaselineManager(baselineFile.path);

      final issue1 = AnalysisIssue(
        ruleId: 'test_rule',
        severity: Severity.medium,
        message: 'Test message',
        context: FileContext(filePath: 'lib/test.dart', line: 5, column: 1),
      );

      final issue2 = AnalysisIssue(
        ruleId: 'test_rule',
        severity: Severity.medium,
        message: 'Test message',
        context: FileContext(filePath: 'lib/test.dart', line: 6, column: 1),
      );

      final fp1 = manager.generateFingerprint(issue1);
      final fp2 = manager.generateFingerprint(issue2);

      expect(fp1, isNot(equals(fp2)));
    });

    test('fingerprint changes when file changes', () {
      final manager = BaselineManager(baselineFile.path);

      final issue1 = AnalysisIssue(
        ruleId: 'test_rule',
        severity: Severity.medium,
        message: 'Test message',
        context: FileContext(filePath: 'lib/test.dart', line: 5, column: 1),
      );

      final issue2 = AnalysisIssue(
        ruleId: 'test_rule',
        severity: Severity.medium,
        message: 'Test message',
        context: FileContext(filePath: 'lib/other.dart', line: 5, column: 1),
      );

      final fp1 = manager.generateFingerprint(issue1);
      final fp2 = manager.generateFingerprint(issue2);

      expect(fp1, isNot(equals(fp2)));
    });

    test('fingerprint changes when rule changes', () {
      final manager = BaselineManager(baselineFile.path);

      final issue1 = AnalysisIssue(
        ruleId: 'rule_a',
        severity: Severity.medium,
        message: 'Test message',
        context: FileContext(filePath: 'lib/test.dart', line: 5, column: 1),
      );

      final issue2 = AnalysisIssue(
        ruleId: 'rule_b',
        severity: Severity.medium,
        message: 'Test message',
        context: FileContext(filePath: 'lib/test.dart', line: 5, column: 1),
      );

      final fp1 = manager.generateFingerprint(issue1);
      final fp2 = manager.generateFingerprint(issue2);

      expect(fp1, isNot(equals(fp2)));
    });

    test('returns empty list when no baseline exists', () async {
      final manager = BaselineManager('nonexistent.yaml');
      final baseline = await manager.loadBaseline();

      expect(baseline, isEmpty);
    });

    test('returns all issues when no baseline exists', () async {
      final manager = BaselineManager('nonexistent.yaml');
      final issues = [
        AnalysisIssue(
          ruleId: 'test_rule',
          severity: Severity.medium,
          message: 'Test',
          context: FileContext(filePath: 'a.dart', line: 1, column: 1),
        ),
      ];

      final filtered = await manager.filterBaselined(issues);

      expect(filtered, hasLength(1));
    });

    test('handles multiple issues in baseline', () async {
      final manager = BaselineManager(baselineFile.path);

      final issue1 = AnalysisIssue(
        ruleId: 'rule1',
        severity: Severity.high,
        message: 'Issue 1',
        context: FileContext(filePath: 'a.dart', line: 1, column: 1),
      );
      final issue2 = AnalysisIssue(
        ruleId: 'rule2',
        severity: Severity.medium,
        message: 'Issue 2',
        context: FileContext(filePath: 'b.dart', line: 2, column: 2),
      );

      await manager.createBaseline([issue1, issue2]);

      final baseline = await manager.loadBaseline();
      expect(baseline, hasLength(2));

      final filtered = await manager.filterBaselined([issue1, issue2]);
      expect(filtered, isEmpty);
    });

    test('handles empty issues list', () async {
      final manager = BaselineManager(baselineFile.path);

      await manager.createBaseline([]);

      expect(baselineFile.existsSync(), isTrue);

      final baseline = await manager.loadBaseline();
      expect(baseline, isEmpty);
    });

    test('baseline file is human-readable YAML', () async {
      final manager = BaselineManager(baselineFile.path);
      final issues = [
        AnalysisIssue(
          ruleId: 'avoid_hardcoded_secrets',
          severity: Severity.high,
          message: 'Secret detected',
          context: FileContext(filePath: 'lib/api.dart', line: 10, column: 5),
        ),
      ];

      await manager.createBaseline(issues);

      final content = baselineFile.readAsStringSync();
      // Check it's valid YAML structure
      expect(content, contains('baseline:'));
      expect(content, contains('rule_id:'));
      expect(content, contains('file:'));
      expect(content, contains('line:'));
      expect(content, contains('fingerprint:'));
    });
  });
}
