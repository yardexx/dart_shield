# Phase 2: Feature Expansion - Implementation Plan

## Overview

This document outlines the detailed implementation plan for Phase 2 of dart_shield improvements. The goal is to expand functionality with high-impact features that differentiate dart_shield in the Dart/Flutter security space.

**Prerequisites:** Phase 1 must be completed (tests, CI, severity levels)  
**Estimated Scope:** 4 major features  
**Development Approach:** Test-Driven Development (TDD)

---

## Development Workflow

### Branch Naming Convention

All features must be developed in dedicated branches:

```
feature/<feature-name>
```

Examples:
- `feature/sarif-reporter`
- `feature/baseline-support`
- `feature/insecure-storage-rules`
- `feature/flutter-specific-rules`

### TDD Process

For each feature:

1. **Write tests first** - Define expected behavior through tests
2. **Run tests (expect failure)** - Confirm tests fail without implementation
3. **Implement minimum code** - Write just enough to pass tests
4. **Refactor** - Clean up while keeping tests green
5. **Repeat** - Add more tests for edge cases

```bash
# Create feature branch
git checkout -b feature/<feature-name>

# Write tests first
# Run tests (should fail)
dart test test/path/to/new_feature_test.dart

# Implement feature
# Run tests (should pass)
dart test

# Commit with descriptive message
git add .
git commit -m "feat: add <feature-name>"

# Push and create PR
git push -u origin feature/<feature-name>
```

---

## Task 1: Implement SARIF Output Reporter

### Priority: P0 (Critical)

### Branch: `feature/sarif-reporter`

### Context

SARIF (Static Analysis Results Interchange Format) is the industry standard for static analysis tools. GitHub Security, Azure DevOps, and many other platforms consume SARIF for security dashboards and PR annotations.

**This is a killer feature** - it enables:
- GitHub Security tab integration
- PR annotations showing security issues inline
- Tracking security issues over time
- Integration with enterprise security dashboards

### SARIF Specification

Reference: https://sarifweb.azurewebsites.net/

SARIF version: `2.1.0`

### Implementation Steps

#### Step 1.1: Write Tests First

**File: `test/src/reporters/sarif_reporter_test.dart`**

