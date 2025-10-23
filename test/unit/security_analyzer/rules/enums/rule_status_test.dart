import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:test/test.dart';

void main() {
  group('RuleStatus', () {
    group('enum values', () {
      test('has experimental status', () {
        expect(RuleStatus.experimental.name, equals('experimental'));
      });

      test('has stable status', () {
        expect(RuleStatus.stable.name, equals('stable'));
      });

      test('has deprecated status', () {
        expect(RuleStatus.deprecated.name, equals('deprecated'));
      });
    });

    group('enum properties', () {
      test('has all expected status values', () {
        expect(RuleStatus.values.length, equals(3));
        expect(RuleStatus.values, contains(RuleStatus.experimental));
        expect(RuleStatus.values, contains(RuleStatus.stable));
        expect(RuleStatus.values, contains(RuleStatus.deprecated));
      });

      test('enum values are unique', () {
        final values = RuleStatus.values.map((e) => e.name).toSet();
        expect(values.length, equals(RuleStatus.values.length));
      });
    });

    group('status lifecycle', () {
      test('experimental is initial status', () {
        expect(RuleStatus.experimental.name, equals('experimental'));
      });

      test('stable is production status', () {
        expect(RuleStatus.stable.name, equals('stable'));
      });

      test('deprecated is end-of-life status', () {
        expect(RuleStatus.deprecated.name, equals('deprecated'));
      });
    });

    group('status ordering', () {
      test('status values are ordered logically', () {
        expect(RuleStatus.values.indexOf(RuleStatus.experimental), equals(0));
        expect(RuleStatus.values.indexOf(RuleStatus.stable), equals(1));
        expect(RuleStatus.values.indexOf(RuleStatus.deprecated), equals(2));
      });
    });
  });
}
