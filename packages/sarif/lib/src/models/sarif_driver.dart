import 'package:json_annotation/json_annotation.dart';

import 'package:sarif/src/models/sarif_rule.dart';

part 'sarif_driver.g.dart';

/// The tool component that performed the analysis.
@JsonSerializable(
  includeIfNull: false,
  createFactory: false,
  explicitToJson: true,
)
class SarifDriver {
  SarifDriver({
    required this.name,
    required this.version,
    required this.informationUri,
    this.rules = const [],
  });

  /// The name of the tool.
  final String name;

  /// The version of the tool.
  final String version;

  /// A URI where the tool can be found.
  final String informationUri;

  /// The rules defined by the tool.
  final List<SarifRule> rules;

  Map<String, dynamic> toJson() => _$SarifDriverToJson(this);
}
