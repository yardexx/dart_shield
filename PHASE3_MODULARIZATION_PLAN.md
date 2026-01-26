# Phase 3: Internal Modularization - Implementation Plan

## Overview

This document outlines the implementation plan for modularizing key components of dart_shield into extraction-ready internal modules. The goal is to structure code so it can eventually be published as standalone packages while remaining integrated with dart_shield.

**Prerequisites:** Phase 1 and Phase 2 should be completed  
**Estimated Scope:** 2 major refactoring tasks  
**Development Approach:** Test-Driven Development (TDD)

**Key Principle:** Modularized components must have **ZERO imports from `dart_shield`** in their core files. They work with generic types only.

---

## Development Workflow

### Branch Naming Convention

```
refactor/<module-name>-modularization
```

Examples:
- `refactor/secret-detector-modularization`
- `refactor/regex-compat-modularization`

### TDD Process

1. **Write tests first** for the new modular API
2. **Run tests (expect failure)** - Confirm tests fail
3. **Move/refactor code** into modular structure
4. **Run tests (should pass)** - Both new and existing tests
5. **Update adapter** to use new module
6. **Run full test suite** - Ensure no regressions

---

## Task 1: Secret Detector Module

### Priority: P1 (High)

### Branch: `refactor/secret-detector-modularization`

### Context

The secret detection logic is currently spread across multiple files and tightly coupled to dart_shield. This refactoring extracts it into a self-contained module that could eventually become `package:secret_detector`.

### Current Structure

```
lib/src/analyzers/
├── code/rules/secrets/
│   ├── avoid_hardcoded_secrets.dart    # Analysis rule (uses SecretRule)
│   ├── rule_provider.dart              # Loads rules from cache/fallback
│   ├── secret_rule.dart                # Data structure
│   └── secret_rules.dart               # Custom rules
└── utils/
    └── shannon_entropy.dart            # Entropy calculation
```

### Target Structure

```
lib/src/
├── secret_detector/                     # Independent module (ZERO dart_shield imports)
│   ├── src/
│   │   ├── entropy.dart                 # Shannon entropy (moved)
│   │   ├── secret_rule.dart             # Data structure (moved)
│   │   ├── secret_matcher.dart          # NEW: Core matching logic
│   │   └── patterns/
│   │       ├── builtin_patterns.dart    # Embedded 250+ rules
│   │       └── pattern_loader.dart      # Load from JSON
│   └── secret_detector.dart             # Public API barrel file
│
└── analyzers/code/rules/secrets/
    ├── avoid_hardcoded_secrets.dart     # Adapter: uses secret_detector
    └── rule_provider.dart               # Simplified: delegates to module
```

### Implementation Steps

#### Step 1.1: Write Tests for New Module API

**File: `test/src/secret_detector/secret_detector_test.dart`**

