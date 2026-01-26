# Package Extraction Candidates

This document identifies components within dart_shield that could potentially be extracted into independent, reusable packages.

## Overview

As dart_shield matures, certain internal modules have emerged as candidates for extraction into standalone packages. This follows the principle of building modular, reusable components that benefit the broader Dart ecosystem.

**Extraction Criteria:**
- Independence (minimal dart_shield-specific dependencies)
- Reusability (useful outside this project)
- Cohesion (related functionality grouped together)
- Complexity (worth the packaging overhead)

---

## Candidate 1: Secret Detection Engine

### Priority: ⭐⭐⭐ High Value

### Current Location

```
lib/src/analyzers/code/rules/secrets/
├── secret_rule.dart
├── secret_rules.dart
├── rule_provider.dart
└── avoid_hardcoded_secrets.dart

lib/src/analyzers/utils/
└── shannon_entropy.dart

rules.json (250+ patterns)
tool/generate_rules.dart
```

### What It Does

- **SecretRule data structure** - Defines patterns with id, regex, keywords, entropy threshold
- **250+ secret patterns** - Derived from Gitleaks, covering AWS, GCP, GitHub, Stripe, etc.
- **Shannon entropy calculation** - Reduces false positives by measuring randomness
- **Keyword optimization** - Skips expensive regex checks when keywords are absent
- **Pattern loading** - From embedded fallback or user cache

### Why Extract?

| Factor | Assessment |
|--------|------------|
| **Reuse Value** | High - CI bots, Git hooks, IDE plugins, other SAST tools |
| **Independence** | High - `SecretRule` already has zero dart_shield imports |
| **Completeness** | High - Patterns + matching logic + entropy = full solution |
| **Uniqueness** | High - No comprehensive Dart secret detection package exists |

### Proposed Package Name

`secret_detector` or `secret_patterns`

### Proposed Structure (Internal Modularization First)

```
lib/src/secret_detector/                # Zero dart_shield imports
├── secret_rule.dart                    # Data structure
├── secret_matcher.dart                 # Matching logic
├── entropy.dart                        # Shannon entropy
├── patterns/
│   ├── pattern_loader.dart             # Load from JSON/embedded
│   └── builtin_patterns.dart           # 250+ embedded rules
└── secret_detector.dart                # Public API

lib/src/analyzers/code/rules/secrets/
└── avoid_hardcoded_secrets.dart        # Adapter using secret_detector
```

### Proposed Public API

```dart
import 'package:secret_detector/secret_detector.dart';

// Simple usage
final detector = SecretDetector();
final matches = detector.scan('const apiKey = "AKIAIOSFODNN7EXAMPLE"');
// Returns: [SecretMatch(ruleId: 'aws-access-token', ...)]

// With context for better detection
final matches = detector.scanWithContext(
  value: 'sk_live_abc123...',
  variableName: 'stripeKey',
);

// Custom rules
final detector = SecretDetector(
  rules: [...defaultRules, ...customRules],
  minEntropy: 3.5,
);
```

---

## Candidate 2: Regex Sanitizer (PCRE/Go → Dart)

### Priority: ⭐⭐ Medium Value

### Current Location

```
tool/utils/regex_sanitizer.dart
```

### What It Does

- Converts Go/PCRE regex syntax to Dart-compatible patterns
- Handles inline flags: `(?i)`, `(?m)`, `(?s)`
- Converts scoped flags: `(?i:...)` → `(?:...)` + global flag
- Returns sanitized pattern with appropriate Dart RegExp flags

### Why Extract?

| Factor | Assessment |
|--------|------------|
| **Reuse Value** | Medium - Useful for porting regex from Python, Go, Ruby |
| **Independence** | Perfect - Zero imports, pure Dart |
| **Completeness** | Good - Handles common cases |
| **Uniqueness** | High - No existing package does this |

### Proposed Package Name

`regex_compat` or `pcre_to_dart`

### Current State

Already completely independent:

```dart
class RegexSanitizer {
  static SanitizedRegex sanitize(String rawPattern) {
    // Handles (?i), (?m), (?s), (?i:...), etc.
  }
}

class SanitizedRegex {
  final String pattern;
  final bool caseSensitive;
  final bool multiLine;
}
```

### Proposed Public API