```dart
import 'dart:convert';

import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:dart_shield/src/domain/issue_context.dart';
import 'package:dart_shield/src/reporters/sarif_reporter.dart';
import 'package:test/test.dart';

void main() {
  group('SarifReporter', () {
    late SarifReporter reporter;

    setUp(() {
      reporter = SarifReporter();
    });

    test('generates valid SARIF 2.1.0 schema', () async {
      final results = [
        AnalysisSuccess(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          issues: [],
        ),
      ];

      final output = await reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;

      expect(sarif[r'$schema'], contains('sarif'));
      expect(sarif['version'], '2.1.0');
      expect(sarif['runs'], isA<List>());
    });

    test('includes tool information', () async {
      final results = [
        AnalysisSuccess(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          issues: [],
        ),
      ];

      final output = await reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;
      final tool = sarif['runs'][0]['tool']['driver'] as Map<String, dynamic>;

      expect(tool['name'], 'dart_shield');
      expect(tool['informationUri'], contains('github.com'));
      expect(tool['rules'], isA<List>());
    });

    test('maps issues to SARIF results', () async {
      final results = [
        AnalysisSuccess(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          issues: [
            AnalysisIssue(
              ruleId: 'avoid_hardcoded_secrets',
              severity: Severity.high,
              message: 'Hardcoded secret detected: AWS credentials',
              context: FileContext(
                filePath: 'lib/src/api.dart',
                line: 10,
                column: 5,
              ),
            ),
          ],
        ),
      ];

      final output = await reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;
      final sarifResults = sarif['runs'][0]['results'] as List;

      expect(sarifResults, hasLength(1));
      expect(sarifResults[0]['ruleId'], 'avoid_hardcoded_secrets');
      expect(sarifResults[0]['level'], 'error'); // high -> error
      expect(sarifResults[0]['message']['text'], contains('AWS'));
    });

    test('maps severity correctly', () async {
      // high -> error
      // medium -> warning
      // low -> note
      // info -> note
      final results = [
        AnalysisSuccess(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          issues: [
            AnalysisIssue(
              ruleId: 'rule1',
              severity: Severity.high,
              message: 'High severity',
              context: FileContext(filePath: 'a.dart', line: 1, column: 1),
            ),
            AnalysisIssue(
              ruleId: 'rule2',
              severity: Severity.medium,
              message: 'Medium severity',
              context: FileContext(filePath: 'a.dart', line: 2, column: 1),
            ),
            AnalysisIssue(
              ruleId: 'rule3',
              severity: Severity.low,
              message: 'Low severity',
              context: FileContext(filePath: 'a.dart', line: 3, column: 1),
            ),
          ],
        ),
      ];

      final output = await reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;
      final sarifResults = sarif['runs'][0]['results'] as List;

      expect(sarifResults[0]['level'], 'error');
      expect(sarifResults[1]['level'], 'warning');
      expect(sarifResults[2]['level'], 'note');
    });

    test('includes physical location with URI', () async {
      final results = [
        AnalysisSuccess(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          issues: [
            AnalysisIssue(
              ruleId: 'test_rule',
              severity: Severity.medium,
              message: 'Test message',
              context: FileContext(
                filePath: 'lib/src/service.dart',
                line: 42,
                column: 10,
              ),
            ),
          ],
        ),
      ];

      final output = await reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;
      final location = sarif['runs'][0]['results'][0]['locations'][0];
      final physicalLocation = location['physicalLocation'];

      expect(physicalLocation['artifactLocation']['uri'], 'lib/src/service.dart');
      expect(physicalLocation['region']['startLine'], 42);
      expect(physicalLocation['region']['startColumn'], 10);
    });

    test('handles empty results', () async {
      final results = <AnalyzerResult>[];

      final output = await reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;

      expect(sarif['runs'], hasLength(1));
      expect(sarif['runs'][0]['results'], isEmpty);
    });

    test('handles analysis failures gracefully', () async {
      final results = [
        AnalysisFailure(
          analyzerId: 'code',
          duration: Duration(milliseconds: 100),
          errorMessage: 'Failed to analyze',
          stackTrace: StackTrace.current,
        ),
      ];

      final output = await reporter.generateSarif(results);
      final sarif = jsonDecode(output) as Map<String, dynamic>;

      // Should still produce valid SARIF, possibly with invocation failure
      expect(sarif['version'], '2.1.0');
    });
  });
}
```

#### Step 1.2: Implement Modular SARIF Module

**Architecture Principle:** The SARIF module is structured as an independent, extraction-ready module. Core SARIF files have **zero imports from `dart_shield`** - they work with generic types only. This enables:

- Future extraction to a standalone `sarif_dart` package
- Pure unit testing without dart_shield dependencies  
- Clean one-directional dependency: `Reporter` → `SarifReporter` → `SarifBuilder`

**File Structure:**

```
lib/src/reporters/
├── reporter.dart                    # Interface (existing)
├── console_reporter.dart            # Existing
├── json_reporter.dart               # Existing
└── sarif/
    ├── sarif_reporter.dart          # Adapter - implements Reporter, uses SarifBuilder
    ├── sarif_document.dart          # Pure SARIF data structures (NO dart_shield imports!)
    └── sarif_builder.dart           # Builds SARIF document (NO dart_shield imports!)
```

---

**File: `lib/src/reporters/sarif/sarif_document.dart`**

> ⚠️ **NO `dart_shield` imports allowed in this file!**

