import 'package:json_annotation/json_annotation.dart';

/// SARIF severity levels.
@JsonEnum(alwaysCreate: true)
enum SarifLevel {
  /// An error.
  error,

  /// A warning.
  warning,

  /// A note (informational).
  note,

  /// No level assigned.
  none,
}
