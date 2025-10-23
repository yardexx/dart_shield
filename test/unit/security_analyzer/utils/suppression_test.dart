import 'package:analyzer/source/line_info.dart';
import 'package:dart_shield/src/security_analyzer/utils/suppression.dart';
import 'package:test/test.dart';

LineInfo _createLineInfo(String content) {
  final lineStarts = <int>[];
  for (var i = 0; i < content.length; i++) {
    if (i == 0 || content[i - 1] == '\n') {
      lineStarts.add(i);
    }
  }
  lineStarts.add(content.length); // End of file
  return LineInfo(lineStarts);
}

void main() {
  group('Suppression', () {
    group('shield_ignore comments', () {
      test('parses single rule on same line', () {
        const content = '''
void main() {
  const key = 'secret'; // shield_ignore: avoid_hardcoded_secrets
}
''';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        expect(
          suppression.isSuppressedAt('avoid_hardcoded_secrets', 2),
          isTrue,
        );
        expect(
          suppression.isSuppressedAt('prefer_https_over_http', 2),
          isFalse,
        );
      });

      test('parses single rule on next line', () {
        const content = '''
void main() {
  // shield_ignore: avoid_hardcoded_secrets
  const key = 'secret';
}
''';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        expect(
          suppression.isSuppressedAt('avoid_hardcoded_secrets', 3),
          isTrue,
        );
        expect(
          suppression.isSuppressedAt('prefer_https_over_http', 3),
          isFalse,
        );
      });

      test('parses multiple rules in one comment', () {
        const content = '''
void main() {
  const key = 'secret'; // shield_ignore: avoid_hardcoded_secrets, prefer_https_over_http
}
''';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        expect(
          suppression.isSuppressedAt('avoid_hardcoded_secrets', 2),
          isTrue,
        );
        expect(suppression.isSuppressedAt('prefer_https_over_http', 2), isTrue);
        expect(suppression.isSuppressedAt('avoid_weak_hashing', 2), isFalse);
      });

      test('handles case insensitive matching', () {
        const content = '''
void main() {
  const key = 'secret'; // shield_ignore: AVOID_HARDCODED_SECRETS
}
''';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        expect(
          suppression.isSuppressedAt('avoid_hardcoded_secrets', 2),
          isTrue,
        );
      });

      test('handles snake_case parsing', () {
        const content = '''
void main() {
  const key = 'secret'; // shield_ignore: avoid_hardcoded_secrets
}
''';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        expect(
          suppression.isSuppressedAt('avoid_hardcoded_secrets', 2),
          isTrue,
        );
      });

      test('ignores standard ignore comments', () {
        const content = '''
void main() {
  const key = 'secret'; // ignore: avoid_hardcoded_secrets
}
''';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        expect(
          suppression.isSuppressedAt('avoid_hardcoded_secrets', 2),
          isFalse,
        );
      });
    });

    group('shield_ignore_for_file comments', () {
      test('parses file-level suppression', () {
        const content = '''
// shield_ignore_for_file: avoid_hardcoded_secrets

void main() {
  const key = 'secret';
}
''';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        expect(suppression.isSuppressed('avoid_hardcoded_secrets'), isTrue);
        expect(
          suppression.isSuppressedAt('avoid_hardcoded_secrets', 4),
          isTrue,
        );
        expect(
          suppression.isSuppressedAt('prefer_https_over_http', 4),
          isFalse,
        );
      });

      test('parses multiple file-level suppressions', () {
        const content = '''
// shield_ignore_for_file: avoid_hardcoded_secrets, prefer_https_over_http

void main() {
  const key = 'secret';
}
''';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        expect(suppression.isSuppressed('avoid_hardcoded_secrets'), isTrue);
        expect(suppression.isSuppressed('prefer_https_over_http'), isTrue);
        expect(suppression.isSuppressed('avoid_weak_hashing'), isFalse);
      });

      test('handles case insensitive file-level suppression', () {
        const content = '''
// shield_ignore_for_file: AVOID_HARDCODED_SECRETS

void main() {
  const key = 'secret';
}
''';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        expect(suppression.isSuppressed('avoid_hardcoded_secrets'), isTrue);
      });

      test('ignores standard ignore_for_file comments', () {
        const content = '''
// ignore_for_file: avoid_hardcoded_secrets

void main() {
  const key = 'secret';
}
''';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        expect(suppression.isSuppressed('avoid_hardcoded_secrets'), isFalse);
      });
    });

    group('edge cases', () {
      test('handles empty content', () {
        const content = '';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        expect(suppression.isSuppressed('any_rule'), isFalse);
        expect(suppression.isSuppressedAt('any_rule', 1), isFalse);
      });

      test('handles whitespace in rule names', () {
        const content = '''
void main() {
  const key = 'secret'; // shield_ignore:  avoid_hardcoded_secrets  ,  prefer_https_over_http  
}
''';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        expect(
          suppression.isSuppressedAt('avoid_hardcoded_secrets', 2),
          isTrue,
        );
        expect(suppression.isSuppressedAt('prefer_https_over_http', 2), isTrue);
      });

      test('handles malformed comments gracefully', () {
        const content = '''
void main() {
  const key = 'secret'; // shield_ignore:
  const url = 'http://example.com'; // shield_ignore: ,
}
''';
        final lineInfo = _createLineInfo(content);
        final suppression = Suppression(content, lineInfo);

        // Should not crash and should not match anything
        expect(suppression.isSuppressedAt('any_rule', 2), isFalse);
        expect(suppression.isSuppressedAt('any_rule', 3), isFalse);
      });
    });
  });
}
