import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dart_shield/src/domain/analysis_issue.dart';
import 'package:dart_shield/src/domain/issue_context.dart';
import 'package:yaml/yaml.dart';

/// Manages baseline files for tracking known issues.
///
/// Baseline files allow teams to adopt dart_shield in existing projects
/// without being overwhelmed by legacy issues. The tool records all current
/// issues, then only reports new violations.
class BaselineManager {
  BaselineManager(this.baselinePath);

  /// Path to the baseline file.
  final String baselinePath;

  /// Create a baseline file from the given issues.
  Future<void> createBaseline(List<AnalysisIssue> issues) async {
    final entries = issues.map((issue) {
      final context = issue.context;
      final filePath = switch (context) {
        FileContext(:final filePath) => filePath,
      };
      final line = switch (context) {
        FileContext(:final line) => line,
      };

      return {
        'rule_id': issue.ruleId,
        'file': filePath,
        'line': line,
        'fingerprint': generateFingerprint(issue),
      };
    }).toList();

    final yamlContent = _generateYaml(entries);

    final file = File(baselinePath);
    await file.writeAsString(yamlContent);
  }

  /// Load the baseline entries from the file.
  Future<List<BaselineEntry>> loadBaseline() async {
    final file = File(baselinePath);
    if (!file.existsSync()) return [];

    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];

    final yaml = loadYaml(content);
    if (yaml == null) return [];

    final yamlMap = yaml as YamlMap;
    final baseline = yamlMap['baseline'];
    if (baseline == null) return [];

    final baselineList = baseline as YamlList;
    return baselineList.map((entry) {
      final entryMap = entry as YamlMap;
      return BaselineEntry(
        ruleId: entryMap['rule_id'] as String,
        file: entryMap['file'] as String,
        line: entryMap['line'] as int,
        fingerprint: entryMap['fingerprint'] as String,
      );
    }).toList();
  }

  /// Filter out issues that are already in the baseline.
  Future<List<AnalysisIssue>> filterBaselined(List<AnalysisIssue> issues) async {
    final baseline = await loadBaseline();
    final baselineFingerprints = baseline.map((e) => e.fingerprint).toSet();

    return issues.where((issue) {
      final fp = generateFingerprint(issue);
      return !baselineFingerprints.contains(fp);
    }).toList();
  }

  /// Generate a stable fingerprint for an issue.
  ///
  /// The fingerprint is based on the rule ID, file path, and line number.
  /// This allows the baseline to track issues even if the message changes.
  String generateFingerprint(AnalysisIssue issue) {
    final context = issue.context;
    final filePath = switch (context) {
      FileContext(:final filePath) => filePath,
    };
    final line = switch (context) {
      FileContext(:final line) => line,
    };

    final data = '${issue.ruleId}:$filePath:$line';
    return md5.convert(utf8.encode(data)).toString().substring(0, 12);
  }

  /// Generate YAML content from baseline entries.
  String _generateYaml(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) {
      return 'baseline: []\n';
    }

    final buffer = StringBuffer('baseline:\n');
    for (final entry in entries) {
      buffer.writeln('  - rule_id: ${entry['rule_id']}');
      buffer.writeln('    file: ${entry['file']}');
      buffer.writeln('    line: ${entry['line']}');
      buffer.writeln('    fingerprint: ${entry['fingerprint']}');
    }
    return buffer.toString();
  }
}

/// An entry in the baseline file.
class BaselineEntry {
  BaselineEntry({
    required this.ruleId,
    required this.file,
    required this.line,
    required this.fingerprint,
  });

  /// The rule ID.
  final String ruleId;

  /// The file path.
  final String file;

  /// The line number.
  final int line;

  /// The fingerprint (hash of rule, file, line).
  final String fingerprint;
}