```dart
import 'package:dart_shield/src/secret_detector/secret_detector.dart';
import 'package:test/test.dart';

void main() {
  group('SecretDetector', () {
    late SecretDetector detector;

    setUp(() {
      detector = SecretDetector();
    });

    test('detects AWS access key', () {
      final matches = detector.scan('AKIAIOSFODNN7EXAMPLE');
      
      expect(matches, isNotEmpty);
      expect(matches.first.ruleId, contains('aws'));
    });

    test('detects GitHub token', () {
      final matches = detector.scan('ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
      
      expect(matches, isNotEmpty);
      expect(matches.first.ruleId, contains('github'));
    });

    test('ignores low entropy strings', () {
      final matches = detector.scan('aaaaaaaaaaaaaaaaaaaa');
      
      expect(matches, isEmpty);
    });

    test('ignores short strings', () {
      final matches = detector.scan('short');
      
      expect(matches, isEmpty);
    });

    test('scanWithContext uses variable name for keyword matching', () {
      // This string alone might not trigger, but with apiKey context it should
      final matches = detector.scanWithContext(
        value: 'sk_live_1234567890abcdef1234',
        context: SecretContext(variableName: 'stripeApiKey'),
      );
      
      expect(matches, isNotEmpty);
    });

    test('respects custom entropy threshold', () {
      final strictDetector = SecretDetector(minEntropyOverride: 5.0);
      
      // Medium entropy string that would normally match
      final matches = strictDetector.scan('abc123def456ghi789');
      
      expect(matches, isEmpty);
    });

    test('allows custom rules', () {
      final customDetector = SecretDetector(
        additionalRules: [
          SecretRule(
            id: 'custom-test',
            description: 'Test rule',
            pattern: RegExp(r'CUSTOM_[A-Z]{10}'),
            minEntropy: 0,
          ),
        ],
      );
      
      final matches = customDetector.scan('CUSTOM_ABCDEFGHIJ');
      
      expect(matches, hasLength(1));
      expect(matches.first.ruleId, 'custom-test');
    });
  });

  group('SecretMatch', () {
    test('contains rule info and matched value', () {
      final detector = SecretDetector();
      final matches = detector.scan('ghp_abcdefghijklmnopqrstuvwxyz123456');
      
      expect(matches.first.ruleId, isNotEmpty);
      expect(matches.first.description, isNotEmpty);
      expect(matches.first.matchedValue, isNotEmpty);
    });
  });
}
```

**File: `test/src/secret_detector/secret_matcher_test.dart`**

```dart
import 'package:dart_shield/src/secret_detector/src/secret_matcher.dart';
import 'package:dart_shield/src/secret_detector/src/secret_rule.dart';
import 'package:test/test.dart';

void main() {
  group('SecretMatcher', () {
    test('matches when pattern matches and entropy meets threshold', () {
      final rule = SecretRule(
        id: 'test',
        description: 'Test',
        pattern: RegExp(r'TEST_[A-Z0-9]{16}'),
        minEntropy: 3.0,
      );
      
      final matcher = SecretMatcher(rules: [rule]);
      final result = matcher.match('TEST_ABCD1234EFGH5678');
      
      expect(result, isNotNull);
      expect(result!.ruleId, 'test');
    });

    test('skips when keyword not present', () {
      final rule = SecretRule(
        id: 'test',
        description: 'Test',
        pattern: RegExp(r'[A-Z]{20}'),
        keywords: ['special'],
        minEntropy: 0,
      );
      
      final matcher = SecretMatcher(rules: [rule]);
      final result = matcher.match(
        'ABCDEFGHIJKLMNOPQRST',
        context: '', // No 'special' keyword
      );
      
      expect(result, isNull);
    });

    test('matches when keyword present in context', () {
      final rule = SecretRule(
        id: 'test',
        description: 'Test',
        pattern: RegExp(r'[A-Z]{20}'),
        keywords: ['apikey'],
        minEntropy: 0,
      );
      
      final matcher = SecretMatcher(rules: [rule]);
      final result = matcher.match(
        'ABCDEFGHIJKLMNOPQRST',
        context: 'myApiKey', // Contains 'apikey'
      );
      
      expect(result, isNotNull);
    });
  });
}
```

**File: `test/src/secret_detector/entropy_test.dart`**

```dart
// Move existing tests from test/src/analyzers/utils/shannon_entropy_test.dart
// Update imports to use new location
import 'package:dart_shield/src/secret_detector/src/entropy.dart';
import 'package:test/test.dart';

void main() {
  group('Entropy', () {
    test('returns 0.0 for empty string', () {
      expect(Entropy.calculate(''), 0.0);
    });

    test('returns 0.0 for identical characters', () {
      expect(Entropy.calculate('aaaaa'), 0.0);
    });

    test('calculates entropy for binary string', () {
      expect(Entropy.calculate('01'), closeTo(1.0, 0.0001));
    });

    test('calculates higher entropy for diverse set', () {
      expect(Entropy.calculate('abcd'), closeTo(2.0, 0.0001));
    });

    test('typical API key has high entropy', () {
      final low = Entropy.calculate('password123');
      final high = Entropy.calculate('7Fz92xK1qM4bJ8vR');
      expect(high, greaterThan(low));
    });
  });
}
```

