/// Base class for data flow facts
abstract class DataFlowFact {
  /// Merge this fact with another fact
  DataFlowFact merge(DataFlowFact other);

  /// Check if this fact equals another fact
  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  /// Create a copy of this fact
  DataFlowFact copy();
}

/// Represents taint information for security analysis
class TaintFact implements DataFlowFact {
  TaintFact({
    required this.taintedVariables,
    this.sources = const {},
    this.sanitizers = const {},
  });

  final Set<String> taintedVariables;
  final Set<String> sources; // Where taint originated
  final Set<String> sanitizers; // What sanitization was applied

  @override
  TaintFact merge(DataFlowFact other) {
    if (other is! TaintFact) return this;

    return TaintFact(
      taintedVariables: {...taintedVariables, ...other.taintedVariables},
      sources: {...sources, ...other.sources},
      sanitizers: {...sanitizers, ...other.sanitizers},
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaintFact &&
          _setEquals(taintedVariables, other.taintedVariables) &&
          _setEquals(sources, other.sources) &&
          _setEquals(sanitizers, other.sanitizers);

  @override
  int get hashCode => Object.hash(taintedVariables, sources, sanitizers);

  @override
  TaintFact copy() => TaintFact(
    taintedVariables: Set.from(taintedVariables),
    sources: Set.from(sources),
    sanitizers: Set.from(sanitizers),
  );

  /// Check if a variable is tainted
  bool isTainted(String variable) => taintedVariables.contains(variable);

  /// Add taint to a variable
  TaintFact addTaint(String variable, {String? source}) {
    final newSources = source != null ? {...sources, source} : sources;
    return TaintFact(
      taintedVariables: {...taintedVariables, variable},
      sources: newSources,
      sanitizers: sanitizers,
    );
  }

  /// Remove taint from a variable (sanitization)
  TaintFact removeTaint(String variable, {String? sanitizer}) {
    final newSanitizers = sanitizer != null
        ? {...sanitizers, sanitizer}
        : sanitizers;
    return TaintFact(
      taintedVariables: taintedVariables.where((v) => v != variable).toSet(),
      sources: sources,
      sanitizers: newSanitizers,
    );
  }

  bool _setEquals<T>(Set<T> a, Set<T> b) {
    return a.length == b.length && a.containsAll(b);
  }

  @override
  String toString() =>
      'TaintFact(tainted: $taintedVariables, sources: $sources)';
}

/// Represents reaching definitions information
class ReachingDefinitionsFact implements DataFlowFact {
  ReachingDefinitionsFact({required this.definitions});

  final Map<String, Set<int>>
  definitions; // Variable -> Set of definition node IDs

  @override
  ReachingDefinitionsFact merge(DataFlowFact other) {
    if (other is! ReachingDefinitionsFact) return this;

    final merged = <String, Set<int>>{};
    final allVars = {...definitions.keys, ...other.definitions.keys};

    for (final variable in allVars) {
      merged[variable] = {
        ...definitions[variable] ?? <int>{},
        ...other.definitions[variable] ?? <int>{},
      };
    }

    return ReachingDefinitionsFact(definitions: merged);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReachingDefinitionsFact &&
          _mapEquals(definitions, other.definitions);

  @override
  int get hashCode => definitions.hashCode;

  @override
  ReachingDefinitionsFact copy() {
    final copiedDefs = <String, Set<int>>{};
    for (final entry in definitions.entries) {
      copiedDefs[entry.key] = Set.from(entry.value);
    }
    return ReachingDefinitionsFact(definitions: copiedDefs);
  }

  bool _mapEquals<K, V>(Map<K, Set<V>> a, Map<K, Set<V>> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (!_setEquals(a[key]!, b[key]!)) return false;
    }
    return true;
  }

  bool _setEquals<T>(Set<T> a, Set<T> b) {
    return a.length == b.length && a.containsAll(b);
  }

  @override
  String toString() => 'ReachingDefinitions($definitions)';
}
