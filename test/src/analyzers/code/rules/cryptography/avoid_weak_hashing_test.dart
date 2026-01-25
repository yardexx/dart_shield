import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/cryptography/avoid_weak_hashing.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidWeakHashingTest);
  });
}

@reflectiveTest
class AvoidWeakHashingTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_weak_hashing';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidWeakHashing());

    // Add stub for crypto package
    newPackage('crypto')..addFile('lib/crypto.dart', r'''
abstract class Hash {
  List<int> convert(List<int> data);
}
final Hash md5 = _Md5();
final Hash sha1 = _Sha1();
final Hash sha256 = _Sha256();
class _Md5 implements Hash { 
  @override
  List<int> convert(List<int> data) => []; 
}
class _Sha1 implements Hash { 
  @override
  List<int> convert(List<int> data) => []; 
}
class _Sha256 implements Hash { 
  @override
  List<int> convert(List<int> data) => []; 
}
''');

    super.setUp();
  }

  Future<void> test_md5Convert_reports() async {
    await assertDiagnostics(
      r'''
import 'package:crypto/crypto.dart';
void f() {
  final hash = md5.convert([1, 2, 3]);
}
''',
      [lint(63, 22)],
    );
  }

  Future<void> test_sha1Convert_reports() async {
    await assertDiagnostics(
      r'''
import 'package:crypto/crypto.dart';
void f() {
  final hash = sha1.convert([1, 2, 3]);
}
''',
      [lint(63, 23)],
    );
  }

  Future<void> test_sha256Convert_noReport() async {
    await assertNoDiagnostics(r'''
import 'package:crypto/crypto.dart';
void f() {
  final hash = sha256.convert([1, 2, 3]);
}
''');
  }

  Future<void> test_md5Assignment_reports() async {
    await assertDiagnostics(
      r'''
import 'package:crypto/crypto.dart';
void f() {
  Hash hasher;
  hasher = md5;
}
''',
      [lint(65, 12)],
    );
  }

  Future<void> test_sha1Assignment_reports() async {
    await assertDiagnostics(
      r'''
import 'package:crypto/crypto.dart';
void f() {
  Hash hasher;
  hasher = sha1;
}
''',
      [lint(65, 13)],
    );
  }

  Future<void> test_sha256Assignment_noReport() async {
    await assertNoDiagnostics(r'''
import 'package:crypto/crypto.dart';
void f() {
  Hash hasher;
  hasher = sha256;
}
''');
  }

  Future<void> test_md5InExpression_reports() async {
    await assertDiagnostics(
      r'''
import 'package:crypto/crypto.dart';
void f() {
  final result = md5.convert([1]).toString();
}
''',
      [lint(65, 16)],
    );
  }

  Future<void> test_unrelatedIdentifier_noReport() async {
    // Identifiers named md5 or sha1 that are not from crypto package
    await assertNoDiagnostics(r'''
void f() {
  final md5 = 'some string';
  print(md5);
}
''');
  }
}