```dart
import 'package:regex_compat/regex_compat.dart';

// Convert PCRE pattern to Dart
final result = RegexCompat.toDart('(?i)hello(?m:world)');
print(result.pattern);        // 'hello(?:world)'
print(result.caseSensitive);  // false
print(result.multiLine);      // true

// Direct RegExp creation
final regex = RegexCompat.compile('(?i)test');
```

---

## Candidate 3: SARIF Module

### Priority: ⭐⭐ Medium Value

### Current Location

To be created in Phase 2:

```
lib/src/reporters/sarif/
├── sarif_document.dart      # SARIF 2.1.0 data structures
├── sarif_builder.dart       # Fluent builder API
└── sarif_reporter.dart      # dart_shield adapter
```

### What It Does

- Generates SARIF 2.1.0 compliant JSON output
- Data structures for Tool, Rule, Result, Location
- Builder pattern for easy document construction

### Why Extract?

| Factor | Assessment |
|--------|------------|
| **Reuse Value** | Medium - Any Dart static analysis tool |
| **Independence** | Will be designed with zero dart_shield imports |
| **Completeness** | Good - Full SARIF 2.1.0 support planned |
| **Uniqueness** | High - No well-maintained Dart SARIF package |

### Proposed Package Name

`sarif` or `sarif_dart`

### Proposed Public API

```dart
import 'package:sarif/sarif.dart';

final builder = SarifBuilder(
  toolName: 'my_analyzer',
  toolVersion: '1.0.0',
  toolUri: 'https://example.com',
);

builder.addResult(
  ruleId: 'my_rule',
  message: 'Issue found',
  level: SarifLevel.warning,
  filePath: 'lib/main.dart',
  line: 10,
  column: 5,
);

final json = builder.buildJson();
```

---

## Candidate 4: Shannon Entropy

### Priority: ⭐ Low Value

### Current Location

```
lib/src/analyzers/utils/shannon_entropy.dart
```

### What It Does

- Calculates Shannon entropy of a string (in bits)
- Measures "randomness" or information density
- Used to distinguish secrets from regular strings

### Why NOT Extract (Yet)?

| Factor | Assessment |
|--------|------------|
| **Reuse Value** | Medium - Password strength, compression analysis |
| **Independence** | Perfect - Only imports `dart:math` |
| **Completeness** | Good - Single function, well-tested |
| **Size** | Too small - 35 lines, single static method |

### Recommendation

**Keep as-is.** The file is already extraction-ready (zero dependencies). If there's community demand, it can be published as `shannon_entropy` with minimal effort. For now, including it in `secret_detector` makes more sense.

---

## Extraction Timeline

| Phase | Package | Action |
|-------|---------|--------|
| **Phase 2** | SARIF | Implement as internal module with zero deps |
| **Phase 3** | Secret Detector | Refactor into internal module |
| **Future** | All | Evaluate demand, publish to pub.dev if warranted |

---

## Internal Modularization Pattern

Before extracting to pub.dev, use the "fake internal package" pattern:

1. **Create isolated folder** with zero dart_shield imports
2. **Design clean public API** that doesn't expose dart_shield types
3. **Use adapter pattern** to integrate with dart_shield
4. **Test independently** with pure unit tests
5. **Evaluate** - if there's demand, publish to pub.dev

### Example Structure

```
lib/src/
├── secret_detector/           # Can be extracted to package
│   ├── src/                   # Implementation (zero dart_shield imports)
│   │   ├── rule.dart
│   │   ├── matcher.dart
│   │   └── entropy.dart
│   └── secret_detector.dart   # Public API barrel file
│
└── analyzers/code/rules/secrets/
    └── avoid_hardcoded_secrets.dart   # Adapter (imports both)
```

---

## Decision Checklist

Before extracting a component to pub.dev:

- [ ] Is there external demand? (GitHub issues, community requests)
- [ ] Does it have comprehensive tests?
- [ ] Is the API stable and well-documented?
- [ ] Is there no existing well-maintained alternative?
- [ ] Is the maintenance burden acceptable?
- [ ] Does extraction benefit dart_shield users? (smaller install, optional deps)

---

## References

- [Dart Package Layout Conventions](https://dart.dev/tools/pub/package-layout)
- [SARIF Specification](https://sarifweb.azurewebsites.net/)
- [Gitleaks Patterns](https://github.com/gitleaks/gitleaks)
- [Shannon Entropy](https://en.wikipedia.org/wiki/Entropy_(information_theory))
