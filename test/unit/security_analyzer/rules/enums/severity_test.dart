import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:dart_shield/src/security_analyzer/rules/enums/enums.dart';
import 'package:test/test.dart';

void main() {
  group('Severity', () {
    group('enum values', () {
      test('has correct critical severity', () {
        expect(Severity.critical.value, equals('critical'));
        expect(
          Severity.critical.analysisSeverity,
          equals(AnalysisErrorSeverity.ERROR),
        );
      });

      test('has correct warning severity', () {
        expect(Severity.warning.value, equals('warning'));
        expect(
          Severity.warning.analysisSeverity,
          equals(AnalysisErrorSeverity.WARNING),
        );
      });

      test('has correct info severity', () {
        expect(Severity.info.value, equals('info'));
        expect(
          Severity.info.analysisSeverity,
          equals(AnalysisErrorSeverity.INFO),
        );
      });
    });

    group('enum properties', () {
      test('has all expected severity levels', () {
        expect(Severity.values.length, equals(3));
        expect(Severity.values, contains(Severity.critical));
        expect(Severity.values, contains(Severity.warning));
        expect(Severity.values, contains(Severity.info));
      });

      test('severity levels are ordered correctly', () {
        expect(Severity.values.indexOf(Severity.critical), equals(0));
        expect(Severity.values.indexOf(Severity.warning), equals(1));
        expect(Severity.values.indexOf(Severity.info), equals(2));
      });

      test('enum values are unique', () {
        final values = Severity.values.map((e) => e.name).toSet();
        expect(values.length, equals(Severity.values.length));
      });
    });

    group('severity comparison', () {
      test('critical is more severe than warning', () {
        expect(
          Severity.critical.analysisSeverity.index,
          greaterThan(Severity.warning.analysisSeverity.index),
        );
      });

      test('warning is more severe than info', () {
        expect(
          Severity.warning.analysisSeverity.index,
          greaterThan(Severity.info.analysisSeverity.index),
        );
      });

      test('critical is more severe than info', () {
        expect(
          Severity.critical.analysisSeverity.index,
          greaterThan(Severity.info.analysisSeverity.index),
        );
      });
    });

    group('string representation', () {
      test('value property matches name', () {
        for (final severity in Severity.values) {
          expect(severity.value, equals(severity.name));
        }
      });
    });
  });
}
