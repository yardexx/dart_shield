// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/storage/avoid_shared_preferences_for_secrets.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidSharedPreferencesForSecretsTest);
  });
}

@reflectiveTest
class AvoidSharedPreferencesForSecretsTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_shared_preferences_for_secrets';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidSharedPreferencesForSecrets());

    // Add stub for shared_preferences package
    newPackage('shared_preferences').addFile('lib/shared_preferences.dart', '''
class SharedPreferences {
  static Future<SharedPreferences> getInstance() async {
    return SharedPreferences._();
  }
  SharedPreferences._();
  
  Future<bool> setString(String key, String value) async => true;
  Future<bool> setInt(String key, int value) async => true;
  Future<bool> setBool(String key, bool value) async => true;
  
  String? getString(String key) => null;
  int? getInt(String key) => null;
}
''');

    super.setUp();
  }

  // ==================== setString with sensitive keys ====================

  Future<void> test_setStringWithPasswordKey_reports() async {
    await assertDiagnostics(
      '''
import 'package:shared_preferences/shared_preferences.dart';
Future<void> f() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('password', 'secret123');
}
''',
      [lint(149, 40)],
    );
  }

  Future<void> test_setStringWithTokenKey_reports() async {
    await assertDiagnostics(
      '''
import 'package:shared_preferences/shared_preferences.dart';
Future<void> f() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', 'abc123');
}
''',
      [lint(149, 34)],
    );
  }

  Future<void> test_setStringWithSecretKey_reports() async {
    await assertDiagnostics(
      '''
import 'package:shared_preferences/shared_preferences.dart';
Future<void> f() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('secret', 'mySecret');
}
''',
      [lint(149, 37)],
    );
  }

  Future<void> test_setStringWithApiKeyKey_reports() async {
    await assertDiagnostics(
      '''
import 'package:shared_preferences/shared_preferences.dart';
Future<void> f() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('apikey', 'key123');
}
''',
      [lint(149, 35)],
    );
  }

  Future<void> test_setStringWithCredentialKey_reports() async {
    await assertDiagnostics(
      '''
import 'package:shared_preferences/shared_preferences.dart';
Future<void> f() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('credential', 'cred123');
}
''',
      [lint(149, 40)],
    );
  }

  Future<void> test_setStringWithAuthKey_reports() async {
    await assertDiagnostics(
      '''
import 'package:shared_preferences/shared_preferences.dart';
Future<void> f() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth', 'auth123');
}
''',
      [lint(149, 34)],
    );
  }

  Future<void> test_setStringWithAccessTokenKey_reports() async {
    await assertDiagnostics(
      '''
import 'package:shared_preferences/shared_preferences.dart';
Future<void> f() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('accesstoken', 'token123');
}
''',
      [lint(149, 42)],
    );
  }

  // ==================== Non-sensitive keys - no report ====================

  Future<void> test_setStringWithUsernameKey_noReport() async {
    await assertNoDiagnostics('''
import 'package:shared_preferences/shared_preferences.dart';
Future<void> f() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', 'john');
}
''');
  }

  Future<void> test_setStringWithThemeKey_noReport() async {
    await assertNoDiagnostics('''
import 'package:shared_preferences/shared_preferences.dart';
Future<void> f() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('theme', 'dark');
}
''');
  }

  Future<void> test_setIntWithCounterKey_noReport() async {
    await assertNoDiagnostics('''
import 'package:shared_preferences/shared_preferences.dart';
Future<void> f() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('counter', 42);
}
''');
  }

  // ==================== Get methods - no report ====================

  Future<void> test_getStringWithPasswordKey_noReport() async {
    await assertNoDiagnostics('''
import 'package:shared_preferences/shared_preferences.dart';
Future<void> f() async {
  final prefs = await SharedPreferences.getInstance();
  final password = prefs.getString('password');
}
''');
  }

  // ==================== Non-SharedPreferences classes - no report ====================

  Future<void> test_otherClassSetStringWithPasswordKey_noReport() async {
    await assertNoDiagnostics('''
class MyPrefs {
  void setString(String key, String value) {}
}
void f(MyPrefs prefs) {
  prefs.setString('password', 'secret123');
}
''');
  }

  // ==================== Variable keys (not string literals) - no report ====================

  Future<void> test_setStringWithVariableKey_noReport() async {
    await assertNoDiagnostics('''
import 'package:shared_preferences/shared_preferences.dart';
Future<void> f(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, 'value');
}
''');
  }
}
