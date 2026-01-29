// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sarif_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$SarifResultToJson(SarifResult instance) =>
    <String, dynamic>{
      'ruleId': instance.ruleId,
      'level': _$SarifLevelEnumMap[instance.level]!,
      'message': instance.message.toJson(),
      'locations': instance.locations.map((e) => e.toJson()).toList(),
    };

const _$SarifLevelEnumMap = {
  SarifLevel.error: 'error',
  SarifLevel.warning: 'warning',
  SarifLevel.note: 'note',
  SarifLevel.none: 'none',
};
