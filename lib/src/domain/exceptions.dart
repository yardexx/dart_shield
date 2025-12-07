/// Base class for all exceptions thrown by dart_shield.
///
/// These exceptions represent "expected" failure modes (configuration errors, environment issues) that should be reported cleanly to the user,
/// as opposed to unexpected bugs (StateError, ArgumentError) which are crashes.
abstract class ShieldException implements Exception {
  const ShieldException(this.message, [this.suggestion]);

  /// A human-readable error message explaining what went wrong.
  final String message;

  /// An optional suggestion for the user on how to fix the issue.
  final String? suggestion;

  @override
  String toString() {
    if (suggestion != null) {
      return '$message\nTip: $suggestion';
    }
    return message;
  }
}

/// Thrown when there is an issue with the `shield_options.yaml` configuration.
class ConfigException extends ShieldException {
  const ConfigException(super.message, [super.suggestion]);
}

/// Thrown when an external process (like `dart analyze`) fails to start or
/// crashes unexpectedly.
class ShieldProcessException extends ShieldException {
  const ShieldProcessException(super.message, [super.suggestion]);
}

/// Thrown when the analysis engine encounters an error while processing files.
/// This is distinct from finding vulnerabilities (which is a success case).
class AnalysisException extends ShieldException {
  const AnalysisException(super.message, [super.suggestion]);
}
