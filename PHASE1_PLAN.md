# Phase 1: Stability & Quality - Implementation Plan

## Overview

This document outlines the detailed implementation plan for Phase 1 of dart_shield improvements. The goal is to establish a stable, well-tested foundation before adding new features.

**Estimated Scope:** 5 major tasks  
**Priority:** Critical - blocks all other development

---

## Task 1: Add Unit Tests for All 5 Rules

### Priority: P0 (Critical)

### Context

Currently, the project has minimal test coverage. The 5 analysis rules have no dedicated unit tests, which is unacceptable for a security tool where false negatives can have serious consequences.

### Official Testing Framework

Dart provides the [`analyzer_testing`](https://pub.dev/packages/analyzer_testing) package specifically for testing analysis rules. This is the **official and recommended approach**.

**Reference:** https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server_plugin/doc/testing_rules.md

### Rules to Test

Located in `lib/src/analyzers/code/rules/`:

1. `secrets/avoid_hardcoded_secrets.dart`
2. `network/avoid_harcoded_urls.dart`
3. `network/prefer_https_over_http.dart`
4. `cryptography/avoid_weak_hashing.dart`
5. `cryptography/prefer_secure_random.dart`

### Implementation Steps

#### Step 1.1: Add Test Dependencies

Add to `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  analyzer_testing: ^0.1.0  # Check pub.dev for latest version
  test_reflective_loader: ^0.2.0
  # ... existing dependencies
```

Run `dart pub get` after updating.

#### Step 1.2: Create Test Files Using AnalysisRuleTest

Each test file follows this structure using the `test_reflective_loader` pattern:

**File: `test/src/analyzers/code/rules/network/prefer_https_over_http_test.dart`**

```dart
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/network/prefer_https_over_http.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferHttpsOverHttpTest);
  });
}

@reflectiveTest
class PreferHttpsOverHttpTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferHttpsOverHttp();
    super.setUp();
  }

  void test_httpStringLiteral_reports() async {
    await assertDiagnostics(
      r'''
void f() {
  final url = 'http://example.com';
}
''',
      [lint(27, 20)],  // offset and length of 'http://example.com'
    );
  }

  void test_httpsStringLiteral_noReport() async {
    await assertNoDiagnostics(
      r'''
void f() {
  final url = 'https://example.com';
}
''',
    );
  }

  void test_uriHttpConstructor_reports() async {
    await assertDiagnostics(
      r'''
void f() {
  final uri = Uri.http('example.com', '/path');
}
''',
      [lint(27, 31)],
    );
  }

  void test_uriHttpsConstructor_noReport() async {
    await assertNoDiagnostics(
      r'''
void f() {
  final uri = Uri.https('example.com', '/path');
}
''',
    );
  }

  void test_emptyString_noReport() async {
    await assertNoDiagnostics(
      r'''
void f() {
  final url = '';
}
''',
    );
  }
}
```

**File: `test/src/analyzers/code/rules/network/avoid_hardcoded_urls_test.dart`**

```dart
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/network/avoid_harcoded_urls.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidHardcodedUrlsTest);
  });
}

@reflectiveTest
class AvoidHardcodedUrlsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidHardcodedUrls();
    super.setUp();
  }

  void test_httpsUrl_reports() async {
    await assertDiagnostics(
      r'''
void f() {
  final url = 'https://api.example.com/v1';
}
''',
      [lint(27, 28)],
    );
  }

  void test_httpUrl_reports() async {
    await assertDiagnostics(
      r'''
void f() {
  final url = 'http://api.example.com';
}
''',
      [lint(27, 24)],
    );
  }

  void test_interpolatedUrl_noReport() async {
    await assertNoDiagnostics(
      r'''
void f(String host) {
  final url = 'https://$host/api';
}
''',
    );
  }

  void test_localhostUrl_behavior() async {
    // Decide: should localhost be flagged or ignored?
    // Implement accordingly
  }
}
```

**File: `test/src/analyzers/code/rules/cryptography/avoid_weak_hashing_test.dart`**

```dart
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/cryptography/avoid_weak_hashing.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidWeakHashingTest);
  });
}

@reflectiveTest
class AvoidWeakHashingTest extends AnalysisRuleTest {
  @override
  void setUp() {
    // Add stub for crypto package
    newPackage('crypto')
      ..addFile('lib/crypto.dart', r'''
abstract class Hash {
  List<int> convert(List<int> data);
}
final Hash md5 = _Md5();
final Hash sha1 = _Sha1();
final Hash sha256 = _Sha256();
class _Md5 implements Hash { List<int> convert(List<int> data) => []; }
class _Sha1 implements Hash { List<int> convert(List<int> data) => []; }
class _Sha256 implements Hash { List<int> convert(List<int> data) => []; }
''');
    rule = AvoidWeakHashing();
    super.setUp();
  }

  void test_md5Convert_reports() async {
    await assertDiagnostics(
      r'''
import 'package:crypto/crypto.dart';
void f() {
  final hash = md5.convert([1, 2, 3]);
}
''',
      [lint(52, 22)],
    );
  }

  void test_sha1Convert_reports() async {
    await assertDiagnostics(
      r'''
import 'package:crypto/crypto.dart';
void f() {
  final hash = sha1.convert([1, 2, 3]);
}
''',
      [lint(52, 23)],
    );
  }

  void test_sha256Convert_noReport() async {
    await assertNoDiagnostics(
      r'''
import 'package:crypto/crypto.dart';
void f() {
  final hash = sha256.convert([1, 2, 3]);
}
''',
    );
  }

  void test_md5Assignment_reports() async {
    await assertDiagnostics(
      r'''
import 'package:crypto/crypto.dart';
void f() {
  final hasher = md5;
}
''',
      [lint(52, 14)],
    );
  }
}
```

**File: `test/src/analyzers/code/rules/cryptography/prefer_secure_random_test.dart`**

```dart
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/cryptography/prefer_secure_random.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferSecureRandomTest);
  });
}

@reflectiveTest
class PreferSecureRandomTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferSecureRandom();
    super.setUp();
  }

  void test_randomConstructor_reports() async {
    await assertDiagnostics(
      r'''
import 'dart:math';
void f() {
  final rng = Random();
}
''',
      [lint(45, 8)],
    );
  }

  void test_randomWithSeed_reports() async {
    await assertDiagnostics(
      r'''
import 'dart:math';
void f() {
  final rng = Random(42);
}
''',
      [lint(45, 10)],
    );
  }

  void test_randomSecure_noReport() async {
    await assertNoDiagnostics(
      r'''
import 'dart:math';
void f() {
  final rng = Random.secure();
}
''',
    );
  }
}
```

**File: `test/src/analyzers/code/rules/secrets/avoid_hardcoded_secrets_test.dart`**

```dart
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/secrets/avoid_hardcoded_secrets.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidHardcodedSecretsTest);
  });
}

@reflectiveTest
class AvoidHardcodedSecretsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidHardcodedSecrets();
    super.setUp();
  }

  void test_awsAccessKey_reports() async {
    // Construct dynamically to avoid triggering secret scanners
    final prefix = 'AKIA';
    final suffix = 'ABCDEFGHIJKLMNOP';
    await assertDiagnostics(
      '''
void f() {
  final key = '$prefix$suffix';
}
''',
      [lint(27, 22)],
    );
  }

  void test_githubToken_reports() async {
    await assertDiagnostics(
      r'''
void f() {
  final token = 'ghp_aBcDeFgHiJkLmNoPqRsTuVwXyZ012345';
}
''',
      [lint(29, 40)],
    );
  }

  void test_shortString_noReport() async {
    await assertNoDiagnostics(
      r'''
void f() {
  final s = 'short';
}
''',
    );
  }

  void test_lowEntropyString_noReport() async {
    await assertNoDiagnostics(
      r'''
void f() {
  final s = 'aaaaaaaaaaaaaaaa';
}
''',
    );
  }

  void test_contextVariableName_detects() async {
    // Tests that apiKey variable name triggers keyword check
    await assertDiagnostics(
      r'''
void f() {
  final apiKey = 'sk_live_abcdefghijklmnop';
}
''',
      [lint(30, 25)],
    );
  }

  void test_mapKeyContext_detects() async {
    await assertDiagnostics(
      r'''
void f() {
  final config = {
    'apiKey': 'sk_test_1234567890abcdef',
  };
}
''',
      [lint(46, 27)],
    );
  }
}
```

#### Step 1.3: Run Tests

```bash
# Run all rule tests
dart test test/src/analyzers/code/rules/

# Run with verbose output
dart --enable-asserts test test/src/analyzers/code/rules/

# Run a specific test file
dart test test/src/analyzers/code/rules/network/prefer_https_over_http_test.dart
```

### Key Testing APIs

From the `analyzer_testing` package:

| API | Purpose |
|-----|---------|
| `AnalysisRuleTest` | Base class for rule tests |
| `rule = MyRule()` | Set in `setUp()` to specify which rule to test |
| `assertDiagnostics(code, [lint(...)])` | Assert specific diagnostics are reported |
| `assertNoDiagnostics(code)` | Assert no diagnostics are reported |
| `lint(offset, length)` | Create expected diagnostic at offset with length |
| `error(ErrorCode, offset, length)` | Assert compile-time errors (for edge cases) |
| `newPackage('name')..addFile(...)` | Create stub packages for imports |

### Test Cases Summary

| Rule | Min Test Cases | Key Scenarios |
|------|---------------|---------------|
| `prefer_https_over_http` | 5 | http literals, Uri.http(), https (no report), empty strings |
| `avoid_hardcoded_urls` | 5 | https URLs, http URLs, interpolated URLs, localhost |
| `avoid_weak_hashing` | 5 | md5.convert, sha1.convert, assignment, sha256 (no report) |
| `prefer_secure_random` | 4 | Random(), Random(seed), Random.secure() (no report) |
| `avoid_hardcoded_secrets` | 7 | AWS keys, GitHub tokens, short strings, low entropy, context |

### Acceptance Criteria

- [ ] `analyzer_testing` and `test_reflective_loader` added to dev_dependencies
- [ ] All 5 rules have dedicated test files using `AnalysisRuleTest`
- [ ] Each rule has at least 5 test cases (positive and negative)
- [ ] All tests pass with `dart test`
- [ ] Stub packages created for rules that need external imports (crypto)
- [ ] Test coverage for rules directory > 80%

---

## Task 2: Fix Configuration File Inconsistency

### Priority: P0 (Critical)

### Context

The README documents `shield_options.yaml` as the configuration file, but the code actually reads from `analysis_options.yaml`. This inconsistency confuses users.

### Current State

**README.md (lines 66-68, 100-135):** Documents `shield_options.yaml`

**Code (`lib/src/configuration/shield_config.dart` lines 24-26):**
```dart
static Future<ShieldConfig> load() async {
  final file = File('analysis_options.yaml');
  if (!file.existsSync()) return const ShieldConfig();
```

### Decision Required

**Option A (Recommended):** Use `analysis_options.yaml` with `dart_shield:` key
- Pros: Idiomatic Dart, single config file, familiar to developers
- Cons: Mixes with other Dart analysis config

**Option B:** Use dedicated `shield_options.yaml`
- Pros: Separation of concerns, cleaner
- Cons: Another config file to manage

### Implementation Steps (Option A)

#### Step 2.1: Update README.md

Replace all references to `shield_options.yaml` with `analysis_options.yaml` and show the `dart_shield:` namespace:

```yaml
# analysis_options.yaml
analyzer:
  plugins:
    - dart_shield

dart_shield:
  analyzers:
    code: true
  # Future: exclude patterns, rule configuration, etc.
```

#### Step 2.2: Update `init_command.dart`

Modify the init command to:
1. Check if `analysis_options.yaml` exists
2. If yes, append `dart_shield:` section
3. If no, create new file with full template

#### Step 2.3: Update Example Project

Update `example/analysis_options.yaml` to reflect the correct configuration format.

### Acceptance Criteria

- [ ] README accurately reflects how configuration works
- [ ] `dart_shield init` creates/updates correct config file
- [ ] Example project uses correct configuration
- [ ] No references to `shield_options.yaml` remain in codebase

---

## Task 3: Add `dart test` to CI Pipeline

### Priority: P0 (Critical)

### Context

The current CI pipeline (`.github/workflows/dart.yml`) runs format and analyze checks but does NOT run tests. This means breaking changes can be merged without detection.

### Current State

```yaml
# .github/workflows/dart.yml (current)
- name: ✂ Format
  run: dart format --output=none --set-exit-if-changed .

- name: 📊 Analyze
  run: dart analyze --fatal-infos --fatal-warnings .

- name: 📊 Run Pana
  run: dart pub global activate pana && dart pub global run pana
```

### Implementation Steps

#### Step 3.1: Add Test Step to Workflow

Add after the Analyze step:

```yaml
- name: 🧪 Run Tests
  run: dart test --coverage=coverage

- name: 📈 Upload Coverage
  uses: codecov/codecov-action@v4
  with:
    files: coverage/lcov.info
    fail_ci_if_error: false
```

#### Step 3.2: Add Integration Test Job

Create a separate job for integration tests that may take longer:

```yaml
integration-test:
  runs-on: ubuntu-latest
  needs: build
  steps:
    - uses: actions/checkout@v5
    - uses: dart-lang/setup-dart@v1.6.5
      with:
        sdk: '3.9.0'
    - name: Install Dependencies
      run: dart pub get
    - name: Run Integration Tests
      run: dart test test/integration/ --timeout=120s
```

#### Step 3.3: Add Coverage Badge to README

Add codecov badge to README.md after existing badges.

### Acceptance Criteria

- [ ] `dart test` runs on every PR and push to master
- [ ] Integration tests run in CI
- [ ] Coverage reports uploaded to codecov
- [ ] CI fails if tests fail
- [ ] README displays coverage badge

---

## Task 4: Wire Severity Levels to Rules

### Priority: P1 (High)

### Context

The `Severity` enum exists in `lib/src/domain/analysis_issue.dart` but rules don't specify their severity. All issues are reported without severity distinction.

### Current State

```dart
// lib/src/domain/analysis_issue.dart
enum Severity { high, medium, low, info }
```

Rules don't have severity information attached.

### Implementation Steps

#### Step 4.1: Create Rule Metadata

Create `lib/src/analyzers/code/rules/rule_metadata.dart`:

```dart
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

/// Registry of all rule metadata
const Map<String, RuleMetadata> ruleMetadataRegistry = {
  'avoid_hardcoded_secrets': RuleMetadata(
    ruleId: 'avoid_hardcoded_secrets',
    severity: Severity.high,
    owaspCategory: 'A02:2021 Cryptographic Failures',
    cweId: 'CWE-798',
  ),
  'prefer_https_over_http': RuleMetadata(
    ruleId: 'prefer_https_over_http',
    severity: Severity.high,
    owaspCategory: 'A02:2021 Cryptographic Failures',
    cweId: 'CWE-319',
  ),
  'avoid_weak_hashing': RuleMetadata(
    ruleId: 'avoid_weak_hashing',
    severity: Severity.medium,
    owaspCategory: 'A02:2021 Cryptographic Failures',
    cweId: 'CWE-328',
  ),
  'prefer_secure_random': RuleMetadata(
    ruleId: 'prefer_secure_random',
    severity: Severity.medium,
    owaspCategory: 'A02:2021 Cryptographic Failures',
    cweId: 'CWE-330',
  ),
  'avoid_hardcoded_urls': RuleMetadata(
    ruleId: 'avoid_hardcoded_urls',
    severity: Severity.low,
    owaspCategory: 'A05:2021 Security Misconfiguration',
    cweId: 'CWE-547',
  ),
};
```

#### Step 4.2: Update DTO Mapper

Modify `lib/src/analyzers/utils/dto_mapper.dart` to look up severity from the registry when creating `AnalysisIssue`.

#### Step 4.3: Update Console Reporter

Update `lib/src/reporters/console_reporter.dart` to display severity-based icons (already partially implemented).

#### Step 4.4: Add CLI Filter Option

Add `--min-severity` flag to `analyze_command.dart`:

```dart
argParser.addOption(
  'min-severity',
  allowed: ['info', 'low', 'medium', 'high'],
  defaultsTo: 'info',
  help: 'Minimum severity level to report.',
);
```

### Acceptance Criteria

- [ ] All 5 rules have severity metadata
- [ ] Console output shows severity icons
- [ ] JSON output includes severity field
- [ ] `--min-severity` flag filters output
- [ ] OWASP/CWE references included in metadata

---

## Task 5: Add Code Coverage Tracking

### Priority: P1 (High)

### Context

No visibility into test coverage makes it difficult to identify untested code paths. Security tools require comprehensive coverage.

### Implementation Steps

#### Step 5.1: Setup Coverage Collection

Ensure `dart test --coverage=coverage` works locally.

#### Step 5.2: Add lcov Generation

Create a script or add to CI:

```bash
dart pub global activate coverage
dart pub global run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --report-on=lib
```

#### Step 5.3: Configure Codecov

Create `codecov.yml` in project root:

```yaml
coverage:
  precision: 2
  round: down
  range: "60...100"

  status:
    project:
      default:
        target: 70%
        threshold: 5%
    patch:
      default:
        target: 80%

ignore:
  - "**/*.g.dart"
  - "lib/src/generated/**"
  - "test/**"
```

#### Step 5.4: Add Coverage Badge

Add to README.md:

```markdown
[![codecov](https://codecov.io/gh/yardexx/dart_shield/branch/master/graph/badge.svg)](https://codecov.io/gh/yardexx/dart_shield)
```

### Acceptance Criteria

- [ ] Coverage reports generated locally with `dart test --coverage`
- [ ] Codecov integration working in CI
- [ ] Coverage badge displayed in README
- [ ] Minimum coverage threshold enforced (70%)

---

## Execution Order

1. **Task 3** - Add tests to CI (quick win, prevents regressions)
2. **Task 1** - Add unit tests (most critical, enables safe refactoring)
3. **Task 5** - Add coverage tracking (validates Task 1 completeness)
4. **Task 2** - Fix config inconsistency (user-facing fix)
5. **Task 4** - Wire severity levels (enhances output quality)

---

## Verification Checklist

After completing all tasks:

- [ ] `dart test` passes with 0 failures
- [ ] `dart analyze` passes with 0 issues
- [ ] CI pipeline runs tests on every PR
- [ ] Coverage is above 70%
- [ ] README is accurate and consistent with code
- [ ] All 5 rules have severity metadata
- [ ] `dart_shield analyze example/` produces severity-tagged output

---

## Notes for Implementation

- Run `dart pub get` before starting
- Use `very_good_analysis` linting rules (already configured)
- Follow existing code style and patterns
- Create atomic commits for each sub-task
- Update CHANGELOG.md when tasks are complete

## References

- **Rule Testing Framework:** https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server_plugin/doc/testing_rules.md
- **analyzer_testing package:** https://pub.dev/packages/analyzer_testing
- **test_reflective_loader package:** https://pub.dev/packages/test_reflective_loader
- **Writing Rules Guide:** https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server_plugin/doc/writing_rules.md
