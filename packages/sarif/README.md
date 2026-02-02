# SARIF

A Dart library for creating SARIF 2.1.0 (Static Analysis Results Interchange Format) documents.

## Features

- Complete SARIF 2.1.0 data model
- Fluent builder API for easy document creation
- JSON serialization via `json_serializable`
- No external dependencies beyond `json_annotation`

## Usage

```dart
import 'package:sarif/sarif.dart';

void main() {
  final builder = SarifBuilder(
    toolName: 'my_analyzer',
    toolVersion: '1.0.0',
    toolUri: 'https://example.com/my_analyzer',
  );

  builder.addResult(
    ruleId: 'no_hardcoded_secrets',
    message: 'Hardcoded API key detected',
    level: SarifLevel.error,
    filePath: 'lib/config.dart',
    line: 10,
    column: 5,
    ruleDescription: 'Detects hardcoded secrets in source code',
    ruleHelpUri: 'https://example.com/rules/no_hardcoded_secrets',
  );

  final json = builder.buildJson();
  print(json);
}
```

## SARIF Specification

This library implements the [SARIF 2.1.0 specification](https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html).

## License

MIT
