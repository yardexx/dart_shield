// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/network/prefer_https_over_http.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferHttpsOverHttpTest);
  });
}

@reflectiveTest
class PreferHttpsOverHttpTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'prefer_https_over_http';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(PreferHttpsOverHttp());
    super.setUp();
  }

  Future<void> test_httpStringLiteral_reports() async {
    await assertDiagnostics(
      '''
void f() {
  final url = 'http://example.com';
}
''',
      [lint(25, 20)],
    );
  }

  Future<void> test_httpsStringLiteral_noReport() async {
    await assertNoDiagnostics('''
void f() {
  final url = 'https://example.com';
}
''');
  }

  Future<void> test_httpWithPath_reports() async {
    await assertDiagnostics(
      '''
void f() {
  final url = 'http://example.com/api/v1';
}
''',
      [lint(25, 27)],
    );
  }

  Future<void> test_emptyString_noReport() async {
    await assertNoDiagnostics('''
void f() {
  final url = '';
}
''');
  }

  Future<void> test_nonUrlString_noReport() async {
    await assertNoDiagnostics('''
void f() {
  final text = 'hello world';
}
''');
  }

  Future<void> test_httpInVariable_reports() async {
    await assertDiagnostics(
      '''
void f() {
  final config = 'http://api.example.com';
}
''',
      [lint(28, 24)],
    );
  }

  Future<void> test_httpLocalhost_reports() async {
    await assertDiagnostics(
      '''
void f() {
  final url = 'http://localhost:8080';
}
''',
      [lint(25, 23)],
    );
  }

  Future<void> test_httpWithPort_reports() async {
    await assertDiagnostics(
      '''
void f() {
  final url = 'http://example.com:3000/api';
}
''',
      [lint(25, 29)],
    );
  }

  Future<void> test_httpInList_reports() async {
    await assertDiagnostics(
      '''
void f() {
  final urls = [
    'http://example.com',
  ];
}
''',
      [lint(32, 20)],
    );
  }

  Future<void> test_httpInMap_reports() async {
    await assertDiagnostics(
      '''
void f() {
  final config = {
    'url': 'http://example.com',
  };
}
''',
      [lint(41, 20)],
    );
  }

  Future<void> test_multipleHttpUrls_reportsEach() async {
    await assertDiagnostics(
      '''
void f() {
  final url1 = 'http://example.com';
  final url2 = 'http://other.com';
}
''',
      [lint(26, 20), lint(63, 18)],
    );
  }
}
