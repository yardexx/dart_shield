import 'package:dart_shield/src/security_analyzer/configuration/lint_rule_converter.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:dart_shield/src/security_analyzer/rules/rules.dart';
import 'package:test/test.dart';

void main() {
  const converter = LintRuleConverter();

  group('LintRuleConverter', () {
    test('fromJson should return a LintRule object for valid ruleId', () {
      final rule = converter.fromJson(RuleId.avoidHardcodedUrls.name);
      expect(rule, isA<LintRule>());
      expect(rule.id, equals(RuleId.avoidHardcodedUrls));
    });

    test('fromJson should throw an exception for invalid ruleId', () {
      expect(() => converter.fromJson('Invalid_RuleId'), throwsStateError);
    });

    test('toJson should return a string for valid LintRule', () {
      final rule = RuleCreator.createRule(
        id: RuleId.avoidHardcodedUrls,
        excludes: [],
      );
      final ruleId = converter.toJson(rule);
      expect(ruleId, isA<String>());
      expect(ruleId, equals(RuleId.avoidHardcodedUrls.name));
    });
  });
}
