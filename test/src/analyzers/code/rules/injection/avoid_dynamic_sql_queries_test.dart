// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/injection/avoid_dynamic_sql_queries.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidDynamicSqlQueriesTest);
  });
}

@reflectiveTest
class AvoidDynamicSqlQueriesTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_dynamic_sql_queries';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidDynamicSqlQueries());
    super.setUp();
  }

  // ==================== SELECT queries with interpolation ====================

  Future<void> test_selectWithInterpolation_reports() async {
    await assertDiagnostics(
      r'''
void f(String userId) {
  final query = 'SELECT * FROM users WHERE id = $userId';
}
''',
      [lint(40, 40)],
    );
  }

  Future<void> test_selectWithExpressionInterpolation_reports() async {
    await assertDiagnostics(
      r'''
void f(int id) {
  final query = 'SELECT * FROM users WHERE id = ${id.toString()}';
}
''',
      [lint(33, 49)],
    );
  }

  Future<void> test_selectWithMultipleInterpolations_reports() async {
    await assertDiagnostics(
      r'''
void f(String table, String column, String value) {
  final query = 'SELECT * FROM $table WHERE $column = $value';
}
''',
      [lint(68, 45)],
    );
  }

  // ==================== INSERT queries with interpolation ====================

  Future<void> test_insertWithInterpolation_reports() async {
    await assertDiagnostics(
      r'''
void f(String name, String email) {
  final query = 'INSERT INTO users (name, email) VALUES ($name, $email)';
}
''',
      [lint(52, 56)],
    );
  }

  // ==================== UPDATE queries with interpolation ====================

  Future<void> test_updateWithInterpolation_reports() async {
    await assertDiagnostics(
      r'''
void f(String newName, int id) {
  final query = 'UPDATE users SET name = $newName WHERE id = $id';
}
''',
      [lint(49, 49)],
    );
  }

  // ==================== DELETE queries with interpolation ====================

  Future<void> test_deleteWithInterpolation_reports() async {
    await assertDiagnostics(
      r'''
void f(int userId) {
  final query = 'DELETE FROM users WHERE id = $userId';
}
''',
      [lint(37, 38)],
    );
  }

  // ==================== DROP queries with interpolation ====================

  Future<void> test_dropWithInterpolation_reports() async {
    await assertDiagnostics(
      r'''
void f(String tableName) {
  final query = 'DROP TABLE $tableName';
}
''',
      [lint(43, 23)],
    );
  }

  // ==================== Case insensitivity ====================

  Future<void> test_lowercaseSqlKeyword_reports() async {
    await assertDiagnostics(
      r'''
void f(String userId) {
  final query = 'select * from users where id = $userId';
}
''',
      [lint(40, 40)],
    );
  }

  // ==================== Static SQL (no interpolation) - no report ====================

  Future<void> test_staticSelectQuery_noReport() async {
    await assertNoDiagnostics(r'''
void f() {
  final query = 'SELECT * FROM users WHERE id = 1';
}
''');
  }

  Future<void> test_parameterizedQuery_noReport() async {
    await assertNoDiagnostics(r'''
void f() {
  final query = 'SELECT * FROM users WHERE id = ?';
}
''');
  }

  Future<void> test_namedParameterQuery_noReport() async {
    await assertNoDiagnostics(r'''
void f() {
  final query = 'SELECT * FROM users WHERE id = :userId';
}
''');
  }

  // ==================== Non-SQL strings with interpolation - no report ====================

  Future<void> test_regularStringWithInterpolation_noReport() async {
    await assertNoDiagnostics(r'''
void f(String name) {
  final greeting = 'Hello, $name!';
}
''');
  }

  Future<void> test_urlWithInterpolation_noReport() async {
    await assertNoDiagnostics(r'''
void f(String userId) {
  final url = 'https://api.example.com/users/$userId';
}
''');
  }

  Future<void> test_jsonWithInterpolation_noReport() async {
    await assertNoDiagnostics(r'''
void f(String name) {
  final json = '{"name": "$name"}';
}
''');
  }

  // ==================== SQL in method arguments ====================

  Future<void> test_sqlInMethodArgument_reports() async {
    await assertDiagnostics(
      r'''
void execute(String query) {}
void f(String userId) {
  execute('SELECT * FROM users WHERE id = $userId');
}
''',
      [lint(64, 40)],
    );
  }

  // ==================== SQL in list ====================

  Future<void> test_sqlInList_reports() async {
    await assertDiagnostics(
      r'''
void f(String userId) {
  final queries = [
    'SELECT * FROM users WHERE id = $userId',
  ];
}
''',
      [lint(48, 40)],
    );
  }
}
