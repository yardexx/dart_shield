const minimalConfig = '''
shield:
  rules:
    - prefer-https-over-http
''';

const excludePathConfig = '''
shield:
  exclude:
    - 'example/bar.dart'
  rules:
    - prefer-https-over-http
''';

const excludeGlobConfig = '''
shield:
  exclude:
    - '**.g.dart'
  rules:
    - prefer-https-over-http
''';

const onlyExperimentalConfig = '''
shield:
  enable-experimental: true
  experimental-rules:
    - avoid-hardcoded-urls
''';

const completeConfig = '''
shield:
  exclude:
    - 'example/bar.dart'
  rules:
    - prefer-https-over-http
  enable-experimental: true
  experimental-rules:
    - avoid-hardcoded-urls
''';

const invalidConfig = '''
shield:
  exclude:
    - 'example/bar.dart'
  rules:
    - prefer-https-over-http
  enable-experimental: false
  experimental-rules:
    - avoid-hardcoded-urls
''';
