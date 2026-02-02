/// Represents a rule for detecting a specific type of secret.
class SecretRule {
  const SecretRule({
    required this.id,
    required this.description,
    required this.pattern,
    this.keywords = const [],
    this.minEntropy = 0.0,
  });

  factory SecretRule.fromJson(Map<String, dynamic> json) {
    return SecretRule(
      id: json['id'] as String,
      description: json['description'] as String,
      pattern: RegExp(
        json['pattern'] as String,
        caseSensitive: json['isCaseSensitive'] as bool? ?? true,
        multiLine: json['isMultiLine'] as bool? ?? false,
      ),
      keywords: (json['keywords'] as List?)?.cast<String>() ?? const [],
      minEntropy: (json['minEntropy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Unique identifier for the rule (e.g., 'aws-access-key').
  final String id;

  /// Human-readable description of what this rule detects.
  final String description;

  /// The Regular Expression used to find potential secrets.
  final RegExp pattern;

  /// A list of keywords to optimize the search.
  /// The scanner can skip the regex check if none of these keywords are present
  /// in the context (variable name, string content, etc.).
  ///
  /// If empty, the regex is always checked (slower).
  final List<String> keywords;

  /// The minimum Shannon Entropy required for a match to be considered valid.
  ///
  /// Many secrets (like API keys) appear random and thus have high entropy.
  /// Setting a threshold helps reduce false positives from regular English
  /// words or low-entropy test strings that might match the regex.
  ///
  /// A value of 0.0 disables this check.
  final double minEntropy;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'pattern': pattern.pattern,
      'isCaseSensitive': pattern.isCaseSensitive,
      'isMultiLine': pattern.isMultiLine,
      'keywords': keywords,
      'minEntropy': minEntropy,
    };
  }
}
