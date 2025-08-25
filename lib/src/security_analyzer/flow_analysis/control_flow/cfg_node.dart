import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_node_type.dart';

class CFGNode {
  CFGNode({
    required this.id,
    required this.label,
    required this.type,
    this.astNode,
  });

  final String id;
  final AstNode? astNode;
  final String label;
  final CFGNodeType type;

  final List<CFGNode> successors = [];
  final List<CFGNode> predecessors = [];

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
