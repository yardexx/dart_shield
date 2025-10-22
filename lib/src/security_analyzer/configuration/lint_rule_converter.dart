import 'package:dart_shield/src/security_analyzer/configuration/rule_config.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule_registry.dart';
import 'package:glob/glob.dart';
import 'package:json_annotation/json_annotation.dart';

class LintRuleConverter implements JsonConverter<LintRule, dynamic> {
  const LintRuleConverter();

  @override
  LintRule fromJson(dynamic value) {
    final ruleConfig = RuleConfig.fromDynamic(value);
    final excludePatterns = ruleConfig.exclude.map(Glob.new).toList();
    
    final rule = RuleRegistry.createRule(
      id: RuleId.fromYamlName(ruleConfig.name),
      excludes: excludePatterns,
    );

    return rule;
  }

  @override
  String toJson(LintRule rule) {
    return rule.id.name;
  }
}
