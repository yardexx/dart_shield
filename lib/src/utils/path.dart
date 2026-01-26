import 'dart:io';

import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

String normalize(String p, String rootFolder) {
  final absolutePath = path.isAbsolute(p) ? p : path.join(rootFolder, p);
  return path.normalize(absolutePath);
}

List<String> findDartFiles(String rootFolder) {
  final dartGlob = Glob('**.dart');

  final dir = Directory(rootFolder);
  if (!dir.existsSync()) return [];

  final files = <String>[];
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final relative = path.relative(entity.path, from: rootFolder);
      if (dartGlob.matches(relative)) files.add(entity.path);
    }
  }
  return files;
}
