// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shield_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShieldConfig _$ShieldConfigFromJson(Map json) =>
    $checkedCreate('ShieldConfig', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['analyzers']);
      final val = ShieldConfig(
        analyzers: $checkedConvert(
          'analyzers',
          (v) => v == null
              ? const ShieldAnalyzersConfig()
              : ShieldAnalyzersConfig.fromJson(v as Map),
        ),
      );
      return val;
    });

ShieldAnalyzersConfig _$ShieldAnalyzersConfigFromJson(Map json) =>
    $checkedCreate('ShieldAnalyzersConfig', json, ($checkedConvert) {
      final val = ShieldAnalyzersConfig(
        code: $checkedConvert('code', (v) => v as bool? ?? true),
        deps: $checkedConvert('deps', (v) => v as bool? ?? true),
      );
      return val;
    });
