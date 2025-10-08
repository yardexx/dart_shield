import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:dart_shield/src/security_analyzer/rules/rules_list/crypto/prefer_secure_random.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('PreferSecureRandom', () {
    late PreferSecureRandom rule;

    setUp(() {
      rule = PreferSecureRandom(excludes: []);
    });

    group('detects insecure Random usage', () {
      test('flags Random() constructor as violation', () async {
        const code = '''
import 'dart:math';

void main() {
  final random = Random();
}
''';

        final result = await _analyzeCode(code);
        final issues = rule.check(result);

        expect(issues.length, equals(1));
        expect(issues.first.ruleId, equals('preferSecureRandom'));
        expect(
          issues.first.message,
          contains('Random() is not cryptographically safe'),
        );
      });

      test('flags Random() in variable assignment', () async {
        const code = '''
import 'dart:math';

void main() {
  Random random = Random();
}
''';

        final result = await _analyzeCode(code);
        final issues = rule.check(result);

        expect(issues.length, equals(1));
      });

      test('flags Random() in method call', () async {
        const code = '''
import 'dart:math';

void generateNumber() {
  return Random().nextInt(100);
}
''';

        final result = await _analyzeCode(code);
        final issues = rule.check(result);

        expect(issues.length, equals(1));
      });

      test('flags multiple Random() instances', () async {
        const code = '''
import 'dart:math';

void main() {
  final random1 = Random();
  final random2 = Random();
}
''';

        final result = await _analyzeCode(code);
        final issues = rule.check(result);

        expect(issues.length, equals(2));
      });
    });

    group('does not flag secure Random usage', () {
      test('does not flag Random.secure()', () async {
        const code = '''
import 'dart:math';

void main() {
  final random = Random.secure();
}
''';

        final result = await _analyzeCode(code);
        final issues = rule.check(result);

        expect(issues.length, equals(0));
      });

      test('does not flag Random.secure() in variable assignment', () async {
        const code = '''
import 'dart:math';

void main() {
  Random random = Random.secure();
}
''';

        final result = await _analyzeCode(code);
        final issues = rule.check(result);

        expect(issues.length, equals(0));
      });

      test('does not flag Random.secure() in method call', () async {
        const code = '''
import 'dart:math';

void generateNumber() {
  return Random.secure().nextInt(100);
}
''';

        final result = await _analyzeCode(code);
        final issues = rule.check(result);

        expect(issues.length, equals(0));
      });

      test('does not flag other Random methods', () async {
        const code = '''
import 'dart:math';

void main() {
  final random = Random.secure();
  final value = random.nextInt(100);
  final doubleValue = random.nextDouble();
}
''';

        final result = await _analyzeCode(code);
        final issues = rule.check(result);

        expect(issues.length, equals(0));
      });
    });

    group('mixed usage scenarios', () {
      test('flags only insecure Random() when both are present', () async {
        const code = '''
import 'dart:math';

void main() {
  final secureRandom = Random.secure();
  final insecureRandom = Random();
}
''';

        final result = await _analyzeCode(code);
        final issues = rule.check(result);

        expect(issues.length, equals(1));
      });

      test('handles Random in different scopes', () async {
        const code = '''
import 'dart:math';

class RandomGenerator {
  Random secureRandom = Random.secure();
  
  void generateInsecure() {
    final random = Random();
  }
  
  void generateSecure() {
    final random = Random.secure();
  }
}
''';

        final result = await _analyzeCode(code);
        final issues = rule.check(result);

        expect(issues.length, equals(1));
      });
    });

    group('rule properties', () {
      test('has correct rule ID', () {
        expect(rule.id.name, equals('preferSecureRandom'));
      });

      test('has correct severity', () {
        expect(rule.severity.name, equals('info'));
      });

      test('has correct status', () {
        expect(rule.status.name, equals('experimental'));
      });

      test('has appropriate message', () {
        expect(
          rule.message,
          contains('Random() is not cryptographically safe'),
        );
        expect(rule.message, contains('Random.secure()'));
      });
    });
  });
}

/// Helper function to analyze Dart code and return a ResolvedUnitResult
Future<ResolvedUnitResult> _analyzeCode(String code) async {
  // Create a temporary file
  final tempDir = Directory.systemTemp.createTempSync('dart_shield_test_');
  final tempFile = File(path.join(tempDir.path, 'test.dart'))
    ..writeAsStringSync(code);

  try {
    // Create analysis context
    final collection = AnalysisContextCollection(includedPaths: [tempDir.path]);
    final context = collection.contexts.first;

    // Get resolved unit
    final result = await context.currentSession.getResolvedUnit(tempFile.path);

    if (result is ResolvedUnitResult) {
      return result;
    } else {
      throw Exception('Failed to resolve unit: $result');
    }
  } finally {
    // Clean up temporary file
    tempFile.deleteSync();
    tempDir.deleteSync(recursive: true);
  }
}
