import 'dart:io';

import 'package:dart_shield/src/security_analyzer/configuration/glob_converter.dart';
import 'package:dart_shield/src/security_analyzer/configuration/lint_rule_converter.dart';
import 'package:dart_shield/src/security_analyzer/exceptions/exceptions.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/lint_rule.dart';
import 'package:dart_shield/src/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yaml/yaml.dart';

part 'shield_config.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.kebab,
  converters: [LintRuleConverter(), GlobConverter()],
  createToJson: false,
)
class ShieldConfig {
  ShieldConfig({
    this.rules = const [],
    this.experimentalRules = const [],
    this.enableExperimental = false,
    this.exclude = const [],
  }) {
    _verifyValidity();
  }

  factory ShieldConfig.fromYaml(Map<String, dynamic> yaml) {
    final config = yaml['shield'] as Map<String, dynamic>;
    return _$ShieldConfigFromJson(config);
  }

  factory ShieldConfig.fromFile(String path) {
    final content = File(path).readAsStringSync();
    final dartMap = yamlToDartMap(loadYaml(content)) as Map<String, dynamic>;
    return ShieldConfig.fromYaml(dartMap);
  }

  // Verifies the validity of the configuration
  void _verifyValidity() {
    // Ensure no experimental rules are in the main rules list
    if (rules.any((rule) => rule.status == RuleStatus.experimental)) {
      throw const InvalidConfigurationException(
        'Rules with status experimental are not allowed in the rules list',
      );
    }

    // Ensure experimental rules are only allowed if the experimental flag is
    // enabled
    if (!enableExperimental && experimentalRules.isNotEmpty) {
      throw const InvalidConfigurationException(
        'Experimental rules are not allowed when the experimental flag is '
        'disabled',
      );
    }

    // Ensure only experimental rules are in the experimental rules list
    if (experimentalRules
        .any((rule) => rule.status != RuleStatus.experimental)) {
      throw const InvalidConfigurationException(
        'Only rules with status experimental are allowed in the experimental '
        'rules list',
      );
    }
  }

  List<String> exclude;
  List<LintRule> rules;
  bool enableExperimental;
  List<LintRule> experimentalRules;

  List<LintRule> get allRules => [...rules, ...experimentalRules];
}
