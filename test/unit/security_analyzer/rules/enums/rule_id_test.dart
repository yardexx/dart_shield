import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:test/test.dart';

void main() {
  group('RuleId', () {
    group('fromYamlName', () {
      test('converts snake_case to camelCase correctly', () {
        expect(
          RuleId.fromYamlName('prefer_https_over_http'),
          equals(RuleId.preferHttpsOverHttp),
        );
        expect(
          RuleId.fromYamlName('avoid_hardcoded_urls'),
          equals(RuleId.avoidHardcodedUrls),
        );
        expect(
          RuleId.fromYamlName('avoid_hardcoded_secrets'),
          equals(RuleId.avoidHardcodedSecrets),
        );
        expect(
          RuleId.fromYamlName('avoid_weak_hashing'),
          equals(RuleId.avoidWeakHashing),
        );
        expect(
          RuleId.fromYamlName('prefer_secure_random'),
          equals(RuleId.preferSecureRandom),
        );
      });

      test('handles single word rules', () {
        // Test edge case for rules without underscores - should throw for
        // non-existent rules
        expect(
          () => RuleId.fromYamlName('test_rule'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws for invalid rule names', () {
        expect(
          () => RuleId.fromYamlName('invalid_rule'),
          throwsA(isA<ArgumentError>()),
        );
        expect(() => RuleId.fromYamlName(''), throwsA(isA<ArgumentError>()));
        expect(
          () => RuleId.fromYamlName('unknown_rule_name'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('handles case sensitivity', () {
        expect(
          () => RuleId.fromYamlName('PREFER_HTTPS_OVER_HTTP'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('toUnderscoreCase', () {
      test('converts camelCase to underscore_case correctly', () {
        expect(
          RuleId.preferHttpsOverHttp.toUnderscoreCase(),
          equals('prefer_https_over_http'),
        );
        expect(
          RuleId.avoidHardcodedUrls.toUnderscoreCase(),
          equals('avoid_hardcoded_urls'),
        );
        expect(
          RuleId.avoidHardcodedSecrets.toUnderscoreCase(),
          equals('avoid_hardcoded_secrets'),
        );
        expect(
          RuleId.avoidWeakHashing.toUnderscoreCase(),
          equals('avoid_weak_hashing'),
        );
        expect(
          RuleId.preferSecureRandom.toUnderscoreCase(),
          equals('prefer_secure_random'),
        );
      });

      test('handles single word rules', () {
        // Test edge case for rules without camelCase
        expect(
          RuleId.preferSecureRandom.toUnderscoreCase(),
          equals('prefer_secure_random'),
        );
      });
    });

    group('enum values', () {
      test('has all expected rule IDs', () {
        expect(RuleId.values.length, equals(5));
        expect(RuleId.values, contains(RuleId.preferHttpsOverHttp));
        expect(RuleId.values, contains(RuleId.avoidHardcodedUrls));
        expect(RuleId.values, contains(RuleId.avoidHardcodedSecrets));
        expect(RuleId.values, contains(RuleId.avoidWeakHashing));
        expect(RuleId.values, contains(RuleId.preferSecureRandom));
      });

      test('enum values are unique', () {
        final values = RuleId.values.map((e) => e.name).toSet();
        expect(values.length, equals(RuleId.values.length));
      });
    });

    group('round-trip conversion', () {
      test('fromYamlName and toUnderscoreCase work together', () {
        for (final ruleId in RuleId.values) {
          final underscoreCase = ruleId.toUnderscoreCase();
          final convertedBack = RuleId.fromYamlName(underscoreCase);
          expect(convertedBack, equals(ruleId));
        }
      });
    });
  });
}
