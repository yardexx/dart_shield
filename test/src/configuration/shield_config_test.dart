import 'dart:io';

import 'package:dart_shield/src/configuration/shield_config.dart';
import 'package:dart_shield/src/domain/exceptions.dart';
import 'package:test/test.dart';

void main() {
  group('ShieldConfig', () {
    late File configFile;

    setUp(() {
      configFile = File('analysis_options.yaml');
    });

    tearDown(() {
      if (configFile.existsSync()) {
        configFile.deleteSync();
      }
    });

    test('returns default config when file does not exist', () async {
      if (configFile.existsSync()) configFile.deleteSync();
      final config = await ShieldConfig.load();
      expect(config.analyzers.code, isTrue);
      expect(config.analyzers.deps, isTrue);
    });

    test('returns default config when file is empty', () async {
      configFile.writeAsStringSync('');
      final config = await ShieldConfig.load();
      expect(config.analyzers.code, isTrue);
    });

    test('parses valid configuration correctly', () async {
      configFile.writeAsStringSync('''
dart_shield:
  analyzers:
    code: false
    deps: false
''');
      final config = await ShieldConfig.load();
      expect(config.analyzers.code, isFalse);
      expect(config.analyzers.deps, isFalse);
    });

    test('throws ConfigException on invalid yaml syntax', () async {
      configFile.writeAsStringSync('''
dart_shield:
  analyzers: [
'''); // Broken YAML
      expect(ShieldConfig.load, throwsA(isA<ConfigException>()));
    });

    test('throws ConfigException on type mismatch', () async {
      configFile.writeAsStringSync('''
dart_shield:
  analyzers: "invalid_string" 
''');
      expect(ShieldConfig.load, throwsA(isA<ConfigException>()));
    });
  });
}