```dart
/// Pure SARIF 2.1.0 data structures.
/// This file has NO dependencies on dart_shield domain models.
/// It can be extracted to a standalone package.

class SarifDocument {
  SarifDocument({
    required this.tool,
    required this.results,
  });

  static const String schema =
      'https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json';
  static const String version = '2.1.0';

  final SarifTool tool;
  final List<SarifResult> results;

  Map<String, dynamic> toJson() => {
        r'$schema': schema,
        'version': version,
        'runs': [
          {
            'tool': tool.toJson(),
            'results': results.map((r) => r.toJson()).toList(),
          },
        ],
      };
}

class SarifTool {
  SarifTool({
    required this.name,
    required this.version,
    required this.informationUri,
    this.rules = const [],
  });

  final String name;
  final String version;
  final String informationUri;
  final List<SarifRule> rules;

  Map<String, dynamic> toJson() => {
        'driver': {
          'name': name,
          'version': version,
          'informationUri': informationUri,
          'rules': rules.map((r) => r.toJson()).toList(),
        },
      };
}

class SarifRule {
  SarifRule({
    required this.id,
    required this.shortDescription,
    this.fullDescription,
    this.helpUri,
  });

  final String id;
  final String shortDescription;
  final String? fullDescription;
  final String? helpUri;

  Map<String, dynamic> toJson() => {
        'id': id,
        'shortDescription': {'text': shortDescription},
        if (fullDescription != null)
          'fullDescription': {'text': fullDescription},
        if (helpUri != null) 'helpUri': helpUri,
      };
}

class SarifResult {
  SarifResult({
    required this.ruleId,
    required this.level,
    required this.message,
    required this.location,
  });

  final String ruleId;
  final SarifLevel level;
  final String message;
  final SarifLocation location;

  Map<String, dynamic> toJson() => {
        'ruleId': ruleId,
        'level': level.name,
        'message': {'text': message},
        'locations': [location.toJson()],
      };
}

enum SarifLevel { error, warning, note, none }

class SarifLocation {
  SarifLocation({
    required this.filePath,
    required this.startLine,
    required this.startColumn,
    this.endLine,
    this.endColumn,
  });

  final String filePath;
  final int startLine;
  final int startColumn;
  final int? endLine;
  final int? endColumn;

  Map<String, dynamic> toJson() => {
        'physicalLocation': {
          'artifactLocation': {'uri': filePath},
          'region': {
            'startLine': startLine,
            'startColumn': startColumn,
            if (endLine != null) 'endLine': endLine,
            if (endColumn != null) 'endColumn': endColumn,
          },
        },
      };
}
```

---

**File: `lib/src/reporters/sarif/sarif_builder.dart`**

> ⚠️ **NO `dart_shield` imports allowed in this file!**

```dart
import 'dart:convert';

import 'package:dart_shield/src/reporters/sarif/sarif_document.dart';

/// Fluent builder for SARIF documents.
/// This class has NO dependencies on dart_shield domain models.
class SarifBuilder {
  SarifBuilder({
    required String toolName,
    required String toolVersion,
    required String toolUri,
  }) : _tool = SarifTool(
          name: toolName,
          version: toolVersion,
          informationUri: toolUri,
        );

  final SarifTool _tool;
  final List<SarifResult> _results = [];
  final Map<String, SarifRule> _rules = {};

  /// Add a result to the SARIF document.
  void addResult({
    required String ruleId,
    required String message,
    required SarifLevel level,
    required String filePath,
    required int line,
    required int column,
    String? ruleDescription,
    String? ruleHelpUri,
  }) {
    // Auto-register rule if not seen before
    _rules.putIfAbsent(
      ruleId,
      () => SarifRule(
        id: ruleId,
        shortDescription: ruleDescription ?? ruleId.replaceAll('_', ' '),
        helpUri: ruleHelpUri,
      ),
    );

    _results.add(SarifResult(
      ruleId: ruleId,
      level: level,
      message: message,
      location: SarifLocation(
        filePath: filePath,
        startLine: line,
        startColumn: column,
      ),
    ));
  }

  /// Build the SARIF document.
  SarifDocument build() {
    return SarifDocument(
      tool: SarifTool(
        name: _tool.name,
        version: _tool.version,
        informationUri: _tool.informationUri,
        rules: _rules.values.toList(),
      ),
      results: _results,
    );
  }

  /// Build and serialize to JSON string.
  String buildJson({bool pretty = true}) {
    final doc = build();
    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(doc.toJson());
    }
    return jsonEncode(doc.toJson());
  }
}
```

---

**File: `lib/src/reporters/sarif/sarif_reporter.dart`**

> This is the **adapter** that bridges dart_shield domain → SARIF module.

