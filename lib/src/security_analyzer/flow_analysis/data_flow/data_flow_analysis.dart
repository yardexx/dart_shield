import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_node.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/control_flow_graph.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/data_flow/data_flow_fact.dart';

/// Abstract base class for data flow analysis
abstract class DataFlowAnalysis<T extends DataFlowFact> {
  DataFlowAnalysis({required this.cfg});

  final ControlFlowGraph cfg;

  /// Direction of analysis
  bool get isForward => true;

  /// Initialize fact for entry/exit nodes
  T getInitialFact();

  /// Generate fact for empty state
  T getEmptyFact();

  /// Transfer function: compute output fact from input fact and node
  T transfer(CFGNode node, T inputFact);

  /// Run the data flow analysis
  Map<CFGNode, T> analyze() {
    final inFacts = <CFGNode, T>{};
    final outFacts = <CFGNode, T>{};
    final workList = <CFGNode>[];

    // Initialize
    for (final node in cfg.nodes) {
      if (isForward && node == cfg.entryNode) {
        inFacts[node] = getInitialFact();
      } else if (!isForward && node == cfg.exitNode) {
        outFacts[node] = getInitialFact();
      } else {
        inFacts[node] = getEmptyFact();
        outFacts[node] = getEmptyFact();
      }
      workList.add(node);
    }

    // Fixed-point iteration
    while (workList.isNotEmpty) {
      final node = workList.removeAt(0);

      if (isForward) {
        // Forward analysis: in[n] = merge(out[pred] for pred in predecessors[n])
        final newIn = node.predecessors.isEmpty
            ? (node == cfg.entryNode ? getInitialFact() : getEmptyFact())
            : _mergeFacts(
                node.predecessors.map((pred) => outFacts[pred]).whereType<T>(),
              );

        final oldOut = outFacts[node] ?? getEmptyFact();
        final newOut = transfer(node, newIn);

        inFacts[node] = newIn;
        outFacts[node] = newOut;

        if (!(oldOut == newOut)) {
          workList.addAll(
            node.successors.where((succ) => !workList.contains(succ)),
          );
        }
      } else {
        // Backward analysis: out[n] = merge(in[succ] for succ in successors[n])
        final newOut = node.successors.isEmpty
            ? (node == cfg.exitNode ? getInitialFact() : getEmptyFact())
            : _mergeFacts(
                node.successors.map((succ) => inFacts[succ]).whereType<T>(),
              );

        final oldIn = inFacts[node] ?? getEmptyFact();
        final newIn = transfer(node, newOut);

        inFacts[node] = newIn;
        outFacts[node] = newOut;

        if (!(oldIn == newIn)) {
          workList.addAll(
            node.predecessors.where((pred) => !workList.contains(pred)),
          );
        }
      }
    }

    return isForward ? outFacts : inFacts;
  }

  T _mergeFacts(Iterable<T> facts) {
    if (facts.isEmpty) return getEmptyFact();

    T result = facts.first.copy() as T;
    for (final fact in facts.skip(1)) {
      result = result.merge(fact) as T;
    }
    return result;
  }
}
