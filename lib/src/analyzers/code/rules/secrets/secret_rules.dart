import 'package:dart_shield/src/analyzers/code/rules/secrets/secret_rule.dart';

/// Collection of predefined rules for detecting secrets.
class SecretRules {
  static final List<SecretRule> custom = [
    // Generic High Entropy Assignment
    // Catches things that look like random tokens assigned to suspicious
    // variables.
    // Note: This rule relies heavily on context checks (variable names) which
    // will be implemented in the scanner logic, but the keywords here guide
    // that.
    SecretRule(
      id: 'generic-api-key',
      description: 'Potential high-entropy API key or secret detected.',
      // Matches a contiguous string of 20+ alphanumeric characters/symbols.
      pattern: RegExp(r'[a-zA-Z0-9_+=\-/]{20,}'),
      keywords: [
        'key',
        'api',
        'token',
        'secret',
        'password',
        'auth',
        'credential',
      ],
      // High entropy threshold to avoid flagging regular long words or URLs.
      // A random 20-char hex string has an entropy of ~4 bits.
      minEntropy: 3,
    ),
  ];
}
