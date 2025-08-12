import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'cfg_builder.dart';
import 'control_flow_graph.dart';

/// Visitor to extract all executable elements from a compilation unit
class CFGExtractor extends RecursiveAstVisitor<void> {
  final CFGBuilder builder;
  final Map<String, ControlFlowGraph> cfgs;

  CFGExtractor(this.builder, this.cfgs);

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
    AstNode? current = node.parent;
    while (current != null) {
      if (current is ClassDeclaration) {
        return current.name.lexeme;
      }
      current = current.parent;
    }
    return null;
  }
}
