import 'dart:io';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/control_flow_graph.dart';

/// Utility class for visualizing Control Flow Graphs
class CFGVisualizer {
  /// Export CFG to DOT format for visualization with Graphviz
  static void exportToDot(ControlFlowGraph cfg, String outputPath) {
    final dotContent = cfg.toDot();
    File(outputPath).writeAsStringSync(dotContent);
  }

  /// Generate HTML visualization of CFG
  static String generateHtmlVisualization(ControlFlowGraph cfg) {
    final buffer = StringBuffer();

    buffer.writeln('''
<!DOCTYPE html>
<html>
<head>
    <title>Control Flow Graph Visualization</title>
    <script src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"></script>
    <style>
        #mynetworkid {
            width: 100%;
            height: 600px;
            border: 1px solid lightgray;
        }
    </style>
</head>
<body>
    <h1>Control Flow Graph</h1>
    <div id="mynetworkid"></div>
    
    <script>
        const nodes = new vis.DataSet([
''');

    // Add nodes
    for (final node in cfg.nodes) {
      final color = _getNodeColor(node.type.name);
      final shape = node.type.name == 'condition' ? 'diamond' : 'box';

      buffer.writeln('            {id: ${node.id}, label: "${_escapeLabel(node.toString())}", color: "$color", shape: "$shape"},');
    }

    buffer.writeln('''
        ]);
        
        const edges = new vis.DataSet([
''');

    // Add edges
    for (final node in cfg.nodes) {
      for (final successor in node.successors) {
        buffer.writeln('            {from: ${node.id}, to: ${successor.id}},');
      }
    }

    buffer.writeln('''
        ]);
        
        const container = document.getElementById('mynetworkid');
        const data = { nodes: nodes, edges: edges };
        const options = {
            layout: {
                hierarchical: {
                    direction: 'UD',
                    sortMethod: 'directed'
                }
            },
            physics: false
        };
        
        const network = new vis.Network(container, data, options);
    </script>
</body>
</html>
''');

    return buffer.toString();
  }

  static String _getNodeColor(String nodeType) {
    switch (nodeType) {
      case 'entry':
        return '#90EE90';
      case 'exit':
        return '#FFB6C1';
      case 'condition':
        return '#FFD700';
      case 'merge':
        return '#DDA0DD';
      default:
        return '#87CEEB';
    }
  }

  static String _escapeLabel(String label) {
    return label.replaceAll('"', '\\"').replaceAll('\n', '\\n');
  }
}
