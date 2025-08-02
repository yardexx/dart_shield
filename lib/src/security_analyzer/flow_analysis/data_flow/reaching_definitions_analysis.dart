import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_node.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/data_flow/data_flow_analysis.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/data_flow/data_flow_fact.dart';

/// Reaching definitions analysis - tracks which definitions reach each program point
class ReachingDefinitionsAnalysis
    extends DataFlowAnalysis<ReachingDefinitionsFact> {
  ReachingDefinitionsAnalysis({required super.cfg});

  @override
  ReachingDefinitionsFact getInitialFact() =>
      ReachingDefinitionsFact(definitions: {});

  @override
  ReachingDefinitionsFact getEmptyFact() =>
      ReachingDefinitionsFact(definitions: {});

  @override
  ReachingDefinitionsFact transfer(
    CFGNode node,
    ReachingDefinitionsFact inputFact,
  ) {
    final result = inputFact.copy();

    // Remove definitions that this node kills
    for (final variable in node.definitions) {
      result.definitions[variable] = <int>{};
    }

    // Add definitions that this node generates
    for (final variable in node.definitions) {
      result.definitions[variable] = {node.id};
    }

    return result;
  }
}
