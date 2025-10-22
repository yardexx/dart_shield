import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

void main() {
  group('LintIssue', () {
    group('constructor', () {
      test('creates LintIssue with all required fields', () {
        final location = SourceSpan(
          SourceLocation(0, sourceUrl: Uri.parse('file://test.dart')),
          SourceLocation(12, sourceUrl: Uri.parse('file://test.dart')),
          'test content',
        );

        final issue = LintIssue(
          ruleId: 'test_rule',
          severity: Severity.warning,
          message: 'Test message',
          location: location,
        );

        expect(issue.ruleId, equals('test_rule'));
        expect(issue.severity, equals(Severity.warning));
        expect(issue.message, equals('Test message'));
        expect(issue.location, equals(location));
      });

      test('handles different severity levels', () {
        final location = SourceSpan(
          SourceLocation(0, sourceUrl: Uri.parse('file://test.dart')),
          SourceLocation(12, sourceUrl: Uri.parse('file://test.dart')),
          'test content',
        );

        final criticalIssue = LintIssue(
          ruleId: 'critical_rule',
          severity: Severity.critical,
          message: 'Critical message',
          location: location,
        );

        final warningIssue = LintIssue(
          ruleId: 'warning_rule',
          severity: Severity.warning,
          message: 'Warning message',
          location: location,
        );

        final infoIssue = LintIssue(
          ruleId: 'info_rule',
          severity: Severity.info,
          message: 'Info message',
          location: location,
        );

        expect(criticalIssue.severity, equals(Severity.critical));
        expect(warningIssue.severity, equals(Severity.warning));
        expect(infoIssue.severity, equals(Severity.info));
      });
    });

    group('withRule factory', () {
      test('creates LintIssue from rule with correct properties', () {
        final location = SourceSpan(
          SourceLocation(0, sourceUrl: Uri.parse('file://test.dart')),
          SourceLocation(12, sourceUrl: Uri.parse('file://test.dart')),
          'test content',
        );

        // Create a mock rule for testing
        final rule = _MockLintRule(
          id: RuleId.avoidHardcodedSecrets,
          severity: Severity.critical,
          message: 'Avoid hardcoding secrets',
        );

        final issue = LintIssue.withRule(
          rule: rule,
          message: 'Custom message',
          location: location,
        );

        expect(issue.ruleId, equals('avoid_hardcoded_secrets'));
        expect(issue.severity, equals(Severity.critical));
        expect(issue.message, equals('Custom message'));
        expect(issue.location, equals(location));
      });

      test('uses rule properties correctly', () {
        final location = SourceSpan(
          SourceLocation(0, sourceUrl: Uri.parse('file://test.dart')),
          SourceLocation(12, sourceUrl: Uri.parse('file://test.dart')),
          'test content',
        );

        final rule = _MockLintRule(
          id: RuleId.preferHttpsOverHttp,
          severity: Severity.info,
          message: 'Prefer HTTPS over HTTP',
        );

        final issue = LintIssue.withRule(
          rule: rule,
          message: 'Use HTTPS instead',
          location: location,
        );

        expect(issue.ruleId, equals('prefer_https_over_http'));
        expect(issue.severity, equals(Severity.info));
        expect(issue.message, equals('Use HTTPS instead'));
      });
    });

    group('toJson', () {
      test('converts LintIssue to JSON correctly', () {
        final location = SourceSpan(
          SourceLocation(5, sourceUrl: Uri.parse('file://test.dart'), line: 1, column: 5),
          SourceLocation(17, sourceUrl: Uri.parse('file://test.dart'), line: 1, column: 17),
          'test content',
        );

        final issue = LintIssue(
          ruleId: 'test_rule',
          severity: Severity.warning,
          message: 'Test message',
          location: location,
        );

        final json = issue.toJson();

        expect(json['ruleId'], equals('test_rule'));
        expect(json['severity'], equals('warning'));
        expect(json['message'], equals('Test message'));
        expect(json['location'], isA<Map<String, Object?>>());
        
        final locationJson = json['location'] as Map<String, Object?>;
        expect(locationJson['startLine'], equals(1));
        expect(locationJson['startColumn'], equals(5));
        expect(locationJson['endLine'], equals(1));
        expect(locationJson['endColumn'], equals(17));
      });

      test('handles different severity levels in JSON', () {
        final location = SourceSpan(
          SourceLocation(0, sourceUrl: Uri.parse('file://test.dart')),
          SourceLocation(12, sourceUrl: Uri.parse('file://test.dart')),
          'test content',
        );

        final criticalIssue = LintIssue(
          ruleId: 'critical_rule',
          severity: Severity.critical,
          message: 'Critical message',
          location: location,
        );

        final warningIssue = LintIssue(
          ruleId: 'warning_rule',
          severity: Severity.warning,
          message: 'Warning message',
          location: location,
        );

        final infoIssue = LintIssue(
          ruleId: 'info_rule',
          severity: Severity.info,
          message: 'Info message',
          location: location,
        );

        expect(criticalIssue.toJson()['severity'], equals('critical'));
        expect(warningIssue.toJson()['severity'], equals('warning'));
        expect(infoIssue.toJson()['severity'], equals('info'));
      });
    });

    group('properties', () {
      test('LintIssue properties are accessible', () {
        final location = SourceSpan(
          SourceLocation(0, sourceUrl: Uri.parse('file://test.dart')),
          SourceLocation(12, sourceUrl: Uri.parse('file://test.dart')),
          'test content',
        );

        final issue = LintIssue(
          ruleId: 'test_rule',
          severity: Severity.warning,
          message: 'Test message',
          location: location,
        );

        expect(issue.ruleId, equals('test_rule'));
        expect(issue.severity, equals(Severity.warning));
        expect(issue.message, equals('Test message'));
        expect(issue.location, equals(location));
      });
    });
  });
}

// Mock LintRule for testing
class _MockLintRule extends LintRule {
  _MockLintRule({
    required RuleId id,
    required Severity severity,
    required String message,
  }) : super(
          id: id,
          message: message,
          severity: severity,
          excludes: [],
        );

  @override
  List<SyntacticEntity> collectErrorNodes(ResolvedUnitResult source) => [];
}
