// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/secrets/avoid_hardcoded_secrets.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidHardcodedSecretsTest);
  });
}

@reflectiveTest
class AvoidHardcodedSecretsTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_hardcoded_secrets';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidHardcodedSecrets());
    super.setUp();
  }

  Future<void> test_awsAccessKey_reports() async {
    // AWS access keys start with AKIA and are 20 chars
    await assertDiagnostics(
      '''
void f() {
  final key = 'AKIAIOSFODNN7EXAMPLE';
}
''',
      [lint(25, 22)],
    );
  }

  Future<void> test_githubToken_reports() async {
    await assertDiagnostics(
      '''
void f() {
  final token = 'ghp_aBcDeFgHiJkLmNoPqRsTuVwXyZ012345';
}
''',
      [lint(27, 38)],
    );
  }

  Future<void> test_shortString_noReport() async {
    await assertNoDiagnostics('''
void f() {
  final s = 'short';
}
''');
  }

  Future<void> test_lowEntropyString_noReport() async {
    await assertNoDiagnostics('''
void f() {
  final s = 'aaaaaaaaaaaaaaaa';
}
''');
  }

  Future<void> test_contextVariableName_detects() async {
    // Tests that apiKey variable name triggers keyword check with Stripe
    // pattern
    await assertDiagnostics(
      '''
void f() {
  final apiKey = 'sk_live_abcdefghijklmnop';
}
''',
      [lint(28, 26)],
    );
  }

  Future<void> test_mapKeyContext_detects() async {
    await assertDiagnostics(
      '''
void f() {
  final config = {
    'apiKey': 'sk_test_1234567890abcdef',
  };
}
''',
      [lint(44, 26)],
    );
  }

  // Note: Slack token test removed to avoid GitHub push protection
  // false positives. The xoxb- pattern is still tested in integration tests
  // with real project scans.

  Future<void> test_genericApiKeyPattern_reports() async {
    // Generic API key with sufficient entropy
    await assertDiagnostics(
      '''
void f() {
  final apiKey = 'api_key_xK9mN2pL5qR8vW3yZ1aB4cD7eF0gH';
}
''',
      [lint(28, 39)],
    );
  }

  Future<void> test_regularString_noReport() async {
    await assertNoDiagnostics('''
void f() {
  final message = 'Hello, World!';
}
''');
  }

  Future<void> test_emptyString_noReport() async {
    await assertNoDiagnostics('''
void f() {
  final s = '';
}
''');
  }

  Future<void> test_namedParameterContext_detects() async {
    await assertDiagnostics(
      '''
void configure({required String apiKey}) {}
void f() {
  configure(apiKey: 'sk_live_abc123def456ghi789');
}
''',
      [lint(75, 28)],
    );
  }

  Future<void> test_jwtToken_reports() async {
    // JWT tokens have distinctive patterns
    await assertDiagnostics(
      '''
void f() {
  final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
}
''',
      [lint(27, 157)],
    );
  }
}
