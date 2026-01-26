/// An entry in the baseline file.
class BaselineEntry {
  BaselineEntry({
    required this.ruleId,
    required this.file,
    required this.line,
    required this.fingerprint,
  });

  /// The rule ID.
  final String ruleId;

  /// The file path.
  final String file;

  /// The line number.
  final int line;

  /// The fingerprint (hash of rule, file, line).
  final String fingerprint;
}
