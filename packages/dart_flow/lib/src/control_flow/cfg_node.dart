import 'package:analyzer/dart/ast/ast.dart';
import 'cfg_node_type.dart';

class CFGNode {
  final String id;
  final AstNode? astNode;
  final String label;
  final CFGNodeType type;

  final List<CFGNode> successors = [];
  final List<CFGNode> predecessors = [];

  CFGNode({
    required this.id,
    this.astNode,
    required this.label,
    required this.type,
  });

  void addSuccessor(CFGNode successor) {
    if (!successors.contains(successor)) {
      successors.add(successor);
      successor.predecessors.add(this);
    }
  }

  void removeSuccessor(CFGNode successor) {
    successors.remove(successor);
    successor.predecessors.remove(this);
  }

  @override
  String toString() {
    return 'CFGNode($label ($id))';
  }
}