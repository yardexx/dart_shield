import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_builder.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/control_flow_graph.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/data_flow/reaching_definitions_analysis.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/data_flow/taint_analysis.dart';

/// Main engine for flow analysis
class FlowAnalysisEngine {
  FlowAnalysisEngine();

  /// Analyze a resolved unit for security vulnerabilities using flow analysis
  FlowAnalysisResult analyzeUnit(ResolvedUnitResult unit) {
    final visitor = _FunctionVisitor();
    unit.unit.accept(visitor);

    final results = <String, FunctionAnalysisResult>{};

    for (final function in visitor.functions) {
      final result = analyzeFunction(function);
      final functionName = _getFunctionName(function);
      results[functionName] = result;
    }

    for (final method in visitor.methods) {
      final result = analyzeMethod(method);
      final methodName = _getMethodName(method);
      results[methodName] = result;
    }

    return FlowAnalysisResult(
      filePath: unit.path,
      functionResults: results,
    );
  }

  /// Analyze a single function
  FunctionAnalysisResult analyzeFunction(FunctionDeclaration function) {
    final cfgBuilder = CFGBuilder();
    final cfg = cfgBuilder.buildForFunction(function);

    return _analyzeCFG(cfg, _getFunctionName(function));
  }

  /// Analyze a single method
  FunctionAnalysisResult analyzeMethod(MethodDeclaration method) {
    final cfgBuilder = CFGBuilder();
    final cfg = cfgBuilder.buildForMethod(method);

    return _analyzeCFG(cfg, _getMethodName(method));
  }

  FunctionAnalysisResult _analyzeCFG(ControlFlowGraph cfg, String name) {
    // Run taint analysis
    final taintAnalysis = TaintAnalysis(cfg: cfg);
    final taintResults = taintAnalysis.analyze();

    // Run reaching definitions analysis
    final reachingDefsAnalysis = ReachingDefinitionsAnalysis(cfg: cfg);
    final reachingDefsResults = reachingDefsAnalysis.analyze();

    return FunctionAnalysisResult(
      functionName: name,
      cfg: cfg,
      taintVulnerabilities: taintAnalysis.vulnerabilities,
      reachingDefinitions: reachingDefsResults,
    );
  }

  String _getFunctionName(FunctionDeclaration function) {
    return function.name.lexeme;
  }

  String _getMethodName(MethodDeclaration method) {
    return method.name.lexeme;
  }
}

/// Visitor to find all functions and methods in a compilation unit
class _FunctionVisitor extends RecursiveAstVisitor<void> {
  final List<FunctionDeclaration> functions = [];
  final List<MethodDeclaration> methods = [];

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    functions.add(node);
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    methods.add(node);
    super.visitMethodDeclaration(node);
  }
}

/// Result of flow analysis for an entire file
class FlowAnalysisResult {
  FlowAnalysisResult({
    required this.filePath,
    required this.functionResults,
  });

  final String filePath;
  final Map<String, FunctionAnalysisResult> functionResults;

  /// Get all vulnerabilities found in this file
  List<TaintVulnerability> get allVulnerabilities {
    return functionResults.values
        .expand((result) => result.taintVulnerabilities)
        .toList();
  }

  /// Check if any vulnerabilities were found
  bool get hasVulnerabilities => allVulnerabilities.isNotEmpty;
}

/// Result of flow analysis for a single function
class FunctionAnalysisResult {
  FunctionAnalysisResult({
    required this.functionName,
    required this.cfg,
    required this.taintVulnerabilities,
    required this.reachingDefinitions,
  });

  final String functionName;
  final ControlFlowGraph cfg;
  final List<TaintVulnerability> taintVulnerabilities;
  final Map<dynamic, dynamic> reachingDefinitions; // CFGNode -> ReachingDefinitionsFact
}
