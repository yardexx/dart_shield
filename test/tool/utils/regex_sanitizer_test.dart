import 'package:test/test.dart';

import '../../../tool/utils/regex_sanitizer.dart';

void main() {
  group('RegexSanitizer', () {
    test('handles global case insensitivity at start', () {
      final result = RegexSanitizer.sanitize('(?i)abc');
      expect(result.pattern, 'abc');
      expect(result.caseSensitive, isFalse);
    });

    test('handles inline case insensitivity', () {
      final result = RegexSanitizer.sanitize('abc(?i)def');
      expect(result.pattern, 'abcdef');
      expect(result.caseSensitive, isFalse);
    });

    test('handles scoped case insensitivity', () {
      final result = RegexSanitizer.sanitize('(?i:abc)def');
      expect(result.pattern, '(?:abc)def');
      expect(result.caseSensitive, isFalse);
    });

    test('handles multiline flag', () {
      final result = RegexSanitizer.sanitize('(?m)^abc');
      expect(result.pattern, '^abc');
      expect(result.multiLine, isTrue);
    });

    test('handles combined flags', () {
      final result = RegexSanitizer.sanitize('(?i)(?m)abc');
      expect(result.pattern, 'abc');
      expect(result.caseSensitive, isFalse);
      expect(result.multiLine, isTrue);
    });

    test('leaves standard regex untouched', () {
      final result = RegexSanitizer.sanitize(r'^abc[0-9]+$');
      expect(result.pattern, r'^abc[0-9]+$');
      expect(result.caseSensitive, isTrue);
      expect(result.multiLine, isFalse);
    });
  });
}
