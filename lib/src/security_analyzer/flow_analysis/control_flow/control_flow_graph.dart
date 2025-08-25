import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_node.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_node_type.dart';

/// Represents a complete Control Flow Graph
class ControlFlowGraph {
  ControlFlowGraph({required this.entry, required this.exit}) {
    nodes.addAll([entry, exit]);
  }

  final CFGNode entry;
  final CFGNode exit;
  final List<CFGNode> nodes = [];

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
    final buffer = StringBuffer()
      ..writeln('digraph CFG {')
      ..writeln('  rankdir=TB;')
      ..writeln('  node [shape=box];');

    for (final node in nodes) {
      final shape = _getNodeShape(node.type);
      final label = node.label.replaceAll('"', r'\"');
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
      case CFGNodeType.statement:
      case CFGNodeType.branch:
      case CFGNodeType.call:
      case CFGNodeType.return_:
      case CFGNodeType.throw_:
      case CFGNodeType.catch_:
      case CFGNodeType.continue_:
        return 'box';
    }
  }
}
