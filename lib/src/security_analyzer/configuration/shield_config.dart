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
    try {
      final content = File(path).readAsStringSync();
      final dartMap = yamlToDartMap(loadYaml(content)) as Map<String, dynamic>;
      return ShieldConfig.fromYaml(dartMap);
    } on FileSystemException catch (e) {
      throw InvalidConfigurationException(
        'Could not read config file at $path: ${e.message}',
      );
    } on YamlException catch (e) {
      throw InvalidConfigurationException(
        'Invalid YAML in config file at $path: ${e.message}',
      );
    } catch (e) {
      throw InvalidConfigurationException(
        'Invalid configuration structure in $path: $e',
      );
    }
  }

  // Verifies the validity of the configuration
  void _verifyValidity() {
    // Ensure no experimental rules are in the main rules list
    final experimentalInMainRules = rules
        .where((rule) => rule.status == RuleStatus.experimental)
        .toList();
    if (experimentalInMainRules.isNotEmpty) {
      final ruleNames = experimentalInMainRules
          .map((rule) => rule.id.name)
          .join(', ');
      throw InvalidConfigurationException(
        'Found experimental rule(s) in the "rules" list: $ruleNames. '
        'Move these to "experimental-rules" list.',
      );
    }

    // Ensure experimental rules are only allowed if the experimental flag is
    // enabled
    if (!enableExperimental && experimentalRules.isNotEmpty) {
      final ruleNames = experimentalRules
          .map((rule) => rule.id.name)
          .join(', ');
      throw InvalidConfigurationException(
        'Found experimental rule(s) in "experimental-rules" list: $ruleNames, '
        'but "enable-experimental" is set to false. '
        'Set "enable-experimental" to true to use these rules.',
      );
    }

    // Ensure only experimental rules are in the experimental rules list
    final nonExperimentalInExperimentalRules = experimentalRules
        .where((rule) => rule.status != RuleStatus.experimental)
        .toList();
    if (nonExperimentalInExperimentalRules.isNotEmpty) {
      final ruleNames = nonExperimentalInExperimentalRules
          .map((rule) => rule.id.name)
          .join(', ');
      throw InvalidConfigurationException(
        'Found non-experimental rule(s) in "experimental-rules" list: '
        '$ruleNames. Move these to the "rules" list.',
      );
    }
  }

  List<String> exclude;
  List<LintRule> rules;
  bool enableExperimental;
  List<LintRule> experimentalRules;

  List<LintRule> get allRules => [...rules, ...experimentalRules];
}