```dart
import 'dart:io';

import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/analyzer_result.dart';
import 'package:dart_shield/src/reporters/reporter.dart';
import 'package:dart_shield/src/reporters/sarif/sarif_builder.dart';
import 'package:dart_shield/src/reporters/sarif/sarif_document.dart';

/// SARIF reporter that adapts dart_shield results to SARIF format.
/// 
/// This is a thin adapter - all SARIF logic lives in [SarifBuilder].
class SarifReporter implements Reporter {
  @override
  String get id => 'sarif';

  @override
  Future<void> report(List<AnalyzerResult> results) async {
    final sarif = generateSarif(results);
    stdout.writeln(sarif);
  }

  /// Generate SARIF JSON from analysis results.
  /// Exposed for testing.
  String generateSarif(List<AnalyzerResult> results) {
    final builder = SarifBuilder(
      toolName: 'dart_shield',
      toolVersion: '0.1.0', // TODO: Read from pubspec
      toolUri: 'https://github.com/yardexx/dart_shield',
    );

    // Extract all issues from successful analyses
    final issues = results
        .whereType<AnalysisSuccess>()
        .expand((r) => r.issues);

    for (final issue in issues) {
      builder.addResult(
        ruleId: issue.ruleId,
        message: issue.message,
        level: _mapSeverity(issue.severity),
        filePath: issue.context.filePath,
        line: issue.context.line,
        column: issue.context.column,
        // TODO: Add rule descriptions from metadata
      );
    }

    return builder.buildJson();
  }

  /// Map dart_shield Severity to SARIF Level.
  SarifLevel _mapSeverity(Severity severity) {
    return switch (severity) {
      Severity.high => SarifLevel.error,
      Severity.medium => SarifLevel.warning,
      Severity.low => SarifLevel.note,
      Severity.info => SarifLevel.note,
    };
  }
}
```

---

#### Step 1.3: Add Tests for SARIF Module (Pure Unit Tests)

**File: `test/src/reporters/sarif/sarif_builder_test.dart`**

> These tests have NO dart_shield domain dependencies!

```dart
import 'dart:convert';

import 'package:dart_shield/src/reporters/sarif/sarif_builder.dart';
import 'package:dart_shield/src/reporters/sarif/sarif_document.dart';
import 'package:test/test.dart';

void main() {
  group('SarifBuilder', () {
    test('builds valid SARIF 2.1.0 document', () {
      final builder = SarifBuilder(
        toolName: 'test_tool',
        toolVersion: '1.0.0',
        toolUri: 'https://example.com',
      );

      final json = builder.buildJson();
      final sarif = jsonDecode(json) as Map<String, dynamic>;

      expect(sarif[r'$schema'], contains('sarif'));
      expect(sarif['version'], '2.1.0');
    });

    test('adds results with auto-registered rules', () {
      final builder = SarifBuilder(
        toolName: 'test_tool',
        toolVersion: '1.0.0',
        toolUri: 'https://example.com',
      );

      builder.addResult(
        ruleId: 'test_rule',
        message: 'Test message',
        level: SarifLevel.error,
        filePath: 'lib/test.dart',
        line: 10,
        column: 5,
      );

      final doc = builder.build();
      expect(doc.results, hasLength(1));
      expect(doc.tool.rules, hasLength(1));
      expect(doc.tool.rules.first.id, 'test_rule');
    });

    test('deduplicates rules', () {
      final builder = SarifBuilder(
        toolName: 'test_tool',
        toolVersion: '1.0.0',
        toolUri: 'https://example.com',
      );

      builder.addResult(
        ruleId: 'same_rule',
        message: 'First',
        level: SarifLevel.error,
        filePath: 'a.dart',
        line: 1,
        column: 1,
      );
      builder.addResult(
        ruleId: 'same_rule',
        message: 'Second',
        level: SarifLevel.error,
        filePath: 'b.dart',
        line: 2,
        column: 1,
      );

      final doc = builder.build();
      expect(doc.results, hasLength(2));
      expect(doc.tool.rules, hasLength(1)); // Only one rule entry
    });
  });
}
```

#### Step 1.4: Add CLI Option

Update `lib/src/cli/commands/analyze_command.dart`:

```dart
argParser.addOption(
  'reporter',
  abbr: 'r',
  allowed: ['console', 'json', 'sarif'],  // Add 'sarif'
  defaultsTo: 'console',
  help: 'Select the output format.',
);
```

