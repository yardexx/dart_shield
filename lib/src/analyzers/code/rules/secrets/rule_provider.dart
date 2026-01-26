import 'dart:convert';
import 'dart:io';

import 'package:dart_shield/src/analyzers/code/rules/secrets/secret_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/secrets/secret_rules.dart';
import 'package:dart_shield/src/generated/fallback_rules.dart';
import 'package:path/path.dart' as path;

class RuleProvider {
  static List<SecretRule>? _cachedRules;

  /// Returns the list of active secret detection rules.
  ///
  /// Priority:
  /// 1. Local Cache file (~/.dart_shield/rules.json)
  /// 2. Embedded Fallback rules
  ///
  /// Always includes [SecretRules.custom] rules.
  static List<SecretRule> getRules() {
    if (_cachedRules != null) return _cachedRules!;

    final rules = <SecretRule>[];

    // 1. Try loading from user cache
    try {
      final cacheFile = _getCacheFile();
      if (cacheFile.existsSync()) {
        final jsonContent = cacheFile.readAsStringSync();
        rules.addAll(_parseRules(jsonContent));
      }
    } on Exception catch (_) {
      // Log error or silently fail to fallback?
      // For now, we silently fallback to ensure stability.
    }

    // 2. If cache missed or failed, load fallback
    if (rules.isEmpty) {
      try {
        rules.addAll(_parseRules(fallbackRulesJson));
      } on Exception catch (e) {
        // This should never happen if the generator is correct
        // ignore: avoid_print
        print('CRITICAL ERROR: Failed to parse embedded fallback rules: $e');
      }
    }

    // 3. Add custom rules (always active)
    rules.addAll(SecretRules.custom);

    _cachedRules = rules;
    return rules;
  }

  static List<SecretRule> _parseRules(String jsonContent) {
    final jsonList = jsonDecode(jsonContent) as List;
    return jsonList
        .map((e) => SecretRule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static File _getCacheFile() {
    final env = Platform.environment;
    final home = env['HOME'] ?? env['USERPROFILE'];
    if (home == null) {
      throw Exception('Could not determine home directory');
    }
    return File(path.join(home, '.dart_shield', 'rules.json'));
  }
}
