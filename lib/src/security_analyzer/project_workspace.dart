import 'dart:io';

import 'package:path/path.dart';

class Workspace {
  Workspace({
    required this.analyzedPaths,
    required this.rootFolder,
  }) : configPath = join(rootFolder, _configFileName);

  final List<String> analyzedPaths;
  final String rootFolder;
  final String configPath;

  static const _configFileName = 'shield_options.yaml';

  List<String> get normalizedFolders =>
      analyzedPaths.map((path) => normalize(join(rootFolder, path))).toList();

  bool get configExists => File(configPath).existsSync();

  void createDefaultConfig() {
    File(configPath)
      ..createSync()
      ..writeAsStringSync(_defaultConfig);
  }
}

const _defaultConfig = '''
# dart_shield configuration file
# This file is used to configure analyser behavior.
# For more information, see [link]
shield:
  rules:
    - prefer-https-over-http
''';
