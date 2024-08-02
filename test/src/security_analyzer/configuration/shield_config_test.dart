import 'package:dart_shield/src/security_analyzer/configuration/configuration.dart';
import 'package:dart_shield/src/security_analyzer/rules/rule/rule.dart';
import 'package:dart_shield/src/utils/utils.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../../../data/config_examples.dart';

void main() {
  group('$ShieldConfig - valid configuration', () {
    test('fromJson should handle minimal config', () {
      final map =
          yamlToDartMap(loadYaml(minimalConfig)) as Map<String, dynamic>;
      final config = ShieldConfig.fromYaml(map);

      expect(config.rules.length, equals(1));
      expect(config.rules.first, isA<LintRule>());
      expect(config.enableExperimental, equals(false));
      expect(config.experimentalRules.length, equals(0));
    });

    test('fromJson should handle exclude paths (normal)', () {
      final map =
          yamlToDartMap(loadYaml(excludePathConfig)) as Map<String, dynamic>;
      final config = ShieldConfig.fromYaml(map);

      expect(config.rules.length, equals(1));
      expect(config.rules.first, isA<LintRule>());
      expect(config.exclude.length, equals(1));
    });

    test('fromJson should handle exclude paths (glob)', () {
      final map =
          yamlToDartMap(loadYaml(excludeGlobConfig)) as Map<String, dynamic>;
      final config = ShieldConfig.fromYaml(map);

      expect(config.rules.length, equals(1));
      expect(config.rules.first, isA<LintRule>());
      expect(config.exclude.length, equals(1));
    });

    test('fromJson should handle only experimental rules', () {
      final map = yamlToDartMap(loadYaml(onlyExperimentalConfig))
          as Map<String, dynamic>;
      final config = ShieldConfig.fromYaml(map);

      expect(config.rules.length, equals(0));
      expect(config.enableExperimental, equals(true));
      expect(config.experimentalRules.length, equals(1));
    });

    test('fromJson should handle complete config', () {
      final map =
          yamlToDartMap(loadYaml(completeConfig)) as Map<String, dynamic>;
      final config = ShieldConfig.fromYaml(map);

      expect(config.rules.length, equals(1));
      expect(config.rules.first, isA<LintRule>());
      expect(config.enableExperimental, equals(true));
      expect(config.experimentalRules.length, equals(1));
      expect(config.exclude.length, equals(1));
    });
  });

  group('$ShieldConfig - invalid configuration', () {
    test('fromJson should throw an exception for invalid config', () {
      final map =
          yamlToDartMap(loadYaml(invalidConfig)) as Map<String, dynamic>;
      expect(
        () => ShieldConfig.fromYaml(map),
        throwsA(isA<ConfigValidationException>()),
      );
    });
  });
}
