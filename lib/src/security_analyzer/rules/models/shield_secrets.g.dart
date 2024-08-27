// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shield_secrets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShieldSecrets _$ShieldSecretsFromJson(Map<String, dynamic> json) =>
    ShieldSecrets(
      version: json['version'] as String,
      secrets: (json['secrets'] as List<dynamic>)
          .map((e) => MatchingPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      keys: (json['keys'] as List<dynamic>)
          .map((e) => MatchingPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
