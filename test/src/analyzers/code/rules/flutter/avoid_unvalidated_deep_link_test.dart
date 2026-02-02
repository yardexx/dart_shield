// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/flutter/avoid_unvalidated_deep_link.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnvalidatedDeepLinkTest);
  });
}

@reflectiveTest
class AvoidUnvalidatedDeepLinkTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_unvalidated_deep_link';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidUnvalidatedDeepLink());

    // Add stub for app_links package
    newPackage('app_links').addFile('lib/app_links.dart', '''
class AppLinks {
  Future<Uri?> getInitialLink() async => null;
  Future<Uri?> getLatestLink() async => null;
  Future<Uri?> getInitialUri() async => null;
  Future<Uri?> getLatestUri() async => null;
  Stream<Uri> get uriLinkStream => Stream.empty();
}
''');

    // Add stub for uni_links package
    newPackage('uni_links').addFile('lib/uni_links.dart', '''
Future<String?> getInitialLink() async => null;
Future<Uri?> getInitialUri() async => null;
Stream<String?> get linkStream => Stream.empty();
Stream<Uri?> get uriLinkStream => Stream.empty();
''');

    super.setUp();
  }

  Future<void> test_getInitialLink_reports() async {
    await assertDiagnostics(
      '''
import 'package:app_links/app_links.dart';
void f() async {
  final appLinks = AppLinks();
  final link = await appLinks.getInitialLink();
}
''',
      [lint(112, 25)],
    );
  }

  Future<void> test_getLatestLink_reports() async {
    await assertDiagnostics(
      '''
import 'package:app_links/app_links.dart';
void f() async {
  final appLinks = AppLinks();
  final link = await appLinks.getLatestLink();
}
''',
      [lint(112, 24)],
    );
  }

  Future<void> test_getInitialUri_reports() async {
    await assertDiagnostics(
      '''
import 'package:app_links/app_links.dart';
void f() async {
  final appLinks = AppLinks();
  final uri = await appLinks.getInitialUri();
}
''',
      [lint(111, 24)],
    );
  }

  Future<void> test_getLatestUri_reports() async {
    await assertDiagnostics(
      '''
import 'package:app_links/app_links.dart';
void f() async {
  final appLinks = AppLinks();
  final uri = await appLinks.getLatestUri();
}
''',
      [lint(111, 23)],
    );
  }

  Future<void> test_uniLinksGetInitialLink_reports() async {
    await assertDiagnostics(
      '''
import 'package:uni_links/uni_links.dart' as uni;
void f() async {
  final link = await uni.getInitialLink();
}
''',
      [lint(88, 20)],
    );
  }

  Future<void> test_uniLinksGetInitialUri_reports() async {
    await assertDiagnostics(
      '''
import 'package:uni_links/uni_links.dart' as uni;
void f() async {
  final uri = await uni.getInitialUri();
}
''',
      [lint(87, 19)],
    );
  }

  Future<void> test_unrelatedMethodCall_noReport() async {
    await assertNoDiagnostics('''
class MyClass {
  String getInitialValue() => 'value';
}
void f() {
  final obj = MyClass();
  final value = obj.getInitialValue();
}
''');
  }

  Future<void> test_streamAccess_noReport() async {
    // Stream access is not currently flagged (different pattern)
    await assertNoDiagnostics('''
import 'package:app_links/app_links.dart';
void f() {
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) {
    print(uri);
  });
}
''');
  }
}
