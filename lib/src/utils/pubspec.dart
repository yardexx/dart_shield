import 'dart:io';

class Pubspec {
  static String version() {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = pubspec.split('version: ')[1].split('\n')[0].trim();
    return version;
  }
}
