import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_node.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/data_flow/data_flow_analysis.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/data_flow/data_flow_fact.dart';

/// Configuration for taint analysis
class TaintAnalysisConfig {
  TaintAnalysisConfig({
    this.sources = const {},
    this.sinks = const {},
    this.sanitizers = const {},
    this.propagators = const {},
  });

  /// Methods/functions that introduce taint (e.g., user input)
  final Set<String> sources;

  /// Methods/functions that are vulnerable if tainted data reaches them
  final Set<String> sinks;

  /// Methods/functions that remove taint (sanitization)
  final Set<String> sanitizers;

  /// Methods/functions that propagate taint from input to output
  final Set<String> propagators;

  /// Default configuration for common security issues
  static TaintAnalysisConfig defaultConfig() {
    return TaintAnalysisConfig(
      sources: {
        // HTTP input
        'request.body',
        'request.query',
        'request.params',
        'request.headers',
        'stdin.readLineSync',
        'Platform.environment',

        // File input
        'File.readAsString',
        'File.readAsBytes',

        // Network input
        'http.get',
        'http.post',
        'HttpClient.get',
        'Socket.connect',
      },
      sinks: {
        // SQL injection
        'execute',
        'query',
        'rawQuery',

        // Command injection
        'Process.run',
        'Process.start',
        'shell',

        // File system
        'File.writeAsString',
        'File.writeAsBytes',
        'Directory.create',

        // Reflection/eval
        'dart:mirrors',
        'eval',

        // Logging (potential data leak)
        'print',
        'log',
        'logger.info',
        'logger.debug',
      },
      sanitizers: {
        'sanitize',
        'escape',
        'validate',
        'Uri.encodeComponent',
        'HtmlEscape.convert',
        'RegExp.escape',
      },
      propagators: {
        'toString',
        'substring',
        'trim',
        'toLowerCase',
        'toUpperCase',
        '+', // String concatenation
      },
    );
  }
}

/// Taint analysis for tracking untrusted data flow
class TaintAnalysis extends DataFlowAnalysis<TaintFact> {
  TaintAnalysis({required super.cfg, TaintAnalysisConfig? config})
    : config = config ?? TaintAnalysisConfig.defaultConfig();

  final TaintAnalysisConfig config;

  @override
  TaintFact getInitialFact() => TaintFact(taintedVariables: {});

  @override
  TaintFact getEmptyFact() => TaintFact(taintedVariables: {});

  @override
  TaintFact transfer(CFGNode node, TaintFact inputFact) {
    var result = inputFact.copy();

    if (node.statement != null) {
      result = _analyzeStatement(node.statement!, result);
    }

    if (node.expression != null) {
      result = _analyzeExpression(node.expression!, result);
    }

    return result;
  }

  TaintFact _analyzeStatement(Statement statement, TaintFact fact) {
    if (statement is VariableDeclarationStatement) {
      return _analyzeVariableDeclaration(statement, fact);
    } else if (statement is ExpressionStatement) {
      return _analyzeExpression(statement.expression, fact);
    } else if (statement is ReturnStatement && statement.expression != null) {
      return _analyzeExpression(statement.expression!, fact);
    }

    return fact;
  }

  TaintFact _analyzeVariableDeclaration(
    VariableDeclarationStatement statement,
    TaintFact fact,
  ) {
    var result = fact;

    for (final variable in statement.variables.variables) {
      final varName = variable.name.lexeme;

      if (variable.initializer != null) {
        final initializerTaint = _isExpressionTainted(
          variable.initializer!,
          fact,
        );
        if (initializerTaint.isTainted) {
          result = result.addTaint(varName, source: initializerTaint.source);
        }
      }
    }

    return result;
  }

  TaintFact _analyzeExpression(Expression expression, TaintFact fact) {
    if (expression is AssignmentExpression) {
      return _analyzeAssignment(expression, fact);
    } else if (expression is MethodInvocation) {
      return _analyzeMethodInvocation(expression, fact);
    }

    return fact;
  }

  TaintFact _analyzeAssignment(
    AssignmentExpression assignment,
    TaintFact fact,
  ) {
    final leftSide = assignment.leftHandSide;
    final rightSide = assignment.rightHandSide;

    if (leftSide is SimpleIdentifier) {
      final varName = leftSide.name;
      final rightTaint = _isExpressionTainted(rightSide, fact);

      if (rightTaint.isTainted) {
        return fact.addTaint(varName, source: rightTaint.source);
      } else {
        // Assignment of clean data removes taint
        return fact.removeTaint(varName);
      }
    }

    return fact;
  }