#### Step 1.2: Create Module Structure

**File: `lib/src/secret_detector/secret_detector.dart`** (Public API)

```dart
/// Secret detection module for identifying hardcoded secrets in strings.
///
/// This module can detect 250+ types of secrets including API keys,
/// tokens, passwords, and other sensitive data.
///
/// Example:
/// ```dart
/// final detector = SecretDetector();
/// final matches = detector.scan('AKIAIOSFODNN7EXAMPLE');
/// ```
library secret_detector;

export 'src/entropy.dart' show Entropy;
export 'src/secret_matcher.dart' show SecretMatcher;
export 'src/secret_rule.dart' show SecretRule;

import 'src/patterns/builtin_patterns.dart';
import 'src/secret_matcher.dart';
import 'src/secret_rule.dart';

/// Main entry point for secret detection.
class SecretDetector {
  SecretDetector({
    List<SecretRule>? additionalRules,
    double? minEntropyOverride,
  }) : _matcher = SecretMatcher(
          rules: [
            ...BuiltinPatterns.all,
            ...?additionalRules,
          ],
          minEntropyOverride: minEntropyOverride,
        );

  final SecretMatcher _matcher;

  /// Scan a string for potential secrets.
  List<SecretMatch> scan(String value) {
    return _matcher.matchAll(value);
  }

  /// Scan with additional context (variable name, etc.) for better detection.
  List<SecretMatch> scanWithContext({
    required String value,
    required SecretContext context,
  }) {
    return _matcher.matchAll(value, context: context.toString());
  }
}

/// Context information to improve secret detection accuracy.
class SecretContext {
  const SecretContext({
    this.variableName,
    this.mapKey,
    this.parameterName,
  });

  final String? variableName;
  final String? mapKey;
  final String? parameterName;

  @override
  String toString() {
    return [variableName, mapKey, parameterName]
        .whereType<String>()
        .join(' ')
        .toLowerCase();
  }
}

/// Result of a secret detection match.
class SecretMatch {
  const SecretMatch({
    required this.ruleId,
    required this.description,
    required this.matchedValue,
  });

  final String ruleId;
  final String description;
  final String matchedValue;
}
```

**File: `lib/src/secret_detector/src/entropy.dart`**

> ⚠️ **NO `dart_shield` imports allowed!**

```dart
import 'dart:math';

/// Calculates Shannon entropy of a string.
///
/// Shannon Entropy measures the "randomness" or information density
/// of a string, measured in bits.
///
/// - Identical characters (e.g., "aaaaa"): entropy = 0
/// - Uniform distribution: entropy = log2(unique_chars)
class Entropy {
  /// Calculate Shannon entropy for [input].
  static double calculate(String input) {
    if (input.isEmpty) return 0;

    final frequency = <int, int>{};
    for (final codeUnit in input.codeUnits) {
      frequency[codeUnit] = (frequency[codeUnit] ?? 0) + 1;
    }

    final length = input.length;
    var entropy = 0.0;

    for (final count in frequency.values) {
      final probability = count / length;
      entropy -= probability * (log(probability) / ln2);
    }

    return entropy;
  }
}
```

**File: `lib/src/secret_detector/src/secret_rule.dart`**

> ⚠️ **NO `dart_shield` imports allowed!**

```dart
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

  /// Unique identifier (e.g., 'aws-access-key').
  final String id;

  /// Human-readable description.
  final String description;

  /// Regex pattern to match secrets.
  final RegExp pattern;

  /// Keywords for optimization (skip regex if no keyword present).
  final List<String> keywords;

  /// Minimum Shannon entropy required for a match.
  final double minEntropy;

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'pattern': pattern.pattern,
        'isCaseSensitive': pattern.isCaseSensitive,
        'isMultiLine': pattern.isMultiLine,
        'keywords': keywords,
        'minEntropy': minEntropy,
      };
}
```

**File: `lib/src/secret_detector/src/secret_matcher.dart`**

> ⚠️ **NO `dart_shield` imports allowed!**

```dart
import 'entropy.dart';
import 'secret_rule.dart';

