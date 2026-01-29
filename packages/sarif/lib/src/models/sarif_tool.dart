import 'package:json_annotation/json_annotation.dart';

import 'package:sarif/src/models/sarif_driver.dart';

part 'sarif_tool.g.dart';

/// Information about the tool that produced the SARIF results.
@JsonSerializable(
  includeIfNull: false,
  createFactory: false,
  explicitToJson: true,
)
class SarifTool {
  SarifTool({required this.driver});

  /// The tool driver (component that performed the analysis).
  final SarifDriver driver;

  Map<String, dynamic> toJson() => _$SarifToolToJson(this);
}
