import 'package:json_annotation/json_annotation.dart';

import 'package:sarif/src/models/sarif_artifact_location.dart';
import 'package:sarif/src/models/sarif_region.dart';

part 'sarif_physical_location.g.dart';

/// A physical location in an artifact.
@JsonSerializable(
  includeIfNull: false,
  createFactory: false,
  explicitToJson: true,
)
class SarifPhysicalLocation {
  SarifPhysicalLocation({
    required this.artifactLocation,
    required this.region,
  });

  /// The artifact location.
  final SarifArtifactLocation artifactLocation;

  /// The region within the artifact.
  final SarifRegion region;

  Map<String, dynamic> toJson() => _$SarifPhysicalLocationToJson(this);
}
