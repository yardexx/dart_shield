import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule_creator.dart';
import 'package:json_annotation/json_annotation.dart';

class LintRuleConverter implements JsonConverter<LintRule, String> {
  const LintRuleConverter();

  // Todo: Implement file exclusion
  @override
  LintRule fromJson(String name) {
    final rule = RuleCreator.createRule(
      id: RuleId.fromYamlName(name),
      excludes: [],
    );

    return rule;
  }

  @override
  String toJson(LintRule rule) {
    return rule.id.name;
  }
}