Update `lib/src/core/shield_runner.dart`:

```dart
List<Reporter> _getReporters(String mode) {
  return switch (mode) {
    'json' => [JsonReporter()],
    'sarif' => [SarifReporter()],
    'console' => [ConsoleReporter()],
    _ => [ConsoleReporter()],
  };
}
```

#### Step 1.4: Add GitHub Actions Integration Docs

Create `docs/guides/ci-cd/github-actions.mdx`:

```markdown
# GitHub Actions Integration

## Upload SARIF to GitHub Security

```yaml
- name: Run dart_shield
  run: dart_shield analyze --reporter=sarif > results.sarif

- name: Upload SARIF
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: results.sarif
```
```

### Acceptance Criteria

- [ ] Tests written before implementation
- [ ] `SarifReporter` generates valid SARIF 2.1.0
- [ ] All severity levels mapped correctly
- [ ] File locations include line and column
- [ ] `--reporter=sarif` flag works
- [ ] Documentation for GitHub Actions integration
- [ ] All tests pass

---

## Task 2: Implement Baseline File Support

### Priority: P1 (High)

### Branch: `feature/baseline-support`

### Context

Baseline files allow teams to adopt dart_shield in existing projects without being overwhelmed by legacy issues. The tool records all current issues, then only reports **new** violations.

This eliminates the "all or nothing" adoption barrier.

### Implementation Steps

#### Step 2.1: Write Tests First

**File: `test/src/baseline/baseline_manager_test.dart`**

```dart
import 'dart:io';

import 'package:dart_shield/src/baseline/baseline_manager.dart';
import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/issue_context.dart';
import 'package:test/test.dart';

void main() {
  group('BaselineManager', () {
    late Directory tempDir;
    late File baselineFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('baseline_test_');
      baselineFile = File('${tempDir.path}/shield_baseline.yaml');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('creates baseline file from issues', () async {
      final manager = BaselineManager(baselineFile.path);
      final issues = [
        AnalysisIssue(
          ruleId: 'avoid_hardcoded_secrets',
          severity: Severity.high,
          message: 'Secret detected',
          context: FileContext(filePath: 'lib/api.dart', line: 10, column: 5),
        ),
      ];

      await manager.createBaseline(issues);

      expect(baselineFile.existsSync(), isTrue);
      final content = baselineFile.readAsStringSync();
      expect(content, contains('avoid_hardcoded_secrets'));
      expect(content, contains('lib/api.dart'));
      expect(content, contains('10')); // line number
    });

    test('loads existing baseline', () async {
      baselineFile.writeAsStringSync('''
baseline:
  - rule_id: avoid_hardcoded_secrets
    file: lib/api.dart
    line: 10
    fingerprint: abc123
''');

      final manager = BaselineManager(baselineFile.path);
      final baseline = await manager.loadBaseline();

      expect(baseline, hasLength(1));
      expect(baseline.first.ruleId, 'avoid_hardcoded_secrets');
    });

    test('filters out baselined issues', () async {
      baselineFile.writeAsStringSync('''
baseline:
  - rule_id: avoid_hardcoded_secrets
    file: lib/api.dart
    line: 10
    fingerprint: abc123
''');

      final manager = BaselineManager(baselineFile.path);
      final issues = [
        // This should be filtered (in baseline)
        AnalysisIssue(
          ruleId: 'avoid_hardcoded_secrets',
          severity: Severity.high,
          message: 'Secret detected',
          context: FileContext(filePath: 'lib/api.dart', line: 10, column: 5),
        ),
        // This should NOT be filtered (new issue)
        AnalysisIssue(
          ruleId: 'prefer_https_over_http',
          severity: Severity.high,
          message: 'HTTP detected',
          context: FileContext(filePath: 'lib/client.dart', line: 20, column: 3),
        ),
      ];

      final filtered = await manager.filterBaselined(issues);

      expect(filtered, hasLength(1));
      expect(filtered.first.ruleId, 'prefer_https_over_http');
    });

    test('generates stable fingerprint', () {
      final manager = BaselineManager(baselineFile.path);
      
      final issue = AnalysisIssue(
        ruleId: 'test_rule',
        severity: Severity.medium,
        message: 'Test message',
        context: FileContext(filePath: 'lib/test.dart', line: 5, column: 1),
      );

      final fp1 = manager.generateFingerprint(issue);
      final fp2 = manager.generateFingerprint(issue);

      expect(fp1, equals(fp2));
    });

    test('fingerprint changes when line changes', () {
      final manager = BaselineManager(baselineFile.path);
      
      final issue1 = AnalysisIssue(
        ruleId: 'test_rule',
        severity: Severity.medium,
        message: 'Test message',
        context: FileContext(filePath: 'lib/test.dart', line: 5, column: 1),
      );
      
      final issue2 = AnalysisIssue(
        ruleId: 'test_rule',
        severity: Severity.medium,
        message: 'Test message',
        context: FileContext(filePath: 'lib/test.dart', line: 6, column: 1),
      );

      final fp1 = manager.generateFingerprint(issue1);
      final fp2 = manager.generateFingerprint(issue2);

      expect(fp1, isNot(equals(fp2)));
    });

    test('returns empty list when no baseline exists', () async {
      final manager = BaselineManager('nonexistent.yaml');
      final baseline = await manager.loadBaseline();

      expect(baseline, isEmpty);
    });
  });
}
```

