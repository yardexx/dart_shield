import 'dart:convert';

import 'package:dart_shield/src/reporters/sarif/sarif_document.dart';

/// Fluent builder for SARIF documents.
///
/// This class has NO dependencies on dart_shield domain models.
/// It can be extracted to a standalone package.
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

    _results.add(
      SarifResult(
        ruleId: ruleId,
        level: level,
        message: message,
        location: SarifLocation(
          filePath: filePath,
          startLine: line,
          startColumn: column,
        ),
      ),
    );
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
