import 'package:dart_shield/src/security_analyzer/configuration/lint_rule_converter.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rules.dart';
import 'package:glob/glob.dart';
import 'package:test/test.dart';

void main() {
  const converter = LintRuleConverter();

  group('LintRuleConverter', () {
    group('string format', () {
      test('fromJson should return a LintRule object for valid ruleId', () {
        final rule = converter.fromJson('avoid-hardcoded-urls');
        expect(rule, isA<LintRule>());
        expect(rule.id, equals(RuleId.avoidHardcodedUrls));
        expect(rule.excludes, isEmpty);
      });

      test('fromJson should throw an exception for invalid ruleId', () {
        expect(() => converter.fromJson('invalid-rule-id'), throwsArgumentError);
      });
    });

    group('object format', () {
      test('fromJson should parse object format with exclude patterns', () {
        final rule = converter.fromJson({
          'avoid-hardcoded-secrets': {
            'exclude': ['test/**', 'lib/config.dart']
          }
        });
        expect(rule, isA<LintRule>());
        expect(rule.id, equals(RuleId.avoidHardcodedSecrets));
        expect(rule.excludes, hasLength(2));
        expect(rule.excludes.any((glob) => glob.pattern == 'test/**'), isTrue);
        expect(rule.excludes.any((glob) => glob.pattern == 'lib/config.dart'), isTrue);
      });

      test('fromJson should handle object format with empty exclude', () {
        final rule = converter.fromJson({
          'prefer-https-over-http': {}
        });
        expect(rule, isA<LintRule>());
        expect(rule.id, equals(RuleId.preferHttpsOverHttp));
        expect(rule.excludes, isEmpty);
      });

      test('fromJson should handle object format with missing exclude', () {
        final rule = converter.fromJson({
          'prefer-https-over-http': {'other-config': 'value'}
        });
        expect(rule, isA<LintRule>());
        expect(rule.id, equals(RuleId.preferHttpsOverHttp));
        expect(rule.excludes, isEmpty);
      });

      test('fromJson should throw for object format with multiple entries', () {
        expect(() => converter.fromJson({
          'rule1': {},
          'rule2': {}
        }), throwsArgumentError);
      });
    });

    group('mixed format support', () {
      test('should handle both string and object formats', () {
        // Test string format
        final stringRule = converter.fromJson('avoid-hardcoded-urls');
        expect(stringRule.id, equals(RuleId.avoidHardcodedUrls));
        expect(stringRule.excludes, isEmpty);

        // Test object format
        final objectRule = converter.fromJson({
          'avoid-hardcoded-secrets': {
            'exclude': ['test/**']
          }
        });
        expect(objectRule.id, equals(RuleId.avoidHardcodedSecrets));
        expect(objectRule.excludes, hasLength(1));
      });
    });

    test('toJson should return a string for valid LintRule', () {
      final rule = RuleRegistry.createRule(
        id: RuleId.avoidHardcodedUrls,
        excludes: [Glob('test/**')],
      );
      final ruleId = converter.toJson(rule);
      expect(ruleId, isA<String>());
      expect(ruleId, equals(RuleId.avoidHardcodedUrls.name));
    });
  });
}
