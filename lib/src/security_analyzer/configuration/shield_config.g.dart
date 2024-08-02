// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shield_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShieldConfig _$ShieldConfigFromJson(Map<String, dynamic> json) => ShieldConfig(
      rules: (json['rules'] as List<dynamic>?)
              ?.map((e) => const LintRuleConverter().fromJson(e as String))
              .toList() ??
          const [],
      experimentalRules: (json['experimental-rules'] as List<dynamic>?)
              ?.map((e) => const LintRuleConverter().fromJson(e as String))
              .toList() ??
          const [],
      enableExperimental: json['enable-experimental'] as bool? ?? false,
      exclude: (json['exclude'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
