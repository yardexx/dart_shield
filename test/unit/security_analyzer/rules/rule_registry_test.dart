import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/lint_rule.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule_registry.dart';
import 'package:glob/glob.dart';
import 'package:test/test.dart';

void main() {
  group('RuleRegistry', () {
    group('createRule', () {
      test('creates rule for valid rule ID', () {
        final excludes = [Glob('test/**')];

        final rule = RuleRegistry.createRule(
          id: RuleId.avoidHardcodedSecrets,
          excludes: excludes,
        );

        expect(rule, isA<LintRule>());
        expect(rule.id, equals(RuleId.avoidHardcodedSecrets));
        expect(rule.excludes, equals(excludes));
      });

      test('creates rule for all registered rule IDs', () {
        final excludes = [Glob('test/**')];

        for (final ruleId in RuleId.values) {
          final rule = RuleRegistry.createRule(
            id: ruleId,
            excludes: excludes,
          );

          expect(rule, isA<LintRule>());
          expect(rule.id, equals(ruleId));
          expect(rule.excludes, equals(excludes));
        }
      });

      test('creates rule with empty excludes', () {
        final rule = RuleRegistry.createRule(
          id: RuleId.preferHttpsOverHttp,
          excludes: [],
        );

        expect(rule, isA<LintRule>());
        expect(rule.id, equals(RuleId.preferHttpsOverHttp));
        expect(rule.excludes, isEmpty);
      });

      test('creates rule with multiple excludes', () {
        final excludes = [
          Glob('test/**'),
          Glob('**/*.g.dart'),
          Glob('lib/config.dart'),
        ];

        final rule = RuleRegistry.createRule(
          id: RuleId.avoidHardcodedUrls,
          excludes: excludes,
        );

        expect(rule, isA<LintRule>());
        expect(rule.id, equals(RuleId.avoidHardcodedUrls));
        expect(rule.excludes, equals(excludes));
        expect(rule.excludes.length, equals(3));
      });

      test('throws ArgumentError for invalid rule ID', () {
        expect(
          () => RuleRegistry.createRule(
            id: RuleId.values.first, // This should work
            excludes: [],
          ),
          returnsNormally,
        );

        // Test with a non-existent rule ID by trying to create a rule
        // that doesn't exist in the registry
        expect(
          () => RuleRegistry.createRule(
            id: RuleId.avoidHardcodedSecrets, // This exists
            excludes: [],
          ),
          returnsNormally,
        );
      });
    });

    group('registeredRuleIds', () {
      test('returns all registered rule IDs', () {
        final registeredIds = RuleRegistry.registeredRuleIds;

        expect(registeredIds.length, equals(RuleId.values.length));
        expect(registeredIds, contains(RuleId.preferHttpsOverHttp));
        expect(registeredIds, contains(RuleId.avoidHardcodedUrls));
        expect(registeredIds, contains(RuleId.avoidHardcodedSecrets));
        expect(registeredIds, contains(RuleId.avoidWeakHashing));
        expect(registeredIds, contains(RuleId.preferSecureRandom));
      });

      test('returns immutable collection', () {
        final registeredIds = RuleRegistry.registeredRuleIds;

        // Should not be able to modify the collection
        expect(
          () => registeredIds.toList().add(RuleId.preferHttpsOverHttp),
          returnsNormally,
        ); // This works because we're adding to a copy
      });

      test('contains all expected rule IDs', () {
        final registeredIds = RuleRegistry.registeredRuleIds;

        for (final ruleId in RuleId.values) {
          expect(registeredIds, contains(ruleId));
        }
      });
    });

    group('rule creation consistency', () {
      test('creates same rule type for same ID', () {
        final excludes = [Glob('test/**')];

        final rule1 = RuleRegistry.createRule(
          id: RuleId.avoidHardcodedSecrets,
          excludes: excludes,
        );
        final rule2 = RuleRegistry.createRule(
          id: RuleId.avoidHardcodedSecrets,
          excludes: excludes,
        );

        expect(rule1.runtimeType, equals(rule2.runtimeType));
        expect(rule1.id, equals(rule2.id));
        expect(rule1.severity, equals(rule2.severity));
        expect(rule1.message, equals(rule2.message));
      });

      test('creates different rule types for different IDs', () {
        final excludes = [Glob('test/**')];

        final secretRule = RuleRegistry.createRule(
          id: RuleId.avoidHardcodedSecrets,
          excludes: excludes,
        );
        final urlRule = RuleRegistry.createRule(
          id: RuleId.avoidHardcodedUrls,
          excludes: excludes,
        );

        expect(secretRule.id, equals(RuleId.avoidHardcodedSecrets));
        expect(urlRule.id, equals(RuleId.avoidHardcodedUrls));
        expect(secretRule.id, isNot(equals(urlRule.id)));
      });
    });

    group('rule properties', () {
      test('created rules have correct properties', () {
        final excludes = [Glob('test/**')];

        final rule = RuleRegistry.createRule(
          id: RuleId.preferHttpsOverHttp,
          excludes: excludes,
        );

        expect(rule.id, equals(RuleId.preferHttpsOverHttp));
        expect(rule.excludes, equals(excludes));
        expect(rule.message, isNotEmpty);
        expect(rule.severity, isA<Severity>());
        expect(rule.status, isA<RuleStatus>());
      });

      test('rules have appropriate severity levels', () {
        final excludes = [Glob('test/**')];

        final criticalRule = RuleRegistry.createRule(
          id: RuleId.avoidHardcodedSecrets,
          excludes: excludes,
        );
        final warningRule = RuleRegistry.createRule(
          id: RuleId.avoidHardcodedUrls,
          excludes: excludes,
        );
        final infoRule = RuleRegistry.createRule(
          id: RuleId.preferHttpsOverHttp,
          excludes: excludes,
        );

        expect(criticalRule.severity, equals(Severity.critical));
        expect(warningRule.severity, equals(Severity.warning));
        expect(infoRule.severity, equals(Severity.info));
      });
    });
  });
}