  TaintFact _analyzeMethodInvocation(
    MethodInvocation invocation,
    TaintFact fact,
  ) {
    final methodName = _getMethodName(invocation);

    // Check if this is a source
    if (config.sources.contains(methodName)) {
      // If the result is assigned to a variable, mark it as tainted
      return fact; // Taint will be added by assignment analysis
    }

    // Check if this is a sanitizer
    if (config.sanitizers.contains(methodName)) {
      // Sanitizers remove taint from their arguments
      var result = fact;
      for (final arg in invocation.argumentList.arguments) {
        if (arg is SimpleIdentifier) {
          result = result.removeTaint(arg.name, sanitizer: methodName);
        }
      }
      return result;
    }

    // Check if this is a sink - this is where we detect vulnerabilities
    if (config.sinks.contains(methodName)) {
      _checkSinkVulnerability(invocation, fact, methodName);
    }

    return fact;
  }

  ExpressionTaintResult _isExpressionTainted(
    Expression expression,
    TaintFact fact,
  ) {
    if (expression is SimpleIdentifier) {
      final isTainted = fact.isTainted(expression.name);
      return ExpressionTaintResult(
        isTainted: isTainted,
        source: isTainted ? 'variable:${expression.name}' : null,
      );
    } else if (expression is MethodInvocation) {
      final methodName = _getMethodName(expression);

      // Source methods produce tainted data
      if (config.sources.contains(methodName)) {
        return ExpressionTaintResult(
          isTainted: true,
          source: 'source:$methodName',
        );
      }

      // Propagator methods propagate taint from arguments
      if (config.propagators.contains(methodName)) {
        for (final arg in expression.argumentList.arguments) {
          final argTaint = _isExpressionTainted(arg, fact);
          if (argTaint.isTainted) {
            return ExpressionTaintResult(
              isTainted: true,
              source: argTaint.source,
            );
          }
        }
      }

      // Check if target is tainted (for method calls on objects)
      if (expression.target != null) {
        final targetTaint = _isExpressionTainted(expression.target!, fact);
        if (targetTaint.isTainted && config.propagators.contains(methodName)) {
          return ExpressionTaintResult(
            isTainted: true,
            source: targetTaint.source,
          );
        }
      }
    } else if (expression is BinaryExpression) {
      // String concatenation propagates taint
      if (expression.operator.lexeme == '+') {
        final leftTaint = _isExpressionTainted(expression.leftOperand, fact);
        final rightTaint = _isExpressionTainted(expression.rightOperand, fact);

        if (leftTaint.isTainted || rightTaint.isTainted) {
          return ExpressionTaintResult(
            isTainted: true,
            source: leftTaint.source ?? rightTaint.source,
          );
        }
      }
    }

    return ExpressionTaintResult(isTainted: false);
  }

  void _checkSinkVulnerability(
    MethodInvocation invocation,
    TaintFact fact,
    String sinkName,
  ) {
    for (final arg in invocation.argumentList.arguments) {
      final argTaint = _isExpressionTainted(arg, fact);
      if (argTaint.isTainted) {
        // Found a vulnerability!
        vulnerabilities.add(
          TaintVulnerability(
            sink: sinkName,
            taintedArgument: arg.toString(),
            source: argTaint.source ?? 'unknown',
            location: invocation,
          ),
        );
      }
    }
  }

  String _getMethodName(MethodInvocation invocation) {
    if (invocation.target != null) {
      return '${invocation.target}.${invocation.methodName.name}';
    }
    return invocation.methodName.name;
  }

  final List<TaintVulnerability> vulnerabilities = [];
}

/// Result of checking if an expression is tainted
class ExpressionTaintResult {
  ExpressionTaintResult({required this.isTainted, this.source});

  final bool isTainted;
  final String? source;
}

/// Represents a taint vulnerability found during analysis
class TaintVulnerability {
  TaintVulnerability({
    required this.sink,
    required this.taintedArgument,
    required this.source,
    required this.location,
  });

  final String sink;
  final String taintedArgument;
  final String source;
  final Expression location;

  @override
  String toString() =>
      'TaintVulnerability: $source flows to $sink via $taintedArgument';
}
