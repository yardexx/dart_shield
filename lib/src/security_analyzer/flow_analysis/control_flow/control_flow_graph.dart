import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_node.dart';

/// Represents a Control Flow Graph for a function or method
class ControlFlowGraph {
  ControlFlowGraph({
    required this.entryNode,
    required this.exitNode,
    required this.nodes,
    required this.functionNode,
  });

  final CFGNode entryNode;
  final CFGNode exitNode;
  final List<CFGNode> nodes;
  final AstNode functionNode; // FunctionDeclaration, MethodDeclaration, etc.

  /// Get all nodes that can reach the given node
  Set<CFGNode> getReachableNodes(CFGNode target) {
    final visited = <CFGNode>{};
    final queue = <CFGNode>[entryNode];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (visited.contains(current)) continue;

      visited.add(current);
      queue.addAll(current.successors);

      if (current == target) break;
    }

    return visited;
  }

  /// Get all nodes reachable from the given node
  Set<CFGNode> getNodesReachableFrom(CFGNode source) {
    final visited = <CFGNode>{};
    final queue = <CFGNode>[source];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (visited.contains(current)) continue;

      visited.add(current);
      queue.addAll(current.successors);
    }

    return visited;
  }

  /// Check if there's a path from source to target
  bool hasPath(CFGNode source, CFGNode target) {
    return getNodesReachableFrom(source).contains(target);
  }

  /// Get all paths from source to target (for vulnerability tracking)
  List<List<CFGNode>> getAllPaths(CFGNode source, CFGNode target) {
    final paths = <List<CFGNode>>[];
    final currentPath = <CFGNode>[];
    final visited = <CFGNode>{};

    _findAllPaths(source, target, currentPath, visited, paths);
    return paths;
  }

  void _findAllPaths(
    CFGNode current,
    CFGNode target,
    List<CFGNode> currentPath,
    Set<CFGNode> visited,
    List<List<CFGNode>> allPaths,
  ) {
    currentPath.add(current);
    visited.add(current);

    if (current == target) {
      allPaths.add(List.from(currentPath));
    } else {
      for (final successor in current.successors) {
        if (!visited.contains(successor)) {
          _findAllPaths(successor, target, currentPath, visited, allPaths);
        }
      }
    }

    currentPath.removeLast();
    visited.remove(current);
  }

  /// Generate DOT format for visualization
  String toDot() {
    final buffer = StringBuffer()
      ..writeln('digraph CFG {')
      ..writeln('  rankdir=TB;');

    for (final node in nodes) {
      final shape = node.type == CFGNodeType.condition ? 'diamond' : 'box';
      final color = node.type == CFGNodeType.entry
          ? 'green'
          : node.type == CFGNodeType.exit
          ? 'red'
          : 'lightblue';

      buffer.writeln(
        '  ${node.id} [label="${_getNodeLabel(node)}", shape=$shape, fillcolor=$color, style=filled];',
      );
    }

    for (final node in nodes) {
      for (final successor in node.successors) {
        buffer.writeln('  ${node.id} -> ${successor.id};');
      }
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  String _getNodeLabel(CFGNode node) {
    if (node.label != null) return node.label!;
    if (node.statement != null) {
      return node.statement
          .toString()
          .replaceAll('\n', '\\n')
          .replaceAll('"', '\\"');
    }
    if (node.expression != null) {
      return node.expression
          .toString()
          .replaceAll('\n', '\\n')
          .replaceAll('"', '\\"');
    }
    return node.type.name;
  }
}
