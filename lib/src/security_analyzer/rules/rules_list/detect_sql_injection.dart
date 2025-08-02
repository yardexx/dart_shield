import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:dart_shield/src/security_analyzer/extensions.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/flow_analysis_engine.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/data_flow/taint_analysis.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';
import 'package:source_span/source_span.dart';

/// Specialized rule for detecting SQL injection vulnerabilities using taint analysis
class DetectSqlInjection extends LintRule {
  DetectSqlInjection({required super.excludes})
      : super(
    id: RuleId.detectSqlInjection,
    message: _message,
    severity: Severity.critical,
    status: RuleStatus.experimental,
  );

  static const _message =
      'Potential SQL injection vulnerability detected.';

  @override
  List<SyntacticEntity> collectErrorNodes(ResolvedUnitResult source) {
    final config = _createSqlInjectionConfig();
    final engine = FlowAnalysisEngine();
    final result = engine.analyzeUnit(source);

    final errorNodes = <SyntacticEntity>[];

    // Filter for SQL-specific vulnerabilities
    for (final vulnerability in result.allVulnerabilities) {
      if (_isSqlSink(vulnerability.sink)) {
        errorNodes.add(vulnerability.location);
      }
    }

    return errorNodes;
  }

  @override
  Iterable<LintIssue> check(ResolvedUnitResult source) {
    final config = _createSqlInjectionConfig();
    final engine = FlowAnalysisEngine();
    final result = engine.analyzeUnit(source);

    final issues = <LintIssue>[];

    for (final vulnerability in result.allVulnerabilities) {
      if (_isSqlSink(vulnerability.sink)) {
        final location = SourceSpanX.fromNode(
          node: vulnerability.location,
          source: source,
        );

        final detailedMessage = _buildSqlInjectionMessage(vulnerability);

        issues.add(LintIssue.withRule(
          rule: this,
          message: detailedMessage,
          location: location,
        ));
      }
    }

    return issues;
  }

  TaintAnalysisConfig _createSqlInjectionConfig() {
    return TaintAnalysisConfig(
      sources: {
        // HTTP input sources
        'request.body',
        'request.query',
        'request.params',
        'request.headers',
        'HttpRequest.uri.queryParameters',

        // Form input
        'FormData.get',
        'MultipartFile.filename',

        // File input
        'File.readAsString',
        'stdin.readLineSync',

        // Environment
        'Platform.environment',
      },
      sinks: {
        // Database query methods
        'execute', 'query', 'rawQuery',
        'Database.execute', 'Database.query', 'Database.rawQuery',
        'Connection.query', 'Connection.execute',
        'PreparedStatement.execute',

        // ORM methods that might be vulnerable
        'find', 'findOne', 'findBy',
        'where', 'orderBy', 'groupBy',

        // Raw SQL construction
        'SELECT', 'INSERT', 'UPDATE', 'DELETE',
      },
      sanitizers: {
        // Parameterized queries
        'prepare', 'bind',
        'PreparedStatement.setString',
        'PreparedStatement.setInt',

        // SQL escaping
        'escape', 'escapeSql',
        'quote', 'quoteName',

        // Validation
        'validate', 'sanitize',
        'isNumeric', 'isAlphanumeric',

        // Type conversion with validation
        'int.parse', 'double.parse',
        'DateTime.parse',
      },
      propagators: {
        // String operations
        'toString', 'substring', 'trim',
        'toLowerCase', 'toUpperCase',
        'replaceAll', 'replaceFirst',
        '+', // String concatenation

        // Collection operations
        'join', 'map', 'where',
      },
    );
  }

  bool _isSqlSink(String sink) {
    final sqlSinks = {
      'execute', 'query', 'rawQuery',
      'Database.execute', 'Database.query', 'Database.rawQuery',
      'Connection.query', 'Connection.execute',
      'PreparedStatement.execute',
      'find', 'findOne', 'findBy',
      'where', 'orderBy', 'groupBy',
      'SELECT', 'INSERT', 'UPDATE', 'DELETE',
    };

    return sqlSinks.any((sqlSink) => sink.contains(sqlSink));
  }

  String _buildSqlInjectionMessage(dynamic vulnerability) {
    return 'SQL injection vulnerability: User input from "${vulnerability.source}" '
        'reaches SQL query "${vulnerability.sink}" without proper sanitization. '
        'Use parameterized queries or proper input validation to prevent SQL injection attacks.';
  }
}
