import 'package:json_annotation/json_annotation.dart';

part 'sarif_message.g.dart';

/// A message in SARIF format.
///
/// SARIF messages contain at minimum a `text` field.
@JsonSerializable(includeIfNull: false, createFactory: false)
class SarifMessage {
  SarifMessage({required this.text});

  /// The message text.
  final String text;

  Map<String, dynamic> toJson() => _$SarifMessageToJson(this);
}
