/// Pure SARIF 2.1.0 data structures.
///
/// This file has NO dependencies on dart_shield domain models.
/// It can be extracted to a standalone package.
library;

/// A SARIF 2.1.0 document.
class SarifDocument {
  SarifDocument({
    required this.tool,
    required this.results,
  });

  /// SARIF schema URL.
  static const String schema =
      'https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json';

  /// SARIF version.
  static const String version = '2.1.0';

  /// The tool that produced the results.
  final SarifTool tool;

  /// The results produced by the tool.
  final List<SarifResult> results;

  /// Convert to JSON-serializable map.
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

/// Information about the tool that produced the SARIF results.
class SarifTool {
  SarifTool({
    required this.name,
    required this.version,
    required this.informationUri,
    this.rules = const [],
  });

  /// The name of the tool.
  final String name;

  /// The version of the tool.
  final String version;

  /// A URI where the tool can be found.
  final String informationUri;

  /// The rules defined by the tool.
  final List<SarifRule> rules;

  /// Convert to JSON-serializable map.
  Map<String, dynamic> toJson() => {
        'driver': {
          'name': name,
          'version': version,
          'informationUri': informationUri,
          'rules': rules.map((r) => r.toJson()).toList(),
        },
      };
}

/// A rule defined by a SARIF tool.
class SarifRule {
  SarifRule({
    required this.id,
    required this.shortDescription,
    this.fullDescription,
    this.helpUri,
  });

  /// The rule identifier.
  final String id;

  /// A short description of the rule.
  final String shortDescription;

  /// A full description of the rule.
  final String? fullDescription;

  /// A URI where help for the rule can be found.
  final String? helpUri;

  /// Convert to JSON-serializable map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'shortDescription': {'text': shortDescription},
        if (fullDescription != null)
          'fullDescription': {'text': fullDescription},
        if (helpUri != null) 'helpUri': helpUri,
      };
}

/// A single result (finding) in a SARIF document.
class SarifResult {
  SarifResult({
    required this.ruleId,
    required this.level,
    required this.message,
    required this.location,
  });

  /// The rule that produced this result.
  final String ruleId;

  /// The severity level.
  final SarifLevel level;

  /// The message describing the result.
  final String message;

  /// The location where the result was found.
  final SarifLocation location;

  /// Convert to JSON-serializable map.
  Map<String, dynamic> toJson() => {
        'ruleId': ruleId,
        'level': level.name,
        'message': {'text': message},
        'locations': [location.toJson()],
      };
}

/// SARIF severity levels.
enum SarifLevel {
  /// An error.
  error,

  /// A warning.
  warning,

  /// A note (informational).
  note,

  /// No level assigned.
  none,
}

/// A location in a SARIF result.
class SarifLocation {
  SarifLocation({
    required this.filePath,
    required this.startLine,
    required this.startColumn,
    this.endLine,
    this.endColumn,
  });

  /// The file path.
  final String filePath;

  /// The starting line number (1-based).
  final int startLine;

  /// The starting column number (1-based).
  final int startColumn;

  /// The ending line number (1-based).
  final int? endLine;

  /// The ending column number (1-based).
  final int? endColumn;

  /// Convert to JSON-serializable map.
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
