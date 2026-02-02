// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/flutter/avoid_insecure_webview_settings.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidInsecureWebviewSettingsTest);
  });
}

@reflectiveTest
class AvoidInsecureWebviewSettingsTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_insecure_webview_settings';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidInsecureWebviewSettings());

    // Add stub for webview_flutter package
    newPackage('webview_flutter').addFile('lib/webview_flutter.dart', '''
enum JavaScriptMode {
  disabled,
  unrestricted,
}

class WebViewController {
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
}

class WebViewWidget {
  WebViewWidget({
    required WebViewController controller,
    JavaScriptMode? javaScriptMode,
  });
}

class WebView {
  WebView({
    String? initialUrl,
    JavaScriptMode? javascriptMode,
  });
}
''');

    super.setUp();
  }

  Future<void> test_webViewWithUnrestrictedJs_reports() async {
    await assertDiagnostics(
      '''
import 'package:webview_flutter/webview_flutter.dart';
void f() {
  final webview = WebView(
    initialUrl: 'https://example.com',
    javascriptMode: JavaScriptMode.unrestricted,
  );
}
''',
      [lint(84, 100)],
    );
  }

  Future<void> test_webViewWithDisabledJs_noReport() async {
    await assertNoDiagnostics('''
import 'package:webview_flutter/webview_flutter.dart';
void f() {
  final webview = WebView(
    initialUrl: 'https://example.com',
    javascriptMode: JavaScriptMode.disabled,
  );
}
''');
  }

  Future<void> test_webViewWithoutJsMode_noReport() async {
    await assertNoDiagnostics('''
import 'package:webview_flutter/webview_flutter.dart';
void f() {
  final webview = WebView(
    initialUrl: 'https://example.com',
  );
}
''');
  }

  Future<void> test_webViewWidgetWithUnrestrictedJs_reports() async {
    await assertDiagnostics(
      '''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  final widget = WebViewWidget(
    controller: controller,
    javaScriptMode: JavaScriptMode.unrestricted,
  );
}
''',
      [lint(111, 95)],
    );
  }

  Future<void> test_webViewWidgetWithDisabledJs_noReport() async {
    await assertNoDiagnostics('''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  final widget = WebViewWidget(
    controller: controller,
    javaScriptMode: JavaScriptMode.disabled,
  );
}
''');
  }

  Future<void> test_webViewWidgetWithoutJsMode_noReport() async {
    await assertNoDiagnostics('''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  final widget = WebViewWidget(
    controller: controller,
  );
}
''');
  }

  Future<void> test_unrelatedInstanceCreation_noReport() async {
    await assertNoDiagnostics('''
class MyWidget {
  MyWidget({String? javascriptMode});
}
void f() {
  final widget = MyWidget(
    javascriptMode: 'unrestricted',
  );
}
''');
  }
}
