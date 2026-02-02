// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/flutter/avoid_webview_javascript_bridge.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidWebviewJavascriptBridgeTest);
  });
}

@reflectiveTest
class AvoidWebviewJavascriptBridgeTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_webview_javascript_bridge';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidWebviewJavascriptBridge());

    // Add stub for webview_flutter package
    newPackage('webview_flutter').addFile('lib/webview_flutter.dart', '''
typedef JavaScriptMessageHandler = void Function(JavaScriptMessage message);

class JavaScriptMessage {
  final String message;
  JavaScriptMessage(this.message);
}

class WebViewController {
  Future<void> addJavaScriptChannel(
    String name, {
    required JavaScriptMessageHandler onMessageReceived,
  }) async {}
}
''');

    super.setUp();
  }

  Future<void> test_addJavaScriptChannelWithTokenName_reports() async {
    await assertDiagnostics(
      '''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  controller.addJavaScriptChannel(
    'userToken',
    onMessageReceived: (msg) => print(msg),
  );
}
''',
      [lint(96, 97)],
    );
  }

  Future<void> test_addJavaScriptChannelWithPasswordName_reports() async {
    await assertDiagnostics(
      '''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  controller.addJavaScriptChannel(
    'passwordHandler',
    onMessageReceived: (msg) => print(msg),
  );
}
''',
      [lint(96, 103)],
    );
  }

  Future<void> test_addJavaScriptChannelWithCredentialName_reports() async {
    await assertDiagnostics(
      '''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  controller.addJavaScriptChannel(
    'credentialBridge',
    onMessageReceived: (msg) => print(msg),
  );
}
''',
      [lint(96, 104)],
    );
  }

  Future<void> test_addJavaScriptChannelWithAuthName_reports() async {
    await assertDiagnostics(
      '''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  controller.addJavaScriptChannel(
    'authChannel',
    onMessageReceived: (msg) => print(msg),
  );
}
''',
      [lint(96, 99)],
    );
  }

  Future<void> test_addJavaScriptChannelWithSecretName_reports() async {
    await assertDiagnostics(
      '''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  controller.addJavaScriptChannel(
    'secretData',
    onMessageReceived: (msg) => print(msg),
  );
}
''',
      [lint(96, 98)],
    );
  }

  Future<void> test_addJavaScriptChannelWithPrivateName_reports() async {
    await assertDiagnostics(
      '''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  controller.addJavaScriptChannel(
    'privateInfo',
    onMessageReceived: (msg) => print(msg),
  );
}
''',
      [lint(96, 99)],
    );
  }

  Future<void> test_addJavaScriptChannelWithKeyName_reports() async {
    await assertDiagnostics(
      '''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  controller.addJavaScriptChannel(
    'apiKeyChannel',
    onMessageReceived: (msg) => print(msg),
  );
}
''',
      [lint(96, 101)],
    );
  }

  Future<void> test_addJavaScriptChannelWithSafeName_noReport() async {
    await assertNoDiagnostics('''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  controller.addJavaScriptChannel(
    'messageHandler',
    onMessageReceived: (msg) => print(msg),
  );
}
''');
  }

  Future<void> test_addJavaScriptChannelWithNavigationName_noReport() async {
    await assertNoDiagnostics('''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  controller.addJavaScriptChannel(
    'navigationBridge',
    onMessageReceived: (msg) => print(msg),
  );
}
''');
  }

  Future<void> test_addJavaScriptChannelWithUiName_noReport() async {
    await assertNoDiagnostics('''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  controller.addJavaScriptChannel(
    'uiCallbacks',
    onMessageReceived: (msg) => print(msg),
  );
}
''');
  }

  Future<void> test_unrelatedMethodWithSafeName_noReport() async {
    // Custom class with addJavaScriptChannel method using a safe name
    await assertNoDiagnostics('''
class MyClass {
  void addJavaScriptChannel(String name) {}
}
void f() {
  final obj = MyClass();
  obj.addJavaScriptChannel('messageHandler');
}
''');
  }

  Future<void> test_addJavaScriptChannelCaseInsensitive_reports() async {
    await assertDiagnostics(
      '''
import 'package:webview_flutter/webview_flutter.dart';
void f(WebViewController controller) {
  controller.addJavaScriptChannel(
    'UserTOKEN',
    onMessageReceived: (msg) => print(msg),
  );
}
''',
      [lint(96, 97)],
    );
  }
}
