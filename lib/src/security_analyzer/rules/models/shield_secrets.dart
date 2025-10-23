import 'package:dart_shield/assets/assets.dart';
import 'package:dart_shield/src/security_analyzer/rules/models/matching_pattern.dart';
import 'package:dart_shield/src/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yaml/yaml.dart';

part 'shield_secrets.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ShieldSecrets {
  ShieldSecrets({
    required this.version,
    required this.secrets,
    required this.keys,
  });

  factory ShieldSecrets.preset() {
    // Workaround: Using assets.dart instead of native asset support
    // See: https://github.com/dart-lang/sdk/issues/53562
    // TODO: Migrate to native assets when Dart SDK supports it
    // final content = File(_defaultConfigPath).readAsStringSync();
    const content = shieldSecretsSource;
    final dartMap = yamlToDartMap(loadYaml(content)) as Map<String, dynamic>;
    return ShieldSecrets.fromYaml(dartMap);
  }

  factory ShieldSecrets.fromYaml(Map<String, dynamic> json) {
    final config = json[_yamlRootKey] as Map<String, dynamic>;
    return _$ShieldSecretsFromJson(config);
  }

  // Workaround: Using assets.dart instead of native asset support
  // See: https://github.com/dart-lang/sdk/issues/53562
  // TODO: Migrate to native assets when Dart SDK supports it
  // static const _defaultConfigPath = '../rules_list/utils/shield_secrets.yaml';
  static const _yamlRootKey = 'shield_patterns';

  final String version;
  final List<MatchingPattern> secrets;
  final List<MatchingPattern> keys;

  bool containsSecret(String value) =>
      secrets.any((p) => p.regex.hasMatch(value)) ||
      keys.any((p) => p.regex.hasMatch(value));
}
