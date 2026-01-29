import 'package:json_annotation/json_annotation.dart';

import 'package:dart_shield/src/reporters/sarif/models/sarif_run.dart';

part 'sarif_document.g.dart';

/// A SARIF 2.1.0 document.
@JsonSerializable(includeIfNull: false, createFactory: false, explicitToJson: true)
class SarifDocument {
  SarifDocument({required this.runs});

  /// SARIF schema URL.
  @JsonKey(name: r'$schema')
  final String schema = _schema;

  /// SARIF version.
  final String version = _version;

  /// The runs contained in this document.
  final List<SarifRun> runs;

  /// The SARIF schema URL.
  static const String _schema =
      'https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json';

  /// The SARIF version.
  static const String _version = '2.1.0';

  Map<String, dynamic> toJson() => _$SarifDocumentToJson(this);
}
