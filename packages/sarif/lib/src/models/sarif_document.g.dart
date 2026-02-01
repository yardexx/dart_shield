// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sarif_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$SarifDocumentToJson(SarifDocument instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'version': instance.version,
      'runs': instance.runs.map((e) => e.toJson()).toList(),
    };
