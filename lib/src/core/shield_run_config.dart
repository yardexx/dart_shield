import 'package:dart_shield/src/domain/analysis_issue.dart';

class ShieldRunConfig {
  const ShieldRunConfig({
    required this.paths,
    this.only = const [],
    this.exclude = const [],
    this.reporterMode = 'console',
    this.minSeverity = Severity.info,
    this.baselinePath,
  });

  final List<String> paths;
  final List<String> only;
  final List<String> exclude;
  final String reporterMode;

  /// Minimum severity level to report.
  /// Issues below this severity level will be filtered out.
  final Severity minSeverity;

  /// Path to the baseline file.
  /// Issues in the baseline will be filtered out.
  final String? baselinePath;

  /// Parses a severity string to the corresponding [Severity] enum.
  /// Returns [Severity.info] if the string is not recognized.
  static Severity parseSeverity(String value) {
    return switch (value.toLowerCase()) {
      'high' => Severity.high,
      'medium' => Severity.medium,
      'low' => Severity.low,
      'info' => Severity.info,
      _ => Severity.info,
    };
  }
}
