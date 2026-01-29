import 'package:json_annotation/json_annotation.dart';

part 'sarif_artifact_location.g.dart';

/// Specifies the location of an artifact.
@JsonSerializable(includeIfNull: false, createFactory: false)
class SarifArtifactLocation {
  SarifArtifactLocation({required this.uri});

  /// A URI that identifies the artifact.
  final String uri;

  Map<String, dynamic> toJson() => _$SarifArtifactLocationToJson(this);
}
