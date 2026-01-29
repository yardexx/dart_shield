import 'dart:convert';

import 'package:sarif/sarif.dart';
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

    test('includes tool information', () {
      final builder = SarifBuilder(
        toolName: 'my_tool',
        toolVersion: '2.0.0',
        toolUri: 'https://example.com/tool',
      );

      final json = builder.buildJson();
      final sarif = jsonDecode(json) as Map<String, dynamic>;
      final tool = sarif['runs'][0]['tool']['driver'] as Map<String, dynamic>;

      expect(tool['name'], 'my_tool');
      expect(tool['version'], '2.0.0');
      expect(tool['informationUri'], 'https://example.com/tool');
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
      final run = doc.runs.first;
      expect(run.results, hasLength(1));
      expect(run.tool.driver.rules, hasLength(1));
      expect(run.tool.driver.rules.first.id, 'test_rule');
    });

    test('deduplicates rules', () {
      final builder = SarifBuilder(
        toolName: 'test_tool',
        toolVersion: '1.0.0',
        toolUri: 'https://example.com',
      );

      builder
        ..addResult(
          ruleId: 'same_rule',
          message: 'First',
          level: SarifLevel.error,
          filePath: 'a.dart',
          line: 1,
          column: 1,
        )
        ..addResult(
          ruleId: 'same_rule',
          message: 'Second',
          level: SarifLevel.error,
          filePath: 'b.dart',
          line: 2,
          column: 1,
        );

      final doc = builder.build();
      final run = doc.runs.first;
      expect(run.results, hasLength(2));
      expect(run.tool.driver.rules, hasLength(1)); // Only one rule entry
    });

    test('generates rule description from id if not provided', () {
      final builder = SarifBuilder(
        toolName: 'test_tool',
        toolVersion: '1.0.0',
        toolUri: 'https://example.com',
      );

      builder.addResult(
        ruleId: 'avoid_hardcoded_secrets',
        message: 'Secret found',
        level: SarifLevel.error,
        filePath: 'lib/api.dart',
        line: 1,
        column: 1,
      );

      final doc = builder.build();
      final run = doc.runs.first;
      expect(
        run.tool.driver.rules.first.shortDescription.text,
        'avoid hardcoded secrets',
      );
    });

    test('uses custom rule description when provided', () {
      final builder = SarifBuilder(
        toolName: 'test_tool',
        toolVersion: '1.0.0',
        toolUri: 'https://example.com',
      );

      builder.addResult(
        ruleId: 'test_rule',
        message: 'Test message',
        level: SarifLevel.warning,
        filePath: 'lib/test.dart',
        line: 1,
        column: 1,
        ruleDescription: 'Custom description',
        ruleHelpUri: 'https://docs.example.com/rules/test',
      );

      final doc = builder.build();
      final run = doc.runs.first;
      final rule = run.tool.driver.rules.first;
      expect(rule.shortDescription.text, 'Custom description');
      expect(rule.helpUri, 'https://docs.example.com/rules/test');
    });

    test('buildJson produces valid JSON with runs array', () {
      final builder = SarifBuilder(
        toolName: 'test_tool',
        toolVersion: '1.0.0',
        toolUri: 'https://example.com',
      );

      builder.addResult(
        ruleId: 'rule1',
        message: 'Message 1',
        level: SarifLevel.error,
        filePath: 'a.dart',
        line: 5,
        column: 10,
      );

      final json = builder.buildJson();
      final sarif = jsonDecode(json) as Map<String, dynamic>;

      expect(sarif['runs'], isA<List>());
      expect((sarif['runs'] as List), hasLength(1));

      final run = sarif['runs'][0] as Map<String, dynamic>;
      expect(run['tool'], isA<Map>());
      expect(run['results'], isA<List>());
    });

    test('buildJson without pretty print produces compact JSON', () {
      final builder = SarifBuilder(
        toolName: 'test_tool',
        toolVersion: '1.0.0',
        toolUri: 'https://example.com',
      );

      final compactJson = builder.buildJson(pretty: false);
      final prettyJson = builder.buildJson();

      expect(compactJson.contains('\n'), isFalse);
      expect(prettyJson.contains('\n'), isTrue);
    });

    test('empty builder produces valid SARIF with no results', () {
      final builder = SarifBuilder(
        toolName: 'test_tool',
        toolVersion: '1.0.0',
        toolUri: 'https://example.com',
      );

      final doc = builder.build();
      final run = doc.runs.first;
      expect(run.results, isEmpty);
      expect(run.tool.driver.rules, isEmpty);

      final json = builder.buildJson();
      final sarif = jsonDecode(json) as Map<String, dynamic>;
      expect(sarif['runs'][0]['results'], isEmpty);
    });
  });

  group('SarifDocument', () {
    test('toJson includes schema and version', () {
      final doc = SarifDocument(
        runs: [
          SarifRun(
            tool: SarifTool(
              driver: SarifDriver(
                name: 'test',
                version: '1.0.0',
                informationUri: 'https://example.com',
              ),
            ),
            results: [],
          ),
        ],
      );

      final json = doc.toJson();
      expect(json[r'$schema'], contains('sarif'));
      expect(json['version'], '2.1.0');
    });
  });

  group('SarifResult', () {
    test('toJson includes all required fields', () {
      final result = SarifResult(
        ruleId: 'test_rule',
        level: SarifLevel.error,
        message: SarifMessage(text: 'Test message'),
        locations: [
          SarifLocation(
            physicalLocation: SarifPhysicalLocation(
              artifactLocation: SarifArtifactLocation(uri: 'lib/test.dart'),
              region: SarifRegion(startLine: 10, startColumn: 5),
            ),
          ),
        ],
      );

      final json = result.toJson();
      expect(json['ruleId'], 'test_rule');
      expect(json['level'], 'error');
      final message = json['message'] as Map<String, dynamic>;
      expect(message['text'], 'Test message');
      expect(json['locations'], isA<List>());
    });
  });

  group('SarifLocation', () {
    test('toJson includes physical location', () {
      final location = SarifLocation(
        physicalLocation: SarifPhysicalLocation(
          artifactLocation: SarifArtifactLocation(uri: 'lib/src/api.dart'),
          region: SarifRegion(startLine: 42, startColumn: 10),
        ),
      );

      final json = location.toJson();
      final physical = json['physicalLocation'] as Map<String, dynamic>;
      final artifactLocation =
          physical['artifactLocation'] as Map<String, dynamic>;
      final region = physical['region'] as Map<String, dynamic>;
      expect(artifactLocation['uri'], 'lib/src/api.dart');
      expect(region['startLine'], 42);
      expect(region['startColumn'], 10);
    });

    test('toJson includes end line/column when provided', () {
      final location = SarifLocation(
        physicalLocation: SarifPhysicalLocation(
          artifactLocation: SarifArtifactLocation(uri: 'lib/test.dart'),
          region: SarifRegion(
            startLine: 10,
            startColumn: 5,
            endLine: 10,
            endColumn: 20,
          ),
        ),
      );

      final json = location.toJson();
      final physical = json['physicalLocation'] as Map<String, dynamic>;
      final region = physical['region'] as Map<String, dynamic>;
      expect(region['endLine'], 10);
      expect(region['endColumn'], 20);
    });

    test('toJson omits end line/column when not provided', () {
      final location = SarifLocation(
        physicalLocation: SarifPhysicalLocation(
          artifactLocation: SarifArtifactLocation(uri: 'lib/test.dart'),
          region: SarifRegion(startLine: 10, startColumn: 5),
        ),
      );

      final json = location.toJson();
      final physical = json['physicalLocation'] as Map<String, dynamic>;
      final region = physical['region'] as Map<String, dynamic>;
      expect(region.containsKey('endLine'), isFalse);
      expect(region.containsKey('endColumn'), isFalse);
    });
  });

  group('SarifLevel', () {
    test('enum values match SARIF specification', () {
      expect(SarifLevel.error.name, 'error');
      expect(SarifLevel.warning.name, 'warning');
      expect(SarifLevel.note.name, 'note');
      expect(SarifLevel.none.name, 'none');
    });
  });

  group('SarifRule', () {
    test('toJson includes id and shortDescription', () {
      final rule = SarifRule(
        id: 'test_rule',
        shortDescription: SarifMessage(text: 'Test description'),
      );

      final json = rule.toJson();
      expect(json['id'], 'test_rule');
      final shortDesc = json['shortDescription'] as Map<String, dynamic>;
      expect(shortDesc['text'], 'Test description');
    });

    test('toJson includes optional fields when provided', () {
      final rule = SarifRule(
        id: 'test_rule',
        shortDescription: SarifMessage(text: 'Short'),
        fullDescription: SarifMessage(text: 'Full description of the rule'),
        helpUri: 'https://docs.example.com/rules/test',
      );

      final json = rule.toJson();
      final fullDesc = json['fullDescription'] as Map<String, dynamic>;
      expect(fullDesc['text'], 'Full description of the rule');
      expect(json['helpUri'], 'https://docs.example.com/rules/test');
    });

    test('toJson omits optional fields when not provided', () {
      final rule = SarifRule(
        id: 'test_rule',
        shortDescription: SarifMessage(text: 'Short'),
      );

      final json = rule.toJson();
      expect(json.containsKey('fullDescription'), isFalse);
      expect(json.containsKey('helpUri'), isFalse);
    });
  });
}