#### Step 2.2: Implement BaselineManager

**File: `lib/src/baseline/baseline_manager.dart`**

```dart
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class BaselineManager {
  BaselineManager(this.baselinePath);

  final String baselinePath;

  Future<void> createBaseline(List<AnalysisIssue> issues) async {
    final entries = issues.map((issue) => {
      'rule_id': issue.ruleId,
      'file': issue.context.filePath,
      'line': issue.context.line,
      'fingerprint': generateFingerprint(issue),
    }).toList();

    final yaml = YamlEditor('')
      ..update(['baseline'], entries);

    final file = File(baselinePath);
    await file.writeAsString(yaml.toString());
  }

  Future<List<BaselineEntry>> loadBaseline() async {
    final file = File(baselinePath);
    if (!file.existsSync()) return [];

    final content = await file.readAsString();
    final yaml = loadYaml(content) as YamlMap?;
    if (yaml == null) return [];

    final baseline = yaml['baseline'] as YamlList?;
    if (baseline == null) return [];

    return baseline.map((entry) => BaselineEntry.fromYaml(entry)).toList();
  }

  Future<List<AnalysisIssue>> filterBaselined(List<AnalysisIssue> issues) async {
    final baseline = await loadBaseline();
    final baselineFingerprints = baseline.map((e) => e.fingerprint).toSet();

    return issues.where((issue) {
      final fp = generateFingerprint(issue);
      return !baselineFingerprints.contains(fp);
    }).toList();
  }

  String generateFingerprint(AnalysisIssue issue) {
    final data = '${issue.ruleId}:${issue.context.filePath}:${issue.context.line}';
    return md5.convert(utf8.encode(data)).toString().substring(0, 12);
  }
}

class BaselineEntry {
  BaselineEntry({
    required this.ruleId,
    required this.file,
    required this.line,
    required this.fingerprint,
  });

  factory BaselineEntry.fromYaml(YamlMap yaml) {
    return BaselineEntry(
      ruleId: yaml['rule_id'] as String,
      file: yaml['file'] as String,
      line: yaml['line'] as int,
      fingerprint: yaml['fingerprint'] as String,
    );
  }

  final String ruleId;
  final String file;
  final int line;
  final String fingerprint;
}
```

#### Step 2.3: Add CLI Commands

**New command: `dart_shield baseline`**

```dart
// lib/src/cli/commands/baseline_command.dart
class BaselineCommand extends ShieldCommand {
  BaselineCommand({super.logger}) {
    argParser.addFlag(
      'update',
      abbr: 'u',
      help: 'Update existing baseline with current issues.',
    );
  }

  @override
  String get name => 'baseline';

  @override
  String get description => 'Create or update a baseline file for existing issues.';

  @override
  Future<int> run() async {
    // Implementation: run analysis, then create baseline
  }
}
```

**Update analyze command:**

