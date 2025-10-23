import 'package:dart_shield/src/security_analyzer/rules/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('MatchingPattern', () {
    group('constructor', () {
      test('creates pattern with name and pattern string', () {
        final pattern = MatchingPattern(
          name: 'test_pattern',
          pattern: r'\d+',
        );

        expect(pattern.name, equals('test_pattern'));
        expect(pattern.pattern, equals(r'\d+'));
      });

      test('handles empty name', () {
        final pattern = MatchingPattern(
          name: '',
          pattern: r'\d+',
        );

        expect(pattern.name, equals(''));
        expect(pattern.pattern, equals(r'\d+'));
      });

      test('handles empty pattern', () {
        final pattern = MatchingPattern(
          name: 'test_pattern',
          pattern: '',
        );

        expect(pattern.name, equals('test_pattern'));
        expect(pattern.pattern, equals(''));
      });
    });

    group('regex property', () {
      test('creates RegExp from pattern string', () {
        final pattern = MatchingPattern(
          name: 'number_pattern',
          pattern: r'\d+',
        );

        final regex = pattern.regex;
        expect(regex, isA<RegExp>());
        expect(regex.hasMatch('123'), isTrue);
        expect(regex.hasMatch('abc'), isFalse);
      });

      test('handles complex regex patterns', () {
        final pattern = MatchingPattern(
          name: 'email_pattern',
          pattern: r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );

        final regex = pattern.regex;
        expect(regex.hasMatch('test@example.com'), isTrue);
        expect(regex.hasMatch('invalid-email'), isFalse);
      });

      test('handles special regex characters', () {
        final pattern = MatchingPattern(
          name: 'special_chars',
          pattern: r'[.*+?^${}()|[\]\\]',
        );

        final regex = pattern.regex;
        expect(regex.hasMatch('.'), isTrue);
        expect(regex.hasMatch('*'), isTrue);
        expect(regex.hasMatch('+'), isTrue);
        expect(regex.hasMatch('?'), isTrue);
        expect(regex.hasMatch('^'), isTrue);
        expect(regex.hasMatch(r'$'), isTrue);
        expect(regex.hasMatch('{'), isTrue);
        expect(regex.hasMatch('}'), isTrue);
        expect(regex.hasMatch('('), isTrue);
        expect(regex.hasMatch(')'), isTrue);
        expect(regex.hasMatch('|'), isTrue);
        expect(regex.hasMatch('['), isTrue);
        expect(regex.hasMatch(']'), isTrue);
        expect(regex.hasMatch(r'\'), isTrue);
      });

      test('handles empty pattern', () {
        final pattern = MatchingPattern(
          name: 'empty_pattern',
          pattern: '',
        );

        final regex = pattern.regex;
        expect(regex.hasMatch(''), isTrue);
        expect(
          regex.hasMatch('any'),
          isTrue,
        ); // Empty pattern matches everything
      });

      test('handles invalid regex patterns gracefully', () {
        final pattern = MatchingPattern(
          name: 'invalid_pattern',
          pattern: '[unclosed bracket',
        );

        // Should throw FormatException for invalid regex
        expect(() => pattern.regex, throwsA(isA<FormatException>()));
      });
    });

    group('fromJson factory', () {
      test('creates pattern from valid JSON', () {
        final json = {
          'name': 'test_pattern',
          'pattern': r'\d+',
        };

        final pattern = MatchingPattern.fromJson(json);
        expect(pattern.name, equals('test_pattern'));
        expect(pattern.pattern, equals(r'\d+'));
      });

      test('handles JSON with extra fields', () {
        final json = {
          'name': 'test_pattern',
          'pattern': r'\d+',
          'extra_field': 'ignored',
        };

        final pattern = MatchingPattern.fromJson(json);
        expect(pattern.name, equals('test_pattern'));
        expect(pattern.pattern, equals(r'\d+'));
      });

      test('handles missing fields', () {
        final json = <String, dynamic>{};

        expect(() => MatchingPattern.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('properties', () {
      test('pattern properties are accessible', () {
        final pattern = MatchingPattern(
          name: 'test_pattern',
          pattern: r'\d+',
        );

        expect(pattern.name, equals('test_pattern'));
        expect(pattern.pattern, equals(r'\d+'));
        expect(pattern.regex, isA<RegExp>());
      });
    });
  });
}
