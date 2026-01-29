import 'package:json_annotation/json_annotation.dart';

import 'package:sarif/src/models/sarif_physical_location.dart';

part 'sarif_location.g.dart';

/// A location in a SARIF result.
@JsonSerializable(
  includeIfNull: false,
  createFactory: false,
  explicitToJson: true,
)
class SarifLocation {
  SarifLocation({required this.physicalLocation});

  /// The physical location.
  final SarifPhysicalLocation physicalLocation;

  Map<String, dynamic> toJson() => _$SarifLocationToJson(this);
}
