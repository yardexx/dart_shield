// ignore_for_file: omit_local_variable_types

// yaml package doesn't provide a way to deserialize yaml file into map.
// Issue is already opened. Kudos to @clragon for this code snippet.
// GitHub issue url: https://github.com/dart-lang/yaml/issues/147#issuecomment-1836666943
dynamic yamlToDartMap(dynamic value) {
  if (value is Map) {
    final List<MapEntry<String, dynamic>> entries = [];
    // We cannot directly use `entries` because `YamlMap` will return Nodes
    // instead of values.
    for (final key in value.keys) {
      entries.add(MapEntry(key as String, yamlToDartMap(value[key])));
    }
    return Map.fromEntries(entries);
  } else if (value is List) {
    return List<dynamic>.from(value.map(yamlToDartMap));
  } else {
    return value;
  }
}
