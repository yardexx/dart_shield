import 'package:json_annotation/json_annotation.dart';

part 'sarif_region.g.dart';

/// A region within an artifact.
@JsonSerializable(includeIfNull: false, createFactory: false)
class SarifRegion {
  SarifRegion({
    required this.startLine,
    required this.startColumn,
    this.endLine,
    this.endColumn,
  });

  /// The line number of the first character in the region (1-based).
  final int startLine;

  /// The column number of the first character in the region (1-based).
  final int startColumn;

  /// The line number of the last character in the region (1-based).
  final int? endLine;

  /// The column number of the last character in the region (1-based).
  final int? endColumn;

  Map<String, dynamic> toJson() => _$SarifRegionToJson(this);
}