/// Core matching engine for secret detection.
class SecretMatcher {
  SecretMatcher({
    required this.rules,
    this.minEntropyOverride,
    this.minLength = 8,
  });

  final List<SecretRule> rules;
  final double? minEntropyOverride;
  final int minLength;

  /// Match a single value, return first match or null.
  SecretMatchResult? match(String value, {String context = ''}) {
    if (value.length < minLength) return null;

    final valueLower = value.toLowerCase();
    final contextLower = context.toLowerCase();

    for (final rule in rules) {
      // 1. Keyword check (optimization)
      if (rule.keywords.isNotEmpty) {
        final hasKeyword = rule.keywords.any(
          (kw) => valueLower.contains(kw) || contextLower.contains(kw),
        );
        if (!hasKeyword) continue;
      }

      // 2. Regex check
      if (!rule.pattern.hasMatch(value)) continue;

      // 3. Entropy check
      final requiredEntropy = minEntropyOverride ?? rule.minEntropy;
      if (requiredEntropy > 0) {
        final entropy = Entropy.calculate(value);
        if (entropy < requiredEntropy) continue;
      }

      // Match found
      return SecretMatchResult(
        ruleId: rule.id,
        description: rule.description,
        matchedValue: value,
      );
    }

    return null;
  }

  /// Match all rules against a value, return all matches.
  List<SecretMatchResult> matchAll(String value, {String context = ''}) {
    final result = match(value, context: context);
    return result != null ? [result] : [];
  }
}

/// Result of a successful match.
class SecretMatchResult {
  const SecretMatchResult({
    required this.ruleId,
    required this.description,
    required this.matchedValue,
  });

  final String ruleId;
  final String description;
  final String matchedValue;
}
```

**File: `lib/src/secret_detector/src/patterns/builtin_patterns.dart`**

> ⚠️ **NO `dart_shield` imports allowed!**

```dart
import 'dart:convert';

import '../secret_rule.dart';

/// Built-in secret detection patterns.
///
/// Contains 250+ patterns derived from Gitleaks.
class BuiltinPatterns {
  static List<SecretRule>? _cached;

  /// All built-in patterns.
  static List<SecretRule> get all {
    return _cached ??= _parse(_embeddedJson);
  }

