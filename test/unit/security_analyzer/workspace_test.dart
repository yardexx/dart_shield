import 'dart:io';

import 'package:dart_shield/src/security_analyzer/workspace.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('Workspace', () {
    late Directory tempDir;
    late String tempPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('dart_shield_test_');
      tempPath = tempDir.path;
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    group('constructor', () {
      test('creates workspace with analyzed paths and root folder', () {
        final workspace = Workspace(
          analyzedPaths: ['lib', 'test'],
          rootFolder: tempPath,
        );

        expect(workspace.analyzedPaths, equals(['lib', 'test']));
        expect(workspace.rootFolder, equals(tempPath));
        expect(workspace.configPath, equals(path.join(tempPath, 'shield_options.yaml')));
      });

      test('creates workspace with empty analyzed paths', () {
        final workspace = Workspace(
          analyzedPaths: [],
          rootFolder: tempPath,
        );

        expect(workspace.analyzedPaths, isEmpty);
        expect(workspace.rootFolder, equals(tempPath));
      });

      test('creates workspace with single analyzed path', () {
        final workspace = Workspace(
          analyzedPaths: ['lib'],
          rootFolder: tempPath,
        );

        expect(workspace.analyzedPaths, equals(['lib']));
        expect(workspace.rootFolder, equals(tempPath));
      });
    });

    group('normalizedFolders', () {
      test('normalizes analyzed paths relative to root folder', () {
        final workspace = Workspace(
          analyzedPaths: ['lib', 'test', 'example'],
          rootFolder: tempPath,
        );

        final normalizedFolders = workspace.normalizedFolders;
        
        expect(normalizedFolders.length, equals(3));
        expect(normalizedFolders, contains(path.join(tempPath, 'lib')));
        expect(normalizedFolders, contains(path.join(tempPath, 'test')));
        expect(normalizedFolders, contains(path.join(tempPath, 'example')));
      });

      test('handles absolute paths in analyzed paths', () {
        final absolutePath = path.join(tempPath, 'absolute');
        final workspace = Workspace(
          analyzedPaths: [absolutePath, 'relative'],
          rootFolder: tempPath,
        );

        final normalizedFolders = workspace.normalizedFolders;
        
        expect(normalizedFolders.length, equals(2));
        expect(normalizedFolders, contains(absolutePath));
        expect(normalizedFolders, contains(path.join(tempPath, 'relative')));
      });

      test('handles empty analyzed paths', () {
        final workspace = Workspace(
          analyzedPaths: [],
          rootFolder: tempPath,
        );

        final normalizedFolders = workspace.normalizedFolders;
        
        expect(normalizedFolders, isEmpty);
      });

      test('handles current directory path', () {
        final workspace = Workspace(
          analyzedPaths: ['.'],
          rootFolder: tempPath,
        );

        final normalizedFolders = workspace.normalizedFolders;
        
        expect(normalizedFolders.length, equals(1));
        expect(normalizedFolders.first, equals(tempPath));
      });
    });

    group('configExists', () {
      test('returns false when config file does not exist', () {
        final workspace = Workspace(
          analyzedPaths: [],
          rootFolder: tempPath,
        );

        expect(workspace.configExists, isFalse);
      });

      test('returns true when config file exists', () {
        final workspace = Workspace(
          analyzedPaths: [],
          rootFolder: tempPath,
        );

        // Create the config file
        File(workspace.configPath).createSync();

        expect(workspace.configExists, isTrue);
      });

      test('returns false when config path is a directory', () {
        final workspace = Workspace(
          analyzedPaths: [],
          rootFolder: tempPath,
        );

        // Create a directory with the config name
        Directory(workspace.configPath).createSync();

        expect(workspace.configExists, isFalse);
      });
    });

    group('createDefaultConfig', () {
      test('creates default config file', () {
        final workspace = Workspace(
          analyzedPaths: [],
          rootFolder: tempPath,
        );

        expect(workspace.configExists, isFalse);

        workspace.createDefaultConfig();

        expect(workspace.configExists, isTrue);
        
        final configFile = File(workspace.configPath);
        expect(configFile.existsSync(), isTrue);
        
        final content = configFile.readAsStringSync();
        expect(content, contains('shield:'));
        expect(content, contains('rules:'));
        expect(content, contains('prefer-https-over-http'));
      });

      test('overwrites existing config file', () {
        final workspace = Workspace(
          analyzedPaths: [],
          rootFolder: tempPath,
        );

        // Create initial config file
        File(workspace.configPath).writeAsStringSync('initial content');
        expect(workspace.configExists, isTrue);

        workspace.createDefaultConfig();

        expect(workspace.configExists, isTrue);
        
        final content = File(workspace.configPath).readAsStringSync();
        expect(content, isNot(equals('initial content')));
        expect(content, contains('shield:'));
      });

      test('creates config file with correct permissions', () {
        final workspace = Workspace(
          analyzedPaths: [],
          rootFolder: tempPath,
        );

        workspace.createDefaultConfig();

        final configFile = File(workspace.configPath);
        expect(configFile.existsSync(), isTrue);
        
        // File should be readable
        expect(() => configFile.readAsStringSync(), returnsNormally);
      });
    });

    group('configPath', () {
      test('config path is correct', () {
        final workspace = Workspace(
          analyzedPaths: [],
          rootFolder: tempPath,
        );

        expect(workspace.configPath, equals(path.join(tempPath, 'shield_options.yaml')));
      });

      test('config path uses correct filename', () {
        final workspace = Workspace(
          analyzedPaths: [],
          rootFolder: tempPath,
        );

        expect(path.basename(workspace.configPath), equals('shield_options.yaml'));
      });

      test('config path is absolute', () {
        final workspace = Workspace(
          analyzedPaths: [],
          rootFolder: tempPath,
        );

        expect(path.isAbsolute(workspace.configPath), isTrue);
      });
    });

    group('edge cases', () {
      test('handles root folder with trailing slash', () {
        final rootWithSlash = '$tempPath/';
        final workspace = Workspace(
          analyzedPaths: ['lib'],
          rootFolder: rootWithSlash,
        );

        expect(workspace.rootFolder, equals(rootWithSlash));
        expect(workspace.configPath, equals(path.join(rootWithSlash, 'shield_options.yaml')));
      });

      test('handles analyzed paths with trailing slashes', () {
        final workspace = Workspace(
          analyzedPaths: ['lib/', 'test/'],
          rootFolder: tempPath,
        );

        final normalizedFolders = workspace.normalizedFolders;
        
        expect(normalizedFolders.length, equals(2));
        expect(normalizedFolders, contains(path.join(tempPath, 'lib')));
        expect(normalizedFolders, contains(path.join(tempPath, 'test')));
      });

      test('handles analyzed paths with parent directory references', () {
        final workspace = Workspace(
          analyzedPaths: ['../parent', './current'],
          rootFolder: tempPath,
        );

        final normalizedFolders = workspace.normalizedFolders;
        
        expect(normalizedFolders.length, equals(2));
        expect(normalizedFolders, contains(path.join(path.dirname(tempPath), 'parent')));
        expect(normalizedFolders, contains(path.join(tempPath, 'current')));
      });
    });
  });
}
