import 'dart:io';

import 'package:dart_shield/src/security_analyzer/rules/models/matching_pattern.dart';
import 'package:dart_shield/src/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yaml/yaml.dart';

part 'shield_secrets.g.dart';

@JsonSerializable(fieldRename: FieldRename.kebab, createToJson: false)
class ShieldSecrets {
  ShieldSecrets({
    required this.version,
    required this.secrets,
    required this.keys,
  });

  factory ShieldSecrets.preset() {
    final content = File(_defaultConfigPath).readAsStringSync();
    final dartMap = yamlToDartMap(loadYaml(content)) as Map<String, dynamic>;
    return ShieldSecrets.fromYaml(dartMap);
  }

  factory ShieldSecrets.fromYaml(Map<String, dynamic> json) {
    final config = json[_yamlRootKey] as Map<String, dynamic>;
    return _$ShieldSecretsFromJson(config);
  }

  static const _defaultConfigPath = '../rules_list/utils/shield_secrets.yaml';
  static const _yamlRootKey = 'shield_patterns';

  final String version;
  final List<MatchingPattern> secrets;
  final List<MatchingPattern> keys;

  bool containsSecret(String value) =>
      secrets.any((p) => p.regex.hasMatch(value) || p.regex.hasMatch(value));
}
