// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/cryptography/prefer_secure_random.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferSecureRandomTest);
  });
}

@reflectiveTest
class PreferSecureRandomTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'prefer_secure_random';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(PreferSecureRandom());
    super.setUp();
  }

  Future<void> test_randomConstructor_reports() async {
    await assertDiagnostics(
      '''
import 'dart:math';
void f() {
  final rng = Random();
}
''',
      [lint(45, 8)],
    );
  }

  Future<void> test_randomWithSeed_reports() async {
    await assertDiagnostics(
      '''
import 'dart:math';
void f() {
  final rng = Random(42);
}
''',
      [lint(45, 10)],
    );
  }

  Future<void> test_randomInClassField_reports() async {
    await assertDiagnostics(
      '''
import 'dart:math';
class MyClass {
  final rng = Random();
}
''',
      [lint(50, 8)],
    );
  }

  Future<void> test_randomInFunction_reports() async {
    await assertDiagnostics(
      '''
import 'dart:math';
int getRandomNumber() {
  return Random().nextInt(100);
}
''',
      [lint(53, 8)],
    );
  }

  Future<void> test_multipleRandomInstances_reportsEach() async {
    await assertDiagnostics(
      '''
import 'dart:math';
void f() {
  final rng1 = Random();
  final rng2 = Random(123);
}
''',
      [lint(46, 8), lint(71, 11)],
    );
  }

  Future<void> test_randomWithVariableSeed_reports() async {
    await assertDiagnostics(
      '''
import 'dart:math';
void f(int seed) {
  final rng = Random(seed);
}
''',
      [lint(53, 12)],
    );
  }

  Future<void> test_randomWithTimestampSeed_reports() async {
    await assertDiagnostics(
      '''
import 'dart:math';
void f() {
  final rng = Random(DateTime.now().millisecondsSinceEpoch);
}
''',
      [lint(45, 45)],
    );
  }
}
