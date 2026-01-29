import 'package:json_annotation/json_annotation.dart';

import 'package:dart_shield/src/reporters/sarif/models/sarif_message.dart';

part 'sarif_rule.g.dart';

/// A rule (also called a "reporting descriptor") defined by a SARIF tool.
@JsonSerializable(includeIfNull: false, createFactory: false, explicitToJson: true)
class SarifRule {
  SarifRule({
    required this.id,
    required this.shortDescription,
    this.fullDescription,
    this.helpUri,
  });

  /// The rule identifier.
  final String id;

  /// A short description of the rule.
  final SarifMessage shortDescription;

  /// A full description of the rule.
  final SarifMessage? fullDescription;

  /// A URI where help for the rule can be found.
  final String? helpUri;

  Map<String, dynamic> toJson() => _$SarifRuleToJson(this);
}
