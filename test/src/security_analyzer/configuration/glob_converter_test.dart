import 'package:dart_shield/src/security_analyzer/configuration/glob_converter.dart';
import 'package:glob/glob.dart';
import 'package:test/test.dart';

void main() {
  const converter = GlobConverter();

  group('GlobConverter', () {
    test('fromJson should return a Glob object', () {
      final glob = converter.fromJson('*.dart');
      expect(glob, isA<Glob>());
      expect(glob.pattern, equals('*.dart'));
    });

    test('fromJson should handle empty string', () {
      expect(() => converter.fromJson(''), throwsException);
    });

    test('toJson should return a string', () {
      final glob = Glob('*.dart');
      final pattern = converter.toJson(glob);
      expect(pattern, isA<String>());
      expect(pattern, equals('*.dart'));
    });
  });
}
