import 'package:dart_shield/src/analyzers/code/rules/secrets/secret_rule.dart';
import 'package:test/test.dart';

void main() {
  group('SecretRule', () {
    test('fromJson parses standard rule correctly', () {
      final json = {
        'id': 'test-rule',
        'description': 'Test Description',
        'pattern': 'abc',
        'keywords': ['key'],
        'minEntropy': 1.5,
      };

      final rule = SecretRule.fromJson(json);

      expect(rule.id, 'test-rule');
      expect(rule.description, 'Test Description');
      expect(rule.pattern.pattern, 'abc');
      expect(rule.pattern.isCaseSensitive, isTrue); // Default
      expect(rule.pattern.isMultiLine, isFalse); // Default
      expect(rule.keywords, ['key']);
      expect(rule.minEntropy, 1.5);
    });

    test('fromJson parses flags correctly', () {
      final json = {
        'id': 'flags-rule',
        'description': 'desc',
        'pattern': 'abc',
        'isCaseSensitive': false,
        'isMultiLine': true,
      };

      final rule = SecretRule.fromJson(json);

      expect(rule.pattern.isCaseSensitive, isFalse);
      expect(rule.pattern.isMultiLine, isTrue);
    });

    test('toJson serializes correctly with flags', () {
      final rule = SecretRule(
        id: 'test',
        description: 'desc',
        pattern: RegExp('abc', caseSensitive: false, multiLine: true),
        keywords: ['k'],
        minEntropy: 2,
      );

      final json = rule.toJson();

      expect(json['id'], 'test');
      expect(json['pattern'], 'abc');
      expect(json['isCaseSensitive'], isFalse);
      expect(json['isMultiLine'], isTrue);
      expect(json['keywords'], ['k']);
      expect(json['minEntropy'], 2.0);
    });
  });
}
