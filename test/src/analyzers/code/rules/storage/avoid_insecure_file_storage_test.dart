// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/storage/avoid_insecure_file_storage.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidInsecureFileStorageTest);
  });
}

@reflectiveTest
class AvoidInsecureFileStorageTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_insecure_file_storage';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidInsecureFileStorage());

    // Add stub for dart:io File
    newPackage('io_stub').addFile('lib/io_stub.dart', '''
class File {
  File(String path);
  Future<File> writeAsString(String contents) async => this;
  void writeAsStringSync(String contents) {}
}
''');

    super.setUp();
  }

  // ==================== Files with "password" in path ====================

  Future<void> test_fileWithPasswordInPath_reports() async {
    await assertDiagnostics(
      '''
import 'package:io_stub/io_stub.dart';
void f() {
  final file = File('passwords.txt');
}
''',
      [lint(65, 21)],
    );
  }

  Future<void> test_fileWithUserPassword_reports() async {
    await assertDiagnostics(
      '''
import 'package:io_stub/io_stub.dart';
void f() {
  final file = File('user_password.json');
}
''',
      [lint(65, 26)],
    );
  }

  // ==================== Files with "secret" in path ====================

  Future<void> test_fileWithSecretInPath_reports() async {
    await assertDiagnostics(
      '''
import 'package:io_stub/io_stub.dart';
void f() {
  final file = File('secrets.json');
}
''',
      [lint(65, 20)],
    );
  }

  // ==================== Files with "credential" in path ====================

  Future<void> test_fileWithCredentialInPath_reports() async {
    await assertDiagnostics(
      '''
import 'package:io_stub/io_stub.dart';
void f() {
  final file = File('credentials.json');
}
''',
      [lint(65, 24)],
    );
  }

  // ==================== Files with "token" in path ====================

  Future<void> test_fileWithTokenInPath_reports() async {
    await assertDiagnostics(
      '''
import 'package:io_stub/io_stub.dart';
void f() {
  final file = File('tokens.dat');
}
''',
      [lint(65, 18)],
    );
  }

  // ==================== Files with "key" in path ====================

  Future<void> test_fileWithKeyInPath_reports() async {
    await assertDiagnostics(
      '''
import 'package:io_stub/io_stub.dart';
void f() {
  final file = File('api_key.txt');
}
''',
      [lint(65, 19)],
    );
  }

  // ==================== Files with "private" in path ====================

  Future<void> test_fileWithPrivateInPath_reports() async {
    await assertDiagnostics(
      '''
import 'package:io_stub/io_stub.dart';
void f() {
  final file = File('private_data.json');
}
''',
      [lint(65, 25)],
    );
  }

  // ==================== Files with "auth" in path ====================

  Future<void> test_fileWithAuthInPath_reports() async {
    await assertDiagnostics(
      '''
import 'package:io_stub/io_stub.dart';
void f() {
  final file = File('auth.json');
}
''',
      [lint(65, 17)],
    );
  }

  // ==================== Non-sensitive file paths - no report ====================

  Future<void> test_fileWithNormalName_noReport() async {
    await assertNoDiagnostics('''
import 'package:io_stub/io_stub.dart';
void f() {
  final file = File('config.json');
}
''');
  }

  Future<void> test_fileWithDataName_noReport() async {
    await assertNoDiagnostics('''
import 'package:io_stub/io_stub.dart';
void f() {
  final file = File('/data/users.txt');
}
''');
  }

  Future<void> test_fileWithLogName_noReport() async {
    await assertNoDiagnostics('''
import 'package:io_stub/io_stub.dart';
void f() {
  final file = File('app.log');
}
''');
  }

  // ==================== Variable paths (not string literals) - no report ====================

  Future<void> test_fileWithVariablePath_noReport() async {
    await assertNoDiagnostics('''
import 'package:io_stub/io_stub.dart';
void f(String path) {
  final file = File(path);
}
''');
  }

  // ==================== Non-File classes - no report ====================

  Future<void> test_nonFileClassWithSensitivePath_noReport() async {
    await assertNoDiagnostics('''
class Config {
  Config(String path);
}
void f() {
  final config = Config('passwords.txt');
}
''');
  }
}
