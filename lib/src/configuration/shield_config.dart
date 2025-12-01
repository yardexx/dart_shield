import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shield_config.g.dart';

@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class ShieldConfig {
  const ShieldConfig({
    this.analyzers = const ShieldAnalyzersConfig(),
  });

  factory ShieldConfig.fromJson(Map<dynamic, dynamic> map) =>
      _$ShieldConfigFromJson(map);

  final ShieldAnalyzersConfig analyzers;

  static Future<ShieldConfig> load() async {
    final file = File('analysis_options.yaml');
    if (!file.existsSync()) return const ShieldConfig();

    final content = await file.readAsString();
    if (content.trim().isEmpty) return const ShieldConfig();

    try {
      return checkedYamlDecode(
        content,
        (m) {
          if (m != null && m['dart_shield'] is Map) {
            return ShieldConfig.fromJson(m['dart_shield'] as Map);
          }

          return const ShieldConfig();
        },
        sourceUrl: file.uri,
      );
    } on ParsedYamlException catch (e) {
      // TODO: Better error handling
      print('⚠️ Configuration Error: ${e.formattedMessage}');
      return const ShieldConfig();
    }
  }
}

@JsonSerializable(anyMap: true, checked: true)
class ShieldAnalyzersConfig {
  const ShieldAnalyzersConfig({
    this.code = true,
    this.deps = true,
  });

  factory ShieldAnalyzersConfig.fromJson(Map<dynamic, dynamic> map) =>
      _$ShieldAnalyzersConfigFromJson(map);

  @JsonKey(defaultValue: true)
  final bool code;

  @JsonKey(defaultValue: true)
  final bool deps;
}