  static List<SecretRule> _parse(String json) {
    final list = jsonDecode(json) as List;
    return list
        .map((e) => SecretRule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // TODO: Generate this from rules.json during build
  static const String _embeddedJson = '[]'; // Placeholder
}
```

#### Step 1.3: Update Adapter (avoid_hardcoded_secrets.dart)

```dart
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:dart_shield/src/secret_detector/secret_detector.dart';

class AvoidHardcodedSecrets extends AnalysisRule {
  AvoidHardcodedSecrets()
      : _detector = SecretDetector(),
        super(
          name: 'avoid_hardcoded_secrets',
          description: 'Detects hardcoded secrets, API keys, and tokens.',
        );

  final SecretDetector _detector;

  // ... rest of implementation using _detector.scanWithContext()
}
```

#### Step 1.4: Update Build Script

Update `tool/generate_rules.dart` to generate `builtin_patterns.dart`:

```dart
// Add to existing script:
final builtinFile = File('lib/src/secret_detector/src/patterns/builtin_patterns.dart');
final builtinContent = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
import 'dart:convert';
import '../secret_rule.dart';

class BuiltinPatterns {
  static List<SecretRule>? _cached;
  static List<SecretRule> get all => _cached ??= _parse(_embeddedJson);
  static List<SecretRule> _parse(String json) {
    final list = jsonDecode(json) as List;
    return list.map((e) => SecretRule.fromJson(e as Map<String, dynamic>)).toList();
  }
  static const String _embeddedJson = r\'\'\'
$jsonContent
\'\'\';
}
''';
await builtinFile.writeAsString(builtinContent);
```

### Acceptance Criteria

- [ ] Tests written before refactoring
- [ ] `lib/src/secret_detector/` has ZERO imports from `package:dart_shield` (except in barrel file)
- [ ] `SecretDetector` public API is clean and documented
- [ ] `SecretMatcher` can be tested independently
- [ ] `Entropy` moved and working
- [ ] All 250+ patterns available via `BuiltinPatterns.all`
- [ ] `avoid_hardcoded_secrets.dart` updated to use new module
- [ ] All existing tests still pass
- [ ] New module tests pass
- [ ] `tool/generate_rules.dart` updated to generate `builtin_patterns.dart`

---

## Task 2: Regex Compat Module

### Priority: P2 (Medium)

### Branch: `refactor/regex-compat-modularization`

### Context

The regex sanitizer converts Go/PCRE regex syntax to Dart. It's already independent but lives in `tool/utils/`. Move it to a proper module structure.

### Current Location

```
tool/utils/regex_sanitizer.dart
```

### Target Structure

```
lib/src/regex_compat/
├── regex_compat.dart           # Public API
└── src/
    └── sanitizer.dart          # Implementation
```

### Implementation Steps

#### Step 2.1: Write Tests

**File: `test/src/regex_compat/regex_compat_test.dart`**

```dart
import 'package:dart_shield/src/regex_compat/regex_compat.dart';
import 'package:test/test.dart';

void main() {
  group('RegexCompat', () {
    test('converts (?i) to caseSensitive: false', () {
      final result = RegexCompat.sanitize('(?i)hello');
      
      expect(result.pattern, 'hello');
      expect(result.caseSensitive, isFalse);
    });

    test('converts (?m) to multiLine: true', () {
      final result = RegexCompat.sanitize('(?m)^start');
      
      expect(result.pattern, '^start');
      expect(result.multiLine, isTrue);
    });

    test('converts scoped (?i:...) to global', () {
      final result = RegexCompat.sanitize('abc(?i:def)ghi');
      
      expect(result.pattern, 'abc(?:def)ghi');
      expect(result.caseSensitive, isFalse);
    });

    test('handles multiple flags', () {
      final result = RegexCompat.sanitize('(?i)(?m)test');
      
      expect(result.pattern, 'test');
      expect(result.caseSensitive, isFalse);
      expect(result.multiLine, isTrue);
    });

    test('compile creates working RegExp', () {
      final regex = RegexCompat.compile('(?i)hello');
      
      expect(regex.hasMatch('HELLO'), isTrue);
      expect(regex.hasMatch('hello'), isTrue);
    });

    test('preserves pattern without flags', () {
      final result = RegexCompat.sanitize(r'\d{3}-\d{4}');
      
      expect(result.pattern, r'\d{3}-\d{4}');
      expect(result.caseSensitive, isTrue);
      expect(result.multiLine, isFalse);
    });
  });
}
```

#### Step 2.2: Create Module

**File: `lib/src/regex_compat/regex_compat.dart`**

```dart
/// Regex compatibility utilities for converting PCRE/Go patterns to Dart.
library regex_compat;

export 'src/sanitizer.dart' show SanitizedRegex;

import 'src/sanitizer.dart';

/// Converts PCRE/Go regex patterns to Dart-compatible format.
class RegexCompat {
  /// Sanitize a PCRE/Go pattern for use with Dart's RegExp.
  static SanitizedRegex sanitize(String pattern) {
    return RegexSanitizer.sanitize(pattern);
  }

  /// Compile a PCRE/Go pattern directly to a Dart RegExp.
  static RegExp compile(String pattern) {
    final sanitized = sanitize(pattern);
    return RegExp(
      sanitized.pattern,
      caseSensitive: sanitized.caseSensitive,
      multiLine: sanitized.multiLine,
    );
  }
}
```

**File: `lib/src/regex_compat/src/sanitizer.dart`**

> Move contents from `tool/utils/regex_sanitizer.dart`

```dart
/// Result of sanitizing a regex pattern.
class SanitizedRegex {
  const SanitizedRegex({
    required this.pattern,
    required this.caseSensitive,
    required this.multiLine,
  });

  final String pattern;
  final bool caseSensitive;
  final bool multiLine;
}

/// Internal sanitization logic.
class RegexSanitizer {
  static SanitizedRegex sanitize(String rawPattern) {
    var pattern = rawPattern;
    var caseSensitive = true;
    var multiLine = false;

    // Handle (?i)
    if (pattern.contains('(?i)')) {
      caseSensitive = false;
      pattern = pattern.replaceAll('(?i)', '');
    }

    // Handle (?i:...)
    if (pattern.contains('(?i:')) {
      caseSensitive = false;
      pattern = pattern.replaceAll('(?i:', '(?:');
    }

    // Handle (?m)
    if (pattern.contains('(?m)')) {
      multiLine = true;
      pattern = pattern.replaceAll('(?m)', '');
    }

    // Handle (?m:...)
    if (pattern.contains('(?m:')) {
      multiLine = true;
      pattern = pattern.replaceAll('(?m:', '(?:');
    }

    // Handle (?s)
    if (pattern.contains('(?s)')) {
      pattern = pattern.replaceAll('(?s)', '');
    }

    // Handle (?s:...)
    if (pattern.contains('(?s:')) {
      pattern = pattern.replaceAll('(?s:', '(?:');
    }

    return SanitizedRegex(
      pattern: pattern,
      caseSensitive: caseSensitive,
      multiLine: multiLine,
    );
  }
}
```

#### Step 2.3: Update Tool Script

Update `tool/generate_rules.dart` to use the module:

```dart
import 'package:dart_shield/src/regex_compat/regex_compat.dart';

// Replace:
// import 'utils/regex_sanitizer.dart';
// final sanitized = RegexSanitizer.sanitize(rawRegex);

// With:
final sanitized = RegexCompat.sanitize(rawRegex);
```

### Acceptance Criteria

- [ ] Tests written before refactoring
- [ ] `lib/src/regex_compat/` has ZERO external dependencies
- [ ] `RegexCompat.sanitize()` and `RegexCompat.compile()` work
- [ ] `tool/generate_rules.dart` updated to use module
- [ ] Existing regex sanitizer tests moved and passing
- [ ] Old `tool/utils/regex_sanitizer.dart` removed

---

## Execution Order

1. **Task 1** - Secret Detector (high value, more complex)
2. **Task 2** - Regex Compat (simpler, quick win)

---

## Verification Checklist

After completing all tasks:

- [ ] `dart test` passes with 0 failures
- [ ] `dart analyze` passes with 0 issues
- [ ] No circular dependencies
- [ ] Modular components have zero `package:dart_shield` imports (except adapters)
- [ ] `tool/generate_rules.dart` works with new structure
- [ ] `dart_shield analyze example/` produces same results as before

---

## Git Workflow

```bash
# Task 1
git checkout -b refactor/secret-detector-modularization
# ... implement ...
git push -u origin refactor/secret-detector-modularization
# Create PR, review, merge

# Task 2
git checkout main && git pull
git checkout -b refactor/regex-compat-modularization
# ... implement ...
git push -u origin refactor/regex-compat-modularization
# Create PR, review, merge
```

---

## Future: Publishing to pub.dev

After internal modularization is complete and stable:

1. Create new repository for package
2. Copy module files (they have no dart_shield deps)
3. Add pubspec.yaml, README, CHANGELOG
4. Publish to pub.dev
5. Update dart_shield to depend on published package

This is **NOT** part of Phase 3 - only internal modularization.
