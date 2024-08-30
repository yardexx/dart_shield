// Copy of [shield_secrets.dart] because Dart doesn't support assets.
// TODO: Remove this file once Dart supports assets: https://github.com/dart-lang/sdk/issues/53562

const String shieldSecretsSource = r'''
shield_patterns:
  version: 0.1.0-dev.1
  secrets:
    - name: 'Gitlab Personal Access Token'
      pattern: 'glpat-[0-9a-zA-Z_\-]{20}'
    - name: 'GitHub Personal Access Token'
      pattern: 'ghp_[0-9a-zA-Z]{36}'
    - name: 'GitHub OAuth Token'
      pattern: 'gho_[0-9a-zA-Z]{36}'
    - name: 'GitHub App Token'
      pattern: '(ghu|ghs)_[0-9a-zA-Z]{36}'
    - name: 'AWS Access Token'
      pattern: 'AKIA[0-9A-Z]{16}'
    - name: 'Stripe Live API Key'
      pattern: 'sk_live_[0-9a-zA-Z]{24}'
    - name: 'Google API Key'
      pattern: 'AIza[0-9A-Za-z\\-_]{35}'
    - name: 'Google Cloud Platform Service Account Key'
      pattern: '\"type\": \"service_account\"'
    - name: 'URL with password'
      pattern: '[a-zA-Z]{3,10}:\/\/[^$][^:@\/\n]{3,20}:[^$][^:@\n\/]{3,40}@.{1,100}'
  keys:
    - name: 'RSA Private Key'
      pattern: '-----BEGIN'
''';