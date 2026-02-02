import 'package:dart_shield/src/domain/analysis_issue.dart';

/// Metadata for security rules including severity and documentation links.
class RuleMetadata {
  const RuleMetadata({
    required this.ruleId,
    required this.severity,
    this.owaspCategory,
    this.cweId,
    this.documentationUrl,
  });

  final String ruleId;
  final Severity severity;
  final String? owaspCategory;
  final String? cweId;
  final String? documentationUrl;
}

/// Registry of all rule metadata.
///
/// Each rule is categorized by severity level and mapped to relevant
/// security standards (OWASP, CWE).
const Map<String, RuleMetadata> ruleMetadataRegistry = {
  'avoid_hardcoded_secrets': RuleMetadata(
    ruleId: 'avoid_hardcoded_secrets',
    severity: Severity.high,
    owaspCategory: 'A02:2021 Cryptographic Failures',
    cweId: 'CWE-798',
    documentationUrl:
        'https://dart-shield.dev/rulebook/secrets/avoid-hardcoded-secrets',
  ),
  'prefer_https_over_http': RuleMetadata(
    ruleId: 'prefer_https_over_http',
    severity: Severity.high,
    owaspCategory: 'A02:2021 Cryptographic Failures',
    cweId: 'CWE-319',
    documentationUrl:
        'https://dart-shield.dev/rulebook/network/prefer-https-over-http',
  ),
  'avoid_weak_hashing': RuleMetadata(
    ruleId: 'avoid_weak_hashing',
    severity: Severity.medium,
    owaspCategory: 'A02:2021 Cryptographic Failures',
    cweId: 'CWE-328',
    documentationUrl:
        'https://dart-shield.dev/rulebook/cryptography/avoid-weak-hashing',
  ),
  'prefer_secure_random': RuleMetadata(
    ruleId: 'prefer_secure_random',
    severity: Severity.medium,
    owaspCategory: 'A02:2021 Cryptographic Failures',
    cweId: 'CWE-330',
    documentationUrl:
        'https://dart-shield.dev/rulebook/cryptography/prefer-secure-random',
  ),
  'avoid_hardcoded_urls': RuleMetadata(
    ruleId: 'avoid_hardcoded_urls',
    severity: Severity.low,
    owaspCategory: 'A05:2021 Security Misconfiguration',
    cweId: 'CWE-547',
    documentationUrl:
        'https://dart-shield.dev/rulebook/network/avoid-hardcoded-urls',
  ),
};

/// Gets the metadata for a rule by its ID.
///
/// Returns null if the rule ID is not found in the registry.
RuleMetadata? getRuleMetadata(String ruleId) => ruleMetadataRegistry[ruleId];

/// Gets the severity for a rule by its ID.
///
/// Returns [Severity.info] if the rule ID is not found in the registry.
Severity getSeverityForRule(String ruleId) {
  return ruleMetadataRegistry[ruleId]?.severity ?? Severity.info;
}
