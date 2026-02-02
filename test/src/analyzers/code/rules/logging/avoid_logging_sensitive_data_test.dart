// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/logging/avoid_logging_sensitive_data.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidLoggingSensitiveDataTest);
  });
}

@reflectiveTest
class AvoidLoggingSensitiveDataTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_logging_sensitive_data';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidLoggingSensitiveData());
    super.setUp();
  }

  // ==================== print() with sensitive variables ====================

  Future<void> test_printPassword_reports() async {
    await assertDiagnostics(
      '''
void f(String password) {
  print(password);
}
''',
      [lint(28, 15)],
    );
  }

  Future<void> test_printToken_reports() async {
    await assertDiagnostics(
      '''
void f(String token) {
  print(token);
}
''',
      [lint(25, 12)],
    );
  }

  Future<void> test_printSecret_reports() async {
    await assertDiagnostics(
      '''
void f(String secret) {
  print(secret);
}
''',
      [lint(26, 13)],
    );
  }

  Future<void> test_printApiKey_reports() async {
    await assertDiagnostics(
      '''
void f(String apiKey) {
  print(apiKey);
}
''',
      [lint(26, 13)],
    );
  }

  Future<void> test_printCredential_reports() async {
    await assertDiagnostics(
      '''
void f(String credential) {
  print(credential);
}
''',
      [lint(30, 17)],
    );
  }

  Future<void> test_printPrivateKey_reports() async {
    await assertDiagnostics(
      '''
void f(String privateKey) {
  print(privateKey);
}
''',
      [lint(30, 17)],
    );
  }

  Future<void> test_printAccessToken_reports() async {
    await assertDiagnostics(
      '''
void f(String accessToken) {
  print(accessToken);
}
''',
      [lint(31, 18)],
    );
  }

  Future<void> test_printAuthToken_reports() async {
    await assertDiagnostics(
      '''
void f(String authToken) {
  print(authToken);
}
''',
      [lint(29, 16)],
    );
  }

  // ==================== Logger methods with sensitive variables ====================

  Future<void> test_loggerInfoPassword_reports() async {
    await assertDiagnostics(
      '''
class Logger {
  void info(String message) {}
}
void f(Logger logger, String password) {
  logger.info(password);
}
''',
      [lint(91, 21)],
    );
  }

  Future<void> test_loggerDebugToken_reports() async {
    await assertDiagnostics(
      '''
class Logger {
  void debug(String message) {}
}
void f(Logger logger, String token) {
  logger.debug(token);
}
''',
      [lint(89, 19)],
    );
  }

  Future<void> test_loggerWarningSecret_reports() async {
    await assertDiagnostics(
      '''
class Logger {
  void warning(String message) {}
}
void f(Logger logger, String secret) {
  logger.warning(secret);
}
''',
      [lint(92, 22)],
    );
  }

  Future<void> test_loggerErrorCredential_reports() async {
    await assertDiagnostics(
      '''
class Logger {
  void error(String message) {}
}
void f(Logger logger, String credential) {
  logger.error(credential);
}
''',
      [lint(94, 24)],
    );
  }

  // ==================== Non-sensitive variables - no report ====================

  Future<void> test_printNormalString_noReport() async {
    await assertNoDiagnostics('''
void f(String message) {
  print(message);
}
''');
  }

  Future<void> test_printUsername_noReport() async {
    await assertNoDiagnostics('''
void f(String username) {
  print(username);
}
''');
  }

  Future<void> test_printEmail_noReport() async {
    await assertNoDiagnostics('''
void f(String email) {
  print(email);
}
''');
  }

  Future<void> test_printId_noReport() async {
    await assertNoDiagnostics('''
void f(String id) {
  print(id);
}
''');
  }

  // ==================== String literals (not variable names) - no report ====================

  Future<void> test_printStringLiteralWithPassword_noReport() async {
    await assertNoDiagnostics('''
void f() {
  print('Password is required');
}
''');
  }

  // ==================== Non-logging methods - no report ====================

  Future<void> test_processPassword_noReport() async {
    await assertNoDiagnostics('''
void process(String data) {}
void f(String password) {
  process(password);
}
''');
  }

  Future<void> test_hashPassword_noReport() async {
    await assertNoDiagnostics('''
void hash(String data) {}
void f(String password) {
  hash(password);
}
''');
  }

  // ==================== Case variations ====================

  Future<void> test_printUserPassword_reports() async {
    await assertDiagnostics(
      '''
void f(String userPassword) {
  print(userPassword);
}
''',
      [lint(32, 19)],
    );
  }
}
