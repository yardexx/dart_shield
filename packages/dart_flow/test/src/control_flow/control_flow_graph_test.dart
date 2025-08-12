import 'package:dart_flow/src/control_flow/cfg_node.dart';
import 'package:dart_flow/src/control_flow/cfg_node_type.dart';
import 'package:dart_flow/src/control_flow/control_flow_graph.dart';
import 'package:test/test.dart';

void main() {
  group('ControlFlowGraph Tests', () {
    test('should create graph with entry and exit', () {
      final entry = CFGNode(
        id: 'entry',
        type: CFGNodeType.entry,
        label: 'ENTRY',
      );
      final exit = CFGNode(id: 'exit', type: CFGNodeType.exit, label: 'EXIT');
      final cfg = ControlFlowGraph(entry: entry, exit: exit);

      expect(cfg.entry, equals(entry));
      expect(cfg.exit, equals(exit));
      expect(cfg.nodes, contains(entry));
      expect(cfg.nodes, contains(exit));
    });

    test('should find reachable nodes', () {
      final entry = CFGNode(
        id: 'entry',
        type: CFGNodeType.entry,
        label: 'ENTRY',
      );
      final exit = CFGNode(id: 'exit', type: CFGNodeType.exit, label: 'EXIT');
      final middle = CFGNode(
        id: 'middle',
        type: CFGNodeType.statement,
        label: 'STMT',
      );
      final unreachable = CFGNode(
        id: 'unreachable',
        type: CFGNodeType.statement,
        label: 'UNREACHABLE',
      );

      final cfg = ControlFlowGraph(entry: entry, exit: exit);
      cfg.addNode(middle);
      cfg.addNode(unreachable);

      entry.addSuccessor(middle);
      middle.addSuccessor(exit);
      // unreachable is not connected

      final reachable = cfg.getReachableNodes();
      expect(reachable, contains(entry));
      expect(reachable, contains(middle));
      expect(reachable, contains(exit));
      expect(reachable, isNot(contains(unreachable)));
    });
  });
}
