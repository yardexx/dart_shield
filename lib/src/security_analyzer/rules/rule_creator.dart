import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';
import 'package:dart_shield/src/security_analyzer/rules/rules_list/rules_list.dart';
import 'package:glob/glob.dart';

class RuleCreator {
  static LintRule createRule({
    required RuleId id,
    required Iterable<Glob> excludes,
  }) {
    switch (id) {
      case RuleId.preferHttpsOverHttp:
        return PreferHttpsOverHttp(excludes: excludes);
      case RuleId.avoidHardcodedUrls:
        return AvoidHardcodedUrls(excludes: excludes);
      case RuleId.avoidWeakHashing:
        return AvoidWeakHashing(excludes: excludes);
      case RuleId.preferSecureRandom:
        return PreferSecureRandom(excludes: excludes);
      case RuleId.avoidHardcodedSecrets:
        return AvoidHardcodedSecrets(excludes: excludes);
    }
  }
}