```dart
argParser.addOption(
  'baseline',
  abbr: 'b',
  help: 'Path to baseline file. Issues in baseline are not reported.',
);
```

### Acceptance Criteria

- [ ] Tests written before implementation
- [ ] `dart_shield baseline` command creates `shield_baseline.yaml`
- [ ] `dart_shield analyze --baseline=shield_baseline.yaml` filters issues
- [ ] Fingerprints are stable and reproducible
- [ ] Baseline file format is human-readable YAML
- [ ] Documentation explains baseline workflow
- [ ] All tests pass

---

## Task 3: Add New Security Rules (5-10 rules)

### Priority: P2 (Medium)

### Branch: `feature/new-security-rules`

### Context

The current 5 rules are a good start, but insufficient for comprehensive security coverage. This task adds rules for common vulnerability patterns.

### New Rules to Implement

#### 3.1 Insecure Storage Rules

**Rule: `avoid_shared_preferences_for_secrets`**

Detects storing sensitive data in SharedPreferences (unencrypted).

**File: `test/src/analyzers/code/rules/storage/avoid_shared_preferences_for_secrets_test.dart`**

```dart
@reflectiveTest
class AvoidSharedPreferencesForSecretsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('shared_preferences')
      ..addFile('lib/shared_preferences.dart', r'''
class SharedPreferences {
  Future<bool> setString(String key, String value) async => true;
  String? getString(String key) => null;
}
''');
    rule = AvoidSharedPreferencesForSecrets();
    super.setUp();
  }

  void test_setStringWithSecretKey_reports() async {
    await assertDiagnostics(
      r'''
import 'package:shared_preferences/shared_preferences.dart';
void f(SharedPreferences prefs) {
  prefs.setString('password', 'secret123');
}
''',
      [lint(95, 40)],
    );
  }

  void test_setStringWithNormalKey_noReport() async {
    await assertNoDiagnostics(
      r'''
import 'package:shared_preferences/shared_preferences.dart';
void f(SharedPreferences prefs) {
  prefs.setString('theme', 'dark');
}
''',
    );
  }
}
```

**Sensitive keys to detect:** `password`, `token`, `secret`, `api_key`, `apiKey`, `auth`, `credential`, `private_key`

#### 3.2 Network Security Rules

**Rule: `avoid_certificate_pinning_bypass`**

Detects disabling certificate validation.

```dart
// Detects patterns like:
HttpClient()..badCertificateCallback = (cert, host, port) => true;
```

**Rule: `avoid_allow_any_https_certificate`**

Detects Flutter's `HttpOverrides` being used unsafely.

#### 3.3 Input Validation Rules

**Rule: `avoid_dynamic_sql_queries`**

Detects string concatenation in SQL-like queries.

```dart
// Detects patterns like:
db.execute('SELECT * FROM users WHERE id = $userId');
db.rawQuery('DELETE FROM ${tableName}');
```

#### 3.4 Logging Rules

**Rule: `avoid_logging_sensitive_data`**

Detects printing/logging variables with sensitive names.

```dart
// Detects patterns like:
print(password);
log(apiKey);
debugPrint(token);
```

### Implementation Steps (Per Rule)

1. **Write test file first** using `AnalysisRuleTest`
2. **Create stub packages** if needed (SharedPreferences, sqflite, etc.)
3. **Run tests** - verify they fail
4. **Implement rule** in `lib/src/analyzers/code/rules/<category>/`
5. **Register rule** in `lib/src/analyzers/code/rules/rules.dart`
6. **Add rule metadata** with severity and OWASP/CWE references
7. **Run tests** - verify they pass
8. **Add documentation** in `docs/rulebook/<category>/`

### New Rules Summary

| Rule ID | Category | Severity | CWE |
|---------|----------|----------|-----|
| `avoid_shared_preferences_for_secrets` | storage | high | CWE-312 |
| `avoid_insecure_file_storage` | storage | high | CWE-922 |
| `avoid_certificate_pinning_bypass` | network | high | CWE-295 |
| `avoid_dynamic_sql_queries` | injection | high | CWE-89 |
| `avoid_logging_sensitive_data` | logging | medium | CWE-532 |
| `avoid_biometric_without_encryption` | auth | medium | CWE-287 |

