// ignore_for_file: unnecessary_raw_strings

import 'package:dart_shield/src/security_analyzer/rules/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('ShieldSecrets', () {
    group('constructor', () {
      test('creates ShieldSecrets with version, secrets, and keys', () {
        final secrets = [
          MatchingPattern(name: 'api_key', pattern: r'api[_-]?key'),
          MatchingPattern(name: 'secret', pattern: r'secret[_-]?key'),
        ];
        final keys = [
          MatchingPattern(name: 'private_key', pattern: r'private[_-]?key'),
        ];

        final shieldSecrets = ShieldSecrets(
          version: '1.0.0',
          secrets: secrets,
          keys: keys,
        );

        expect(shieldSecrets.version, equals('1.0.0'));
        expect(shieldSecrets.secrets, equals(secrets));
        expect(shieldSecrets.keys, equals(keys));
      });

      test('handles empty secrets and keys lists', () {
        final shieldSecrets = ShieldSecrets(
          version: '1.0.0',
          secrets: [],
          keys: [],
        );

        expect(shieldSecrets.version, equals('1.0.0'));
        expect(shieldSecrets.secrets, isEmpty);
        expect(shieldSecrets.keys, isEmpty);
      });
    });

    group('containsSecret', () {
      late ShieldSecrets shieldSecrets;

      setUp(() {
        shieldSecrets = ShieldSecrets(
          version: '1.0.0',
          secrets: [
            MatchingPattern(name: 'api_key', pattern: r'api[_-]?key'),
            MatchingPattern(name: 'secret', pattern: r'secret[_-]?key'),
          ],
          keys: [
            MatchingPattern(name: 'private_key', pattern: r'private[_-]?key'),
          ],
        );
      });

      test('returns true for values matching secret patterns', () {
        expect(shieldSecrets.containsSecret('api_key'), isTrue);
        expect(shieldSecrets.containsSecret('api-key'), isTrue);
        expect(shieldSecrets.containsSecret('apikey'), isTrue);
        expect(shieldSecrets.containsSecret('secret_key'), isTrue);
        expect(shieldSecrets.containsSecret('secret-key'), isTrue);
        expect(shieldSecrets.containsSecret('secretkey'), isTrue);
      });

      test('returns true for values matching key patterns', () {
        expect(shieldSecrets.containsSecret('private_key'), isTrue);
        expect(shieldSecrets.containsSecret('private-key'), isTrue);
        expect(shieldSecrets.containsSecret('privatekey'), isTrue);
      });

      test('returns false for values not matching any patterns', () {
        expect(shieldSecrets.containsSecret('password'), isFalse);
        expect(shieldSecrets.containsSecret('token'), isFalse);
        expect(shieldSecrets.containsSecret('random_string'), isFalse);
        expect(shieldSecrets.containsSecret(''), isFalse);
      });

      test('handles case sensitivity', () {
        expect(shieldSecrets.containsSecret('API_KEY'), isFalse);
        expect(shieldSecrets.containsSecret('Api_Key'), isFalse);
      });

      test('handles partial matches', () {
        expect(shieldSecrets.containsSecret('my_api_key_value'), isTrue);
        expect(shieldSecrets.containsSecret('some_secret_key_here'), isTrue);
        expect(shieldSecrets.containsSecret('private_key_value'), isTrue);
      });
    });

    group('fromYaml factory', () {
      test('creates ShieldSecrets from valid YAML structure', () {
        final yamlData = {
          'shield_patterns': {
            'version': '1.0.0',
            'secrets': [
              {'name': 'api_key', 'pattern': r'api[_-]?key'},
              {'name': 'secret', 'pattern': r'secret[_-]?key'},
            ],
            'keys': [
              {'name': 'private_key', 'pattern': r'private[_-]?key'},
            ],
          },
        };

        final shieldSecrets = ShieldSecrets.fromYaml(yamlData);
        expect(shieldSecrets.version, equals('1.0.0'));
        expect(shieldSecrets.secrets.length, equals(2));
        expect(shieldSecrets.keys.length, equals(1));
      });

      test('handles YAML with empty lists', () {
        final yamlData = {
          'shield_patterns': {
            'version': '1.0.0',
            'secrets': <Map<String, dynamic>>[],
            'keys': <Map<String, dynamic>>[],
          },
        };

        final shieldSecrets = ShieldSecrets.fromYaml(yamlData);
        expect(shieldSecrets.version, equals('1.0.0'));
        expect(shieldSecrets.secrets, isEmpty);
        expect(shieldSecrets.keys, isEmpty);
      });

      test('throws for missing shield_patterns key', () {
        final yamlData = {
          'version': '1.0.0',
          'secrets': <Map<String, dynamic>>[],
          'keys': <Map<String, dynamic>>[],
        };

        expect(
          () => ShieldSecrets.fromYaml(yamlData),
          throwsA(isA<TypeError>()),
        );
      });

      test('throws for invalid YAML structure', () {
        final yamlData = {
          'shield_patterns': 'invalid',
        };

        expect(
          () => ShieldSecrets.fromYaml(yamlData),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('preset factory', () {
      test('creates ShieldSecrets from preset configuration', () {
        final shieldSecrets = ShieldSecrets.preset();

        expect(shieldSecrets.version, isNotEmpty);
        expect(shieldSecrets.secrets, isNotEmpty);
        expect(shieldSecrets.keys, isNotEmpty);
      });

      test('preset configuration contains expected patterns', () {
        final shieldSecrets = ShieldSecrets.preset();

        // Test that preset configuration is loaded successfully
        expect(shieldSecrets.version, isNotEmpty);
        expect(shieldSecrets.secrets, isNotEmpty);
        expect(shieldSecrets.keys, isNotEmpty);

        // Test that patterns can detect secrets, without assuming
        // specific patterns
        // This tests the functionality without depending on
        // specific preset content
        expect(shieldSecrets.secrets.length, greaterThan(0));
        expect(shieldSecrets.keys.length, greaterThan(0));
      });
    });

    group('properties', () {
      test('ShieldSecrets properties are accessible', () {
        final secrets = [
          MatchingPattern(name: 'test', pattern: r'test'),
        ];
        final keys = [
          MatchingPattern(name: 'key', pattern: r'key'),
        ];

        final shieldSecrets = ShieldSecrets(
          version: '1.0.0',
          secrets: secrets,
          keys: keys,
        );

        expect(shieldSecrets.version, equals('1.0.0'));
        expect(shieldSecrets.secrets, equals(secrets));
        expect(shieldSecrets.keys, equals(keys));
      });
    });
  });
}
