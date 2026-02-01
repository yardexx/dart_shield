import 'dart:convert';

import 'package:sarif/src/models/models.dart';

/// Fluent builder for SARIF documents.
class SarifBuilder {
  SarifBuilder({
    required String toolName,
    required String toolVersion,
    required String toolUri,
  }) : _toolName = toolName,
       _toolVersion = toolVersion,
       _toolUri = toolUri;

  final String _toolName;
  final String _toolVersion;
  final String _toolUri;
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
        shortDescription: SarifMessage(
          text: ruleDescription ?? ruleId.replaceAll('_', ' '),
        ),
        helpUri: ruleHelpUri,
      ),
    );

    final result = SarifResult(
      ruleId: ruleId,
      level: level,
      message: SarifMessage(text: message),
      locations: [
        SarifLocation(
          physicalLocation: SarifPhysicalLocation(
            artifactLocation: SarifArtifactLocation(uri: filePath),
            region: SarifRegion(startLine: line, startColumn: column),
          ),
        ),
      ],
    );

    _results.add(result);
  }

  /// Build the SARIF document.
  SarifDocument build() {
    return SarifDocument(
      runs: [
        SarifRun(
          tool: SarifTool(
            driver: SarifDriver(
              name: _toolName,
              version: _toolVersion,
              informationUri: _toolUri,
              rules: _rules.values.toList(),
            ),
          ),
          results: _results,
        ),
      ],
    );
  }

  /// Build and serialize to JSON string.
  String buildJson() {
    final doc = build();
    return jsonEncode(doc.toJson());
  }
}
