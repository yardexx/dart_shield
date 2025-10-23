import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:path/path.dart' as path;

/// Helper class for creating test analyzers and managing test files
class TestAnalyzer {
  /// Creates a temporary directory for test files
  static Directory createTempDir() {
    return Directory.systemTemp.createTempSync('dart_shield_test_');
  }

  /// Creates a temporary Dart file with the given content
  static File createTempDartFile(
    Directory tempDir,
    String filename,
    String content,
  ) {
    final file = File(path.join(tempDir.path, filename))
      ..writeAsStringSync(content);
    return file;
  }

  /// Analyzes Dart code and returns a ResolvedUnitResult
  static Future<ResolvedUnitResult> analyzeCode(
    String code, {
    String filename = 'test.dart',
  }) async {
    final tempDir = createTempDir();
    try {
      final tempFile = createTempDartFile(tempDir, filename, code);

      // Create analysis context
      final collection = AnalysisContextCollection(
        includedPaths: [tempDir.path],
      );
      final context = collection.contexts.first;

      // Get resolved unit
      final result = await context.currentSession.getResolvedUnit(
        tempFile.path,
      );

      if (result is ResolvedUnitResult) {
        return result;
      } else {
        throw Exception('Failed to resolve unit: $result');
      }
    } finally {
      // Clean up temporary directory
      tempDir.deleteSync(recursive: true);
    }
  }

  /// Analyzes multiple Dart files in a temporary directory
  static Future<List<ResolvedUnitResult>> analyzeMultipleFiles(
    Map<String, String> files,
  ) async {
    final tempDir = createTempDir();
    try {
      // Create all files
      for (final entry in files.entries) {
        createTempDartFile(tempDir, entry.key, entry.value);
      }

      // Create analysis context
      final collection = AnalysisContextCollection(
        includedPaths: [tempDir.path],
      );
      final context = collection.contexts.first;

      // Analyze all files
      final results = <ResolvedUnitResult>[];
      for (final entry in files.entries) {
        final filePath = path.join(tempDir.path, entry.key);
        final result = await context.currentSession.getResolvedUnit(filePath);

        if (result is ResolvedUnitResult) {
          results.add(result);
        }
      }

      return results;
    } finally {
      // Clean up temporary directory
      tempDir.deleteSync(recursive: true);
    }
  }

  /// Creates a test workspace with sample files
  static Directory createTestWorkspace({
    Map<String, String> dartFiles = const {},
    String? configContent,
  }) {
    final tempDir = createTempDir();

    // Create Dart files
    for (final entry in dartFiles.entries) {
      createTempDartFile(tempDir, entry.key, entry.value);
    }

    // Create config file if provided
    if (configContent != null) {
      File(
        path.join(tempDir.path, 'shield_options.yaml'),
      ).writeAsStringSync(configContent);
    }

    return tempDir;
  }

  /// Cleans up a temporary directory
  static void cleanupTempDir(Directory tempDir) {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }
}

/// Mock workspace for testing
class MockWorkspace {
  MockWorkspace({
    required this.rootFolder,
    required this.analyzedPaths,
    this.files = const {},
    this.configContent,
  });

  final String rootFolder;
  final List<String> analyzedPaths;
  final Map<String, String> files;
  final String? configContent;

  String get configPath => path.join(rootFolder, 'shield_options.yaml');

  List<String> get normalizedFolders => analyzedPaths
      .map(
        (analyzedPath) => analyzedPath.startsWith('/')
            ? analyzedPath
            : path.join(rootFolder, analyzedPath),
      )
      .toList();

  bool get configExists => configContent != null;

  void createDefaultConfig() {
    if (configContent != null) {
      File(configPath).writeAsStringSync(configContent!);
    }
  }
}

/// Test data builder for creating test scenarios
class TestDataBuilder {
  static const String vulnerableCode = '''
import 'dart:math';

void main() {
  // Hardcoded secrets
  const apiKey = 'sk-1234567890abcdef';
  const secret = 'my-secret-key';
  
  // HTTP URLs
  const url = 'http://example.com/api';
  
  // Weak random
  final random = Random();
  
  // Hardcoded URLs
  const endpoint = 'https://api.example.com/v1/users';
}
''';

  static const String secureCode = '''
import 'dart:math';

void main() {
  // Secure random
  final random = Random.secure();
  
  // HTTPS URLs
  const url = 'https://example.com/api';
  
  // Environment variables
  final apiKey = Platform.environment['API_KEY'];
}
''';

  static const String mixedCode = '''
import 'dart:math';

void main() {
  // Mix of secure and insecure code
  const apiKey = 'sk-1234567890abcdef'; // Insecure
  final random = Random.secure(); // Secure
  
  const httpUrl = 'http://example.com'; // Insecure
  const httpsUrl = 'https://secure.example.com'; // Secure
}
''';

  static const String minimalConfig = '''
shield:
  rules:
    - prefer-https-over-http
''';

  static const String completeConfig = '''
shield:
  rules:
    - prefer_https_over_http
    - avoid_hardcoded_secrets
  experimental_rules:
    - avoid_hardcoded_urls
    - avoid_weak_hashing
  enable_experimental: true
  exclude:
    - 'test/**'
    - '**/*.g.dart'
''';

  static const String invalidConfig = '''
shield:
  rules:
    - invalid-rule
  experimental_rules:
    - another-invalid-rule
''';
}
