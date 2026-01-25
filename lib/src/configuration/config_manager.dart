import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class ConfigManager {
  ConfigManager({String path = 'analysis_options.yaml'}) : _file = File(path);
  final File _file;

  bool get exists => _file.existsSync();

  Future<void> applyShieldConfig({bool force = false}) async {
    if (!exists) {
      throw FileSystemException('Configuration file not found.', _file.path);
    }

    final content = await _file.readAsString();

    if (content.trim().isEmpty) {
      await _file.writeAsString(_initialContent);
      return;
    }

    final editor = YamlEditor(content);
    final yaml = loadYaml(content);

    _addPlugin(editor, yaml);
    _addConfigSection(editor, yaml, force: force);

    await _file.writeAsString(editor.toString());
  }

  void _addPlugin(YamlEditor editor, dynamic yaml) {
    const pluginName = 'dart_shield';

    if (yaml == null || (yaml is Map && yaml.isEmpty)) {
      editor.update(['plugins'], [pluginName]);
      return;
    }

    final plugins = yaml is Map ? yaml['plugins'] : null;

    if (plugins == null) {
      editor.update(['plugins'], [pluginName]);
    } else if (plugins is List) {
      if (!plugins.contains(pluginName)) {
        editor.appendToList(['plugins'], pluginName);
      }
    }
  }

  void _addConfigSection(
    YamlEditor editor,
    dynamic yaml, {
    required bool force,
  }) {
    const configKey = 'dart_shield';
    final hasConfig = yaml is Map && yaml.containsKey(configKey);

    if (!hasConfig || force) {
      editor.update([configKey], _defaultShieldConfig);
    }
  }

  // --- TEMPLATES ---

  // Used if file was empty
  static const String _initialContent = '''
include: package:lints/recommended.yaml

plugins:
  - dart_shield

dart_shield:
  analyzers:
    code: true
    deps: true
''';

  static const Map<String, dynamic> _defaultShieldConfig = {
    'analyzers': {'code': true, 'deps': true},
  };
}
