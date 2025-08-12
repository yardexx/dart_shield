import 'package:dart_flow/src/control_flow/cfg_node.dart';
import 'package:dart_flow/src/control_flow/cfg_node_type.dart';
import 'package:test/test.dart';

void main() {
  group('CFGNode Tests', () {
    test('should create node with correct properties', () {
      final node = CFGNode(
        id: 'test1',
        type: CFGNodeType.statement,
        label: 'test statement',
      );

      expect(node.id, equals('test1'));
      expect(node.type, equals(CFGNodeType.statement));
      expect(node.label, equals('test statement'));
      expect(node.successors, isEmpty);
      expect(node.predecessors, isEmpty);
    });

    test('should connect nodes correctly', () {
      final node1 = CFGNode(id: '1', type: CFGNodeType.statement, label: 'A');
      final node2 = CFGNode(id: '2', type: CFGNodeType.statement, label: 'B');

      node1.addSuccessor(node2);

      expect(node1.successors, contains(node2));
      expect(node2.predecessors, contains(node1));
    });
  });
}
