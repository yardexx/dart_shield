const minimalConfig = '''
shield:
  rules:
    - prefer_https_over_http
''';

const excludePathConfig = '''
shield:
  exclude:
    - 'example/bar.dart'
  rules:
    - prefer_https_over_http
''';

const excludeGlobConfig = '''
shield:
  exclude:
    - '**.g.dart'
  rules:
    - prefer_https_over_http
''';

const onlyExperimentalConfig = '''
shield:
  enable_experimental: true
  experimental_rules:
    - avoid_hardcoded_urls
''';

const completeConfig = '''
shield:
  exclude:
    - 'example/bar.dart'
  rules:
    - prefer_https_over_http
  enable_experimental: true
  experimental_rules:
    - avoid_hardcoded_urls
''';

const invalidConfig = '''
shield:
  exclude:
    - 'example/bar.dart'
  rules:
    - prefer_https_over_http
  enable_experimental: false
  experimental_rules:
    - avoid_hardcoded_urls
''';
