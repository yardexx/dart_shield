// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/network/avoid_certificate_pinning_bypass.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidCertificatePinningBypassTest);
  });
}

@reflectiveTest
class AvoidCertificatePinningBypassTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_certificate_pinning_bypass';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidCertificatePinningBypass());

    // Add stub for dart:io HttpClient
    newPackage('io_stub').addFile('lib/io_stub.dart', '''
class HttpClient {
  bool Function(dynamic cert, String host, int port)? badCertificateCallback;
}
''');

    super.setUp();
  }

  // ==================== badCertificateCallback returning true ====================

  Future<void> test_badCertificateCallbackReturnsTrue_reports() async {
    await assertDiagnostics(
      '''
import 'package:io_stub/io_stub.dart';
void f() {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;
}
''',
      [lint(83, 58)],
    );
  }

  Future<void> test_badCertificateCallbackWithPropertyAccess_reports() async {
    await assertDiagnostics(
      '''
import 'package:io_stub/io_stub.dart';
void f(HttpClient client) {
  client.badCertificateCallback = (cert, host, port) => true;
}
''',
      [lint(69, 58)],
    );
  }

  // ==================== badCertificateCallback NOT returning true unconditionally ====================

  Future<void> test_badCertificateCallbackReturnsFalse_noReport() async {
    await assertNoDiagnostics('''
import 'package:io_stub/io_stub.dart';
void f() {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => false;
}
''');
  }

  Future<void> test_badCertificateCallbackReturnsVariable_noReport() async {
    await assertNoDiagnostics('''
import 'package:io_stub/io_stub.dart';
void f(bool allowInsecure) {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => allowInsecure;
}
''');
  }

  Future<void> test_badCertificateCallbackReturnsExpression_noReport() async {
    await assertNoDiagnostics('''
import 'package:io_stub/io_stub.dart';
void f() {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => host == 'localhost';
}
''');
  }

  Future<void> test_badCertificateCallbackWithBlockBody_noReport() async {
    // Block body functions are not detected (only expression body with literal true)
    await assertNoDiagnostics('''
import 'package:io_stub/io_stub.dart';
void f() {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) {
    return true;
  };
}
''');
  }

  Future<void> test_badCertificateCallbackNull_noReport() async {
    await assertNoDiagnostics('''
import 'package:io_stub/io_stub.dart';
void f() {
  final client = HttpClient();
  client.badCertificateCallback = null;
}
''');
  }

  // ==================== Other property assignments - no report ====================

  Future<void> test_otherPropertyAssignment_noReport() async {
    await assertNoDiagnostics('''
class Config {
  bool Function()? callback;
}
void f() {
  final config = Config();
  config.callback = () => true;
}
''');
  }

  Future<void> test_differentCallbackName_noReport() async {
    await assertNoDiagnostics('''
class Client {
  bool Function()? onError;
}
void f() {
  final client = Client();
  client.onError = () => true;
}
''');
  }
}
