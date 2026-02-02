import 'package:json_annotation/json_annotation.dart';

import 'package:sarif/src/models/sarif_result.dart';
import 'package:sarif/src/models/sarif_tool.dart';

part 'sarif_run.g.dart';

/// A single run of a tool.
@JsonSerializable(
  includeIfNull: false,
  createFactory: false,
  explicitToJson: true,
)
class SarifRun {
  SarifRun({required this.tool, required this.results});

  /// The tool that performed this run.
  final SarifTool tool;

  /// The results produced during this run.
  final List<SarifResult> results;

  Map<String, dynamic> toJson() => _$SarifRunToJson(this);
}
