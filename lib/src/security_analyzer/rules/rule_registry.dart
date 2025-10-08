import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/lint_rule.dart';
import 'package:dart_shield/src/security_analyzer/rules/rules_list/rules_list.dart';
import 'package:glob/glob.dart';

/// Registry for managing rule creation and instantiation.
///
/// This class provides a centralized way to create rule instances by mapping
/// [RuleId] values to their corresponding constructor functions.
class RuleRegistry {
  /// Static map that associates each [RuleId] with its constructor function.
  ///
  /// Each entry maps a [RuleId] to a function that takes an [Iterable<Glob>]
  /// for exclusions and returns a [LintRule] instance.
  static final Map<RuleId, LintRule Function(Iterable<Glob>)> _rules = {
    RuleId.preferHttpsOverHttp: (excludes) =>
        PreferHttpsOverHttp(excludes: excludes),
    RuleId.avoidHardcodedUrls: (excludes) =>
        AvoidHardcodedUrls(excludes: excludes),
    RuleId.avoidWeakHashing: (excludes) => AvoidWeakHashing(excludes: excludes),
    RuleId.preferSecureRandom: (excludes) =>
        PreferSecureRandom(excludes: excludes),
    RuleId.avoidHardcodedSecrets: (excludes) =>
        AvoidHardcodedSecrets(excludes: excludes),
  };

  /// Creates a rule instance for the given [id] with the specified [excludes].
  ///
  /// Throws an [ArgumentError] if the [id] is not registered in the registry.
  ///
  /// Example:
  /// ```dart
  /// final rule = RuleRegistry.createRule(
  ///   RuleId.avoidHardcodedSecrets,
  ///   [Glob('**/test/**')],
  /// );
  /// ```
  static LintRule createRule({
    required RuleId id,
    required Iterable<Glob> excludes,
  }) {
    final ruleFactory = _rules[id];
    if (ruleFactory == null) {
      throw ArgumentError('Unknown rule: $id');
    }
    return ruleFactory(excludes);
  }

  /// Returns all registered rule IDs.
  ///
  /// This can be useful for validation, documentation generation, or
  /// listing available rules.
  static Iterable<RuleId> get registeredRuleIds => _rules.keys;

  /// Checks if a rule with the given [id] is registered.
  static bool isRuleRegistered(RuleId id) => _rules.containsKey(id);
}
