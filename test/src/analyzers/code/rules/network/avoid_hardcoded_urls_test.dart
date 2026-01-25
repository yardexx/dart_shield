import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/network/avoid_harcoded_urls.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidHardcodedUrlsTest);
  });
}

@reflectiveTest
class AvoidHardcodedUrlsTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_hardcoded_urls';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidHardcodedUrls());
    super.setUp();
  }

  Future<void> test_httpsUrl_reports() async {
    await assertDiagnostics(
      r'''
void f() {
  final url = 'https://api.example.com/v1';
}
''',
      [lint(25, 28)],
    );
  }

  Future<void> test_httpUrl_reports() async {
    await assertDiagnostics(
      r'''
void f() {
  final url = 'http://api.example.com';
}
''',
      [lint(25, 24)],
    );
  }

  Future<void> test_emptyString_noReport() async {
    await assertNoDiagnostics(r'''
void f() {
  final url = '';
}
''');
  }

  Future<void> test_nonUrlString_noReport() async {
    await assertNoDiagnostics(r'''
void f() {
  final text = 'hello world';
}
''');
  }

  Future<void> test_localhostUrl_reports() async {
    await assertDiagnostics(
      r'''
void f() {
  final url = 'http://localhost:8080/api';
}
''',
      [lint(25, 27)],
    );
  }

  Future<void> test_httpsWithQueryParams_reports() async {
    await assertDiagnostics(
      r'''
void f() {
  final url = 'https://api.example.com/search?q=test';
}
''',
      [lint(25, 39)],
    );
  }

  Future<void> test_multipleUrls_reportsEach() async {
    await assertDiagnostics(
      r'''
void f() {
  final url1 = 'https://api.example.com';
  final url2 = 'http://other.example.com';
}
''',
      [lint(26, 25), lint(68, 26)],
    );
  }

  Future<void> test_urlInClassField_reports() async {
    await assertDiagnostics(
      r'''
class Config {
  final baseUrl = 'https://api.example.com';
}
''',
      [lint(33, 25)],
    );
  }

  Future<void> test_urlInConstant_reports() async {
    await assertDiagnostics(
      r'''
const apiUrl = 'https://api.example.com/v1';
''',
      [lint(15, 28)],
    );
  }

  Future<void> test_partialUrl_noReport() async {
    await assertNoDiagnostics(r'''
void f() {
  final path = '/api/v1/users';
}
''');
  }
}
