import 'dart:io';

import 'package:dart_flow/dart_flow.dart';
import 'package:dart_flow/src/control_flow/cfg_node.dart';
import 'package:dart_flow/src/control_flow/cfg_node_type.dart';
import 'package:dart_flow/src/control_flow/control_flow_graph.dart';
import 'package:dart_flow/src/dart_flow_base.dart';

void main() async {
  //await basicUsageExample();
  await detailedAnalysisExample();
}

Future<void> basicUsageExample() async {
  print('=== Basic CFG Analysis ===');

  // Create analyzer for the current directory
  final analyzer = await DartCFGAnalyzer.forDirectory('example/');

  // Analyze the sample code file
  final cfgs = await analyzer.analyzeFile('example/sample_code.dart');

  print('Found ${cfgs.length} functions/methods to analyze:\n');

  for (final entry in cfgs.entries) {
    final name = entry.key;
    final cfg = entry.value;

    print('🔍 Function: $name');
    print('   Total nodes: ${cfg.nodes.length}');
    print('   Reachable nodes: ${cfg.getReachableNodes().length}');

    final unreachable = cfg.getUnreachableNodes();
    if (unreachable.isNotEmpty) {
      print('   ⚠️  Unreachable nodes: ${unreachable.length}');
      for (final node in unreachable) {
        if (node.type != CFGNodeType.exit) {
          print('      - ${node.label}');
        }
      }
    }

    final orphans = cfg.getOrphanNodes();
    if (orphans.isNotEmpty) {
      print('   🔗 Orphaned nodes: ${orphans.length}');
    }

    print('');
  }
}

Future<void> detailedAnalysisExample() async {
  print('=== Detailed CFG Analysis ===');

  final analyzer = await DartCFGAnalyzer.forDirectory('/Users/yardex/StudioProjects/dart_shield/packages/dart_flow/example');
  final cfgs = await analyzer.analyzeFile('/Users/yardex/StudioProjects/dart_shield/packages/dart_flow/example/sample_code.dart');

  // Focus on a specific function with interesting control flow
  final processNumbersCfg = cfgs['Calculator.processNumbers'];
  if (processNumbersCfg != null) {
    print('📊 Detailed analysis of "processNumbers" method:\n');

    // Print all nodes with their types
    print('Nodes in execution order:');
    final reachableNodes = processNumbersCfg.getReachableNodes();

    for (int i = 0; i < reachableNodes.length; i++) {
      final node = reachableNodes[i];
      final typeEmoji = _getTypeEmoji(node.type);
      print('  ${i + 1}. $typeEmoji ${node.type.name}: ${node.label}');

      if (node.successors.length > 1) {
        print('     ↳ Branches to ${node.successors.length} paths:');
        for (final successor in node.successors) {
          print('       - ${successor.label}');
        }
      }
    }

    // Analyze control flow patterns
    print('\n🔀 Control Flow Analysis:');
    _analyzeControlFlowPatterns(processNumbersCfg);

    // Generate DOT file for visualization
    await _generateVisualization(processNumbersCfg, 'processNumbers');
  }
}

String _getTypeEmoji(CFGNodeType type) {
  switch (type) {
    case CFGNodeType.entry: return '🚪';
    case CFGNodeType.exit: return '🏁';
    case CFGNodeType.condition: return '❓';
    case CFGNodeType.loop: return '🔄';
    case CFGNodeType.branch: return '🌿';
    case CFGNodeType.return_: return '↩️';
    case CFGNodeType.throw_: return '💥';
    case CFGNodeType.catch_: return '🎣';
    default: return '📝';
  }
}

void _analyzeControlFlowPatterns(ControlFlowGraph cfg) {
  final nodes = cfg.nodes;

  // Count different node types
  final typeCounts = <CFGNodeType, int>{};
  for (final node in nodes) {
    typeCounts[node.type] = (typeCounts[node.type] ?? 0) + 1;
  }

  print('  Node distribution:');
  for (final entry in typeCounts.entries) {
    if (entry.value > 0) {
      print('    ${entry.key.name}: ${entry.value}');
    }
  }

  // Find loops (nodes that have back edges)
  final loopNodes = nodes.where((node) {
    return node.successors.any((successor) =>
        _isBackEdge(node, successor, cfg));
  }).toList();

  if (loopNodes.isNotEmpty) {
    print('  🔄 Found ${loopNodes.length} loop(s)');
  }

  // Find decision points (nodes with multiple successors)
  final decisionPoints = nodes.where((node) =>
  node.successors.length > 1).toList();

  print('  🤔 Decision points: ${decisionPoints.length}');

  // Calculate cyclomatic complexity (simplified)
  final edges = nodes.fold(0, (sum, node) => sum + node.successors.length);
  final cyclomaticComplexity = edges - nodes.length + 2;
  print('  🧮 Cyclomatic complexity: $cyclomaticComplexity');
}

bool _isBackEdge(CFGNode from, CFGNode to, ControlFlowGraph cfg) {
  // Simple heuristic: if we can reach 'from' from 'to', it's likely a back edge
  final visited = <CFGNode>{};
  final queue = <CFGNode>[to];

  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    if (visited.contains(current) || current == from) {
      return current == from;
    }
    visited.add(current);
    queue.addAll(current.successors);
  }

  return false;
}

Future<void> _generateVisualization(ControlFlowGraph cfg, String name) async {
  final dotContent = cfg.toDot();
  final file = File('/Users/yardex/StudioProjects/dart_shield/packages/dart_flow/example/output/${name}_cfg.dot');

  await file.create(recursive: true);
  await file.writeAsString(dotContent);

  print('  📊 DOT file generated: ${file.path}');
  print('     To visualize: dot -Tpng ${file.path} -o ${name}_cfg.png');
}