### Acceptance Criteria

- [ ] Tests written before each rule implementation
- [ ] At least 6 new rules implemented
- [ ] Each rule has 5+ test cases
- [ ] Each rule has severity metadata with OWASP/CWE
- [ ] Each rule has documentation page
- [ ] All rules registered and working
- [ ] All tests pass

---

## Task 4: Add Flutter-Specific Rules

### Priority: P2 (Medium)

### Branch: `feature/flutter-specific-rules`

### Context

Flutter apps have unique security concerns (mobile manifests, WebView, platform channels). These rules target Flutter-specific vulnerabilities.

### Rules to Implement

#### 4.1 WebView Security

**Rule: `avoid_insecure_webview_settings`**

Detects unsafe WebView configurations.

```dart
// Detects:
WebView(javascriptMode: JavascriptMode.unrestricted)
WebViewWidget(controller: controller..setJavaScriptMode(JavaScriptMode.unrestricted))
```

**Rule: `avoid_webview_javascript_channels_leaking_data`**

Detects JavaScript channels that might expose sensitive data.

#### 4.2 Deep Link Security

**Rule: `validate_deep_link_parameters`**

Warns when deep link parameters are used without validation.

#### 4.3 Platform Channel Security

**Rule: `avoid_unvalidated_platform_channel_data`**

Detects using platform channel data without validation.

### Test Structure Example

```dart
@reflectiveTest
class AvoidInsecureWebviewSettingsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('webview_flutter')
      ..addFile('lib/webview_flutter.dart', r'''
enum JavascriptMode { disabled, unrestricted }
class WebView {
  WebView({this.javascriptMode = JavascriptMode.disabled});
  final JavascriptMode javascriptMode;
}
''');
    rule = AvoidInsecureWebviewSettings();
    super.setUp();
  }

  void test_unrestrictedJavascript_reports() async {
    await assertDiagnostics(
      r'''
import 'package:webview_flutter/webview_flutter.dart';
Widget build() {
  return WebView(javascriptMode: JavascriptMode.unrestricted);
}
''',
      [lint(71, 52)],
    );
  }
}
```

### Acceptance Criteria

- [ ] Tests written before each rule implementation
- [ ] At least 3 Flutter-specific rules implemented
- [ ] Rules handle both old and new WebView APIs
- [ ] Documentation explains Flutter-specific risks
- [ ] All tests pass

---

## Execution Order

1. **Task 1** - SARIF Reporter (highest value, enables GitHub integration)
2. **Task 2** - Baseline Support (enables gradual adoption)
3. **Task 3** - New Security Rules (expands coverage)
4. **Task 4** - Flutter-Specific Rules (niche differentiation)

---

## Git Workflow Summary

```bash
# For each task:
git checkout main
git pull origin main
git checkout -b feature/<feature-name>

# TDD cycle
# 1. Write tests
# 2. Run tests (fail)
# 3. Implement
# 4. Run tests (pass)
# 5. Refactor

# Commit frequently with good messages
git add .
git commit -m "test: add tests for <feature>"
git commit -m "feat: implement <feature>"
git commit -m "docs: add documentation for <feature>"

# Push and create PR
git push -u origin feature/<feature-name>

# After PR review and merge
git checkout main
git pull origin main
git branch -d feature/<feature-name>
```

---

## Verification Checklist

After completing all tasks:

- [ ] All tests pass (`dart test`)
- [ ] Code analysis passes (`dart analyze`)
- [ ] `dart_shield analyze --reporter=sarif` produces valid SARIF
- [ ] Baseline workflow documented and working
- [ ] At least 11 total rules (5 existing + 6 new)
- [ ] All new rules have tests and documentation
- [ ] PR created from feature branch for each task
- [ ] CHANGELOG.md updated

---

## References

- **SARIF Specification:** https://sarifweb.azurewebsites.net/
- **GitHub SARIF Upload:** https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/uploading-a-sarif-file-to-github
- **OWASP Mobile Top 10:** https://owasp.org/www-project-mobile-top-10/
- **CWE Database:** https://cwe.mitre.org/
- **Rule Testing Framework:** https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server_plugin/doc/testing_rules.md
