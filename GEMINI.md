# Dart Shield

**Project Type:** Dart/Flutter CLI Application
**Status:** Under Construction (Prototype/Dev)

## Overview
`dart_shield` is an open-source static analysis tool designed to secure Dart codebases by detecting potential vulnerabilities before they reach production. It functions similarly to a linter but focuses specifically on security flaws.

## Key Features
- **Hardcoded Secret Detection:** Identifies API keys, passwords, and other sensitive data.
- **Insecure Connection Detection:** Flags usage of HTTP instead of HTTPS.
- **Weak Cryptography Detection:** Warns against weak hashing algorithms (MD5, SHA-1) and insecure random number generators.
- **Configurable:** Uses `shield_options.yaml` for project-specific configuration.

## Architecture
The project follows a standard Dart CLI structure:

- **Entry Point:** `bin/dart_shield.dart` initializes the `ShieldCommandRunner`.
- **CLI Layer:** `lib/src/cli/` handles command parsing (`init`, `analyze`) using `package:args`.
- **Core Engine:** `lib/src/core/` contains `ShieldRunner` and `AnalyzerEngine` which orchestrate the analysis process.
- **Analyzers:**
  - `CodeAnalyzer` (`lib/src/analyzers/code/`): Wraps `dart analyze` (currently WIP).
  - **Rules:** defined in `lib/src/analyzers/code/rules/`.
- **Configuration:** `lib/src/configuration/` manages loading and parsing of `shield_options.yaml`.
- **Reporting:** `lib/src/reporters/` handles output formatting (Console, JSON).

## Development

### Prerequisites
- Dart SDK: `>=3.10.0 <4.0.0`

### Building and Running
To run the CLI from source:
```bash
dart run bin/dart_shield.dart [command]
# Example:
dart run bin/dart_shield.dart analyze
```

### Testing
Run unit tests:
```bash
dart test
```

### Code Style
The project uses `very_good_analysis` for linting.
```bash
dart analyze
```

## Key Files & Directories
- `bin/dart_shield.dart`: Main entry point.
- `lib/src/cli/commands/`: Implementation of `init` and `analyze` commands.
- `lib/src/analyzers/code/rules/`: specific security rules (e.g., `avoid_hardcoded_secrets.dart`).
- `shield_options.yaml`: (User-side) Configuration file for the tool.
- `analysis_options.yaml`: (Dev-side) Linter configuration for the project itself.
## Documentation Style
- All documentation must follow [Google Developer Documentation Style Guide](https://developers.google.com/style/).
- Tone: Professional, clear, concise, and direct.
- Structure: Use the agreed-upon template for rule documentation (Description, Non-Compliant/Compliant Code, How to Fix, Why, When to Ignore, Resources).

## Rule Documentation Template
Refer to `docs/rulebook/RULE_TEMPLATE.mdx` for the mandatory structure of rule documentation files.
