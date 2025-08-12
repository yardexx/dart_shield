import 'cfg_node.dart';
import 'cfg_node_type.dart';

/// Represents a complete Control Flow Graph
class ControlFlowGraph {
  final CFGNode entry;
  final CFGNode exit;
  final List<CFGNode> nodes = [];

  ControlFlowGraph({required this.entry, required this.exit}) {
    nodes.addAll([entry, exit]);
  }

  void addNode(CFGNode node) {
    if (!nodes.contains(node)) {
      nodes.add(node);
    }
  }

  /// Get all reachable nodes from entry
  List<CFGNode> getReachableNodes() {
    final visited = <CFGNode>{};
    final queue = <CFGNode>[entry];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (visited.contains(current)) continue;

      visited.add(current);
      queue.addAll(current.successors);
    }

    return visited.toList();
  }

  /// Get all nodes that are unreachable from entry
  List<CFGNode> getUnreachableNodes() {
    final reachable = getReachableNodes().toSet();
    return nodes.where((node) => !reachable.contains(node)).toList();
  }

  /// Get nodes with no predecessors (besides entry)
  List<CFGNode> getOrphanNodes() {
    return nodes
        .where((node) => node != entry && node.predecessors.isEmpty)
        .toList();
  }

  /// Generate DOT format for visualization
  String toDot() {
    final buffer = StringBuffer();
    buffer.writeln('digraph CFG {');
    buffer.writeln('  rankdir=TB;');
    buffer.writeln('  node [shape=box];');

    for (final node in nodes) {
      final shape = _getNodeShape(node.type);
      final label = node.label?.replaceAll('"', '\\"');
      buffer.writeln('  "${node.id}" [label="$label", shape=$shape];');
    }

    for (final node in nodes) {
      for (final successor in node.successors) {
        buffer.writeln('  "${node.id}" -> "${successor.id}";');
      }
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  String _getNodeShape(CFGNodeType type) {
    switch (type) {
      case CFGNodeType.entry:
      case CFGNodeType.exit:
        return 'ellipse';
      case CFGNodeType.condition:
        return 'diamond';
      case CFGNodeType.loop:
        return 'hexagon';
      default:
        return 'box';
    }
  }
}
