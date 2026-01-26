import 'package:dart_shield/src/analyzers/analyzer.dart';
import 'package:dart_shield/src/analyzers/code/code_analyzer.dart';
import 'package:dart_shield/src/configuration/shield_config.dart';

/// Defines the signature for creating an analyzer.
/// We pass the raw paths, and the factory decides how to use them.
typedef AnalyzerBuilder = Analyzer Function(List<String> paths);

class AnalyzerFactory {
  static final Map<String, AnalyzerBuilder> _builders = {
    'code': (paths) => CodeAnalyzer(analyzedPaths: paths),
  };

  static List<String> get availableIds => _builders.keys.toList();

  /// Resolves and instantiates the analyzers
  static List<Analyzer> resolve({
    required List<String> paths,
    required ShieldConfig config,
    List<String> only = const [],
    List<String> exclude = const [],
  }) {
    final configEnabled = <String, bool>{'code': config.analyzers.code};

    final selected = <Analyzer>[];

    for (final entry in _builders.entries) {
      final id = entry.key;
      final builder = entry.value;

      if (_shouldRun(id, configEnabled[id] ?? true, only, exclude)) {
        selected.add(builder(paths));
      }
    }

    return selected;
  }

  static bool _shouldRun(
    String id,
    bool isEnabledInYaml,
    List<String> only,
    List<String> exclude,
  ) {
    if (exclude.contains(id)) return false;
    if (only.isNotEmpty) return only.contains(id);
    return isEnabledInYaml;
  }
}
