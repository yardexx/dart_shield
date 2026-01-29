import 'package:json_annotation/json_annotation.dart';

import 'package:dart_shield/src/reporters/sarif/models/sarif_level.dart';
import 'package:dart_shield/src/reporters/sarif/models/sarif_location.dart';
import 'package:dart_shield/src/reporters/sarif/models/sarif_message.dart';

part 'sarif_result.g.dart';

/// A single result (finding) in a SARIF document.
@JsonSerializable(includeIfNull: false, createFactory: false, explicitToJson: true)
class SarifResult {
  SarifResult({
    required this.ruleId,
    required this.level,
    required this.message,
    required this.locations,
  });

  /// The rule that produced this result.
  final String ruleId;

  /// The severity level.
  final SarifLevel level;

  /// The message describing the result.
  final SarifMessage message;

  /// The locations where the result was found.
  final List<SarifLocation> locations;

  Map<String, dynamic> toJson() => _$SarifResultToJson(this);
}
