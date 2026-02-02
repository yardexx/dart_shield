// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/auth/avoid_empty_catch.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidEmptyCatchTest);
  });
}

@reflectiveTest
class AvoidEmptyCatchTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_empty_catch';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidEmptyCatch());
    super.setUp();
  }

  // ==================== Empty catch blocks ====================

  Future<void> test_emptyCatchBlock_reports() async {
    await assertDiagnostics(
      '''
void f() {
  try {
    throw Exception();
  } catch (e) {
  }
}
''',
      [lint(46, 15)],
    );
  }

  Future<void> test_emptyCatchBlockOnSpecificType_reports() async {
    await assertDiagnostics(
      '''
void f() {
  try {
    throw FormatException();
  } on FormatException {
  }
}
''',
      [lint(52, 24)],
    );
  }

  Future<void> test_multipleCatchesOneEmpty_reports() async {
    await assertDiagnostics(
      '''
void f() {
  try {
    throw Exception();
  } on FormatException catch (e) {
    print(e);
  } catch (e) {
  }
}
''',
      [lint(95, 15)],
    );
  }

  // ==================== Catch with only empty statement ====================

  Future<void> test_catchWithOnlyEmptyStatement_reports() async {
    await assertDiagnostics(
      '''
void f() {
  try {
    throw Exception();
  } catch (e) {
    ;
  }
}
''',
      [lint(46, 21)],
    );
  }

  // ==================== Catch with only identifier (no effect) ====================

  Future<void> test_catchWithOnlyIdentifier_reports() async {
    await assertDiagnostics(
      '''
void f() {
  try {
    throw Exception();
  } catch (e) {
    e;
  }
}
''',
      [lint(46, 22)],
    );
  }

  // ==================== Valid catch blocks (no report) ====================

  Future<void> test_catchWithRethrow_noReport() async {
    await assertNoDiagnostics('''
void f() {
  try {
    throw Exception();
  } catch (e) {
    rethrow;
  }
}
''');
  }

  Future<void> test_catchWithThrow_noReport() async {
    await assertNoDiagnostics(r'''
void f() {
  try {
    throw Exception();
  } catch (e) {
    throw Exception('Wrapped: $e');
  }
}
''');
  }

  Future<void> test_catchWithPrint_noReport() async {
    await assertNoDiagnostics('''
void f() {
  try {
    throw Exception();
  } catch (e) {
    print(e);
  }
}
''');
  }

  Future<void> test_catchWithMethodCall_noReport() async {
    await assertNoDiagnostics('''
void log(Object e) {}
void f() {
  try {
    throw Exception();
  } catch (e) {
    log(e);
  }
}
''');
  }

  Future<void> test_catchWithReturn_noReport() async {
    await assertNoDiagnostics('''
int f() {
  try {
    int.parse('abc');
  } catch (e) {
    return -1;
  }
  return 0;
}
''');
  }

  Future<void> test_catchWithAssignment_noReport() async {
    await assertNoDiagnostics('''
void f() {
  Object? lastError;
  try {
    throw Exception();
  } catch (e) {
    lastError = e;
  }
  print(lastError);
}
''');
  }

  Future<void> test_catchWithVariableDeclaration_noReport() async {
    await assertNoDiagnostics('''
void f() {
  try {
    throw Exception();
  } catch (e) {
    final message = e.toString();
    print(message);
  }
}
''');
  }

  Future<void> test_catchWithIfStatement_noReport() async {
    await assertNoDiagnostics('''
void f() {
  try {
    throw Exception();
  } catch (e) {
    if (e is FormatException) {
      print('Format error');
    }
  }
}
''');
  }

  Future<void> test_catchWithBlock_noReport() async {
    await assertNoDiagnostics('''
void f() {
  try {
    throw Exception();
  } catch (e) {
    {
      print(e);
    }
  }
}
''');
  }

  Future<void> test_catchWithFunctionExpressionInvocation_noReport() async {
    await assertNoDiagnostics('''
void f() {
  final handler = (Object e) => print(e);
  try {
    throw Exception();
  } catch (e) {
    handler(e);
  }
}
''');
  }

  // ==================== Nested try-catch ====================

  Future<void> test_nestedTryCatch_innerEmpty_reports() async {
    await assertDiagnostics(
      '''
void f() {
  try {
    try {
      throw Exception();
    } catch (e) {
    }
  } catch (e) {
    print(e);
  }
}
''',
      [lint(60, 17)],
    );
  }

  Future<void> test_nestedTryCatch_outerEmpty_reports() async {
    await assertDiagnostics(
      '''
void f() {
  try {
    try {
      throw Exception();
    } catch (e) {
      print(e);
    }
  } catch (e) {
  }
}
''',
      [lint(98, 15)],
    );
  }

  // ==================== Async/await context ====================

  Future<void> test_asyncFunctionEmptyCatch_reports() async {
    await assertDiagnostics(
      '''
Future<void> f() async {
  try {
    await Future.error('error');
  } catch (e) {
  }
}
''',
      [lint(70, 15)],
    );
  }

  Future<void> test_asyncFunctionCatchWithAwait_noReport() async {
    await assertNoDiagnostics('''
Future<void> logError(Object e) async {}
Future<void> f() async {
  try {
    await Future.error('error');
  } catch (e) {
    await logError(e);
  }
}
''');
  }
}
