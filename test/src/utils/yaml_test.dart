import 'package:dart_shield/src/utils/utils.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import '../../data/yaml_inputs.dart';

void main() {
  group('yamlToDartMap', () {
    test('converts a simple map', () {
      final input = loadYaml(yamlSimpleMap);
      expect(input, isA<YamlMap>());

      final output = yamlToDartMap(input);
      expect(output, equals({'key1': 'value1', 'key2': 'value2'}));
    });

    test('converts a nested map', () {
      final input = loadYaml(yamlNestedMap);
      expect(input, isA<YamlMap>());

      final output = yamlToDartMap(input);
      expect(
        output,
        equals({
          'key1': 'value1',
          'key2': {'nestedKey1': 'nestedValue1', 'nestedKey2': 'nestedValue2'},
        }),
      );
    });

    test('converts a simple list', () {
      final input = loadYaml(yamlSimpleList);
      expect(input, isA<YamlList>());

      final output = yamlToDartMap(input);
      expect(output, equals(['value1', 'value2', 'value3']));
    });

    test('converts a list of maps', () {
      final input = loadYaml(yamlListOfMaps);
      expect(input, isA<YamlList>());

      final output = yamlToDartMap(input);
      expect(
        output,
        equals([
          {'key1': 'value1'},
          {'key2': 'value2'},
        ]),
      );
    });

    test('converts a map with a list', () {
      final input = loadYaml(yamlMapWithList);
      expect(input, isA<YamlMap>());

      final output = yamlToDartMap(input);
      expect(
        output,
        equals({
          'key1': 'value1',
          'key2': ['listValue1', 'listValue2'],
        }),
      );
    });

    test('converts a nested list of maps', () {
      final input = loadYaml(yamlNestedListOfMaps);
      expect(input, isA<YamlList>());

      final output = yamlToDartMap(input);
      expect(
        output,
        equals([
          {'key1': 'value1'},
          [
            {'key2': 'value2'},
          ]
        ]),
      );
    });

    test('converts an empty map', () {
      final input = loadYaml(yamlEmptyMap);
      expect(input, isNull);

      final output = yamlToDartMap(input);
      expect(output, isNull);
    });

    test('converts an empty list', () {
      final input = loadYaml(yamlEmptyList);
      expect(input, isA<YamlList>());

      final output = yamlToDartMap(input);
      expect(output, equals([]));
    });

    test('returns primitive values as-is', () {
      expect(yamlToDartMap(123), equals(123));
      expect(yamlToDartMap('string'), equals('string'));
      expect(yamlToDartMap(true), isTrue);
      expect(yamlToDartMap(null), isNull);
    });
  });
}
