import 'dart:io';

import 'package:dart_shield/src/analyzers/code/code_analyzer.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:test/test.dart';

void main() {
  group('Integration Test', () {
    late File targetFile;
    late String originalContent;

    setUp(() {
      targetFile = File('example/lib/vulnerabilities.dart');
      originalContent = targetFile.readAsStringSync();
    });

    tearDown(() {
      targetFile.writeAsStringSync(originalContent);
    });

    test('detects hardcoded secrets via dart analyze plugin', () async {
      // Inject a secret that matches our rules.
      // We construct it dynamically to avoid triggering GitHub's secret scanner
      // on this test file itself.
      // Pattern requires [A-Z2-7]{16}. Also high entropy (> 3.0).
      // ABCDEFGHIJKLMNOP uses only [A-Z], which is valid. And has max entropy.
      const prefix = 'AKIA';
      const suffix = 'ABCDEFGHIJKLMNOP';
      const secret = prefix + suffix;

      final codeWithSecret =
          '''
$originalContent

void injectedSecret() {
  final key = '$secret';
}
''';
      targetFile.writeAsStringSync(codeWithSecret);

      final analyzer = CodeAnalyzer(
        analyzedPaths: ['.'], // Analyze root of example
        rootFolder: 'example',
      );

      final result = await analyzer.analyze();

      expect(result, isA<AnalysisSuccess>());
      final success = result as AnalysisSuccess;

      // Check for our specific rule
      final secretIssues = success.issues
          .where((i) => i.ruleId == 'avoid_hardcoded_secrets')
          .toList();

      expect(
        secretIssues,
        isNotEmpty,
        reason: 'Should have detected the injected AWS key',
      );

      // The generic rule might ALSO match, so we just check if ONE is AWS.
      final awsMatch = secretIssues.any(
        (i) => i.message.contains('AWS credentials'),
      );

      expect(
        awsMatch,
        isTrue,
        reason:
            'Should detect AWS specific rule. '
            'Found: ${secretIssues.map((e) => e.message)}',
      );
    });
  });
}
