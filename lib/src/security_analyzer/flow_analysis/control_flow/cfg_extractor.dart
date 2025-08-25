import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_builder.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/control_flow_graph.dart';

/// Visitor to extract all executable elements from a compilation unit
class CFGExtractor extends RecursiveAstVisitor<void> {

  CFGExtractor(this.builder, this.cfgs);
  final CFGBuilder builder;
  final Map<String, ControlFlowGraph> cfgs;

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final name = node.name.lexeme;
    cfgs[name] = builder.buildForFunction(node);
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final className = _getEnclosingClassName(node);
    final methodName = node.name.lexeme;
    final fullName = className != null ? '$className.$methodName' : methodName;
    cfgs[fullName] = builder.buildForMethod(node);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    final className = _getEnclosingClassName(node);
    final constructorName = node.name?.lexeme ?? '';
    final fullName = className != null
        ? '$className.$constructorName'
        : constructorName;
    cfgs[fullName] = builder.buildForConstructor(node);
    super.visitConstructorDeclaration(node);
  }

  String? _getEnclosingClassName(AstNode node) {
    var current = node.parent;
    while (current != null) {
      if (current is ClassDeclaration) {
        return current.name.lexeme;
      }
      current = current.parent;
    }
    return null;
  }
}
