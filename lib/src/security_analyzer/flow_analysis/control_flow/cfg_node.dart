import 'package:analyzer/dart/ast/ast.dart';

/// Represents different types of nodes in the Control Flow Graph
enum CFGNodeType {
  entry,          // Function entry point
  exit,           // Function exit point
  statement,      // Regular statement
  condition,      // Conditional expression (if, while, etc.)
  merge,          // Merge point for multiple paths
  call,           // Function/method call
  throw_,         // Throw statement
  return_,        // Return statement
  break_,         // Break statement
  continue_,      // Continue statement
}

/// A node in the Control Flow Graph
class CFGNode {
  CFGNode({
    required this.id,
    required this.type,
    this.statement,
    this.expression,
    this.label,
  });

  final int id;
  final CFGNodeType type;
  final Statement? statement;
  final Expression? expression;
  final String? label;

  final List<CFGNode> predecessors = [];
  final List<CFGNode> successors = [];

  /// Data flow information - what variables are defined at this node
  final Set<String> definitions = <String>{};

  /// Data flow information - what variables are used at this node
  final Set<String> uses = <String>{};

  void addSuccessor(CFGNode node) {
    if (!successors.contains(node)) {
      successors.add(node);
      node.predecessors.add(this);
    }
  }

  void addPredecessor(CFGNode node) {
    if (!predecessors.contains(node)) {
      predecessors.add(this);
      node.successors.add(this);
    }
  }

  @override
  String toString() {
    final nodeInfo = label ?? type.name;
    return 'CFGNode($id: $nodeInfo)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CFGNode && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
