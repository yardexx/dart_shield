// example/flow_analysis_example.dart
import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/flow_analysis.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/visualization/cfg_visualizer.dart';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:dart_shield/src/security_analyzer/configuration/shield_config.dart';
import 'package:dart_shield/src/security_analyzer/extensions.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/flow_analysis.dart';
import 'package:dart_shield/src/security_analyzer/report/report.dart';
import 'package:dart_shield/src/security_analyzer/workspace.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';

void main() async {
  // Example 1: Basic CFG construction and visualization
  await demonstrateCFGConstruction();

  // Example 2: Taint analysis on vulnerable code
  await demonstrateTaintAnalysis();

  // Example 3: Integrating with existing SAST tool
  await demonstrateIntegration();
}

Future<void> demonstrateCFGConstruction() async {
  print('=== CFG Construction Example ===');

  const vulnerableCode = '''
void processUserInput(String input) {
  if (input.isEmpty) {
    print('Empty input');
    return;
  }
  
  String query = "SELECT * FROM users WHERE name = '" + input + "'";
  
  try {
    var result = database.execute(query);
    print('Result: \$result');
  } catch (e) {
    print('Error: \$e');
  }
}
''';

  // Create a temporary file
  final tempFile = File('/Users/yardex/StudioProjects/dart_shield/example/lib/temp_example.dart')..createSync();
  await tempFile.writeAsString(vulnerableCode);

  try {
    // Analyze the code
    final collection = AnalysisContextCollection(
      includedPaths: [tempFile.path],
    );

    final context = collection.contexts.first;
    final result = await context.currentSession.getResolvedUnit(tempFile.path);

    if (result is ResolvedUnitResult) {
      final engine = FlowAnalysisEngine();
      final analysisResult = engine.analyzeUnit(result);

      // Print CFG information
      for (final funcResult in analysisResult.functionResults.values) {
        print('Function: ${funcResult.functionName}');
        print('CFG Nodes: ${funcResult.cfg.nodes.length}');
        print('Entry Node: ${funcResult.cfg.entryNode}');
        print('Exit Node: ${funcResult.cfg.exitNode}');

        // Generate visualization
        final htmlViz = CFGVisualizer.generateHtmlVisualization(funcResult.cfg);
        File('/Users/yardex/StudioProjects/dart_shield/example/lib/cfg_${funcResult.functionName}.html')
            ..createSync()
            ..writeAsStringSync(htmlViz);
        print('CFG visualization saved to cfg_${funcResult.functionName}.html');

        // Print vulnerabilities found
        if (funcResult.taintVulnerabilities.isNotEmpty) {
          print('Vulnerabilities found:');
          for (final vuln in funcResult.taintVulnerabilities) {
            print('  - $vuln');
          }
        }

        print('---');
      }
    }
  } finally {
    // Clean up
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  }
}

Future<void> demonstrateTaintAnalysis() async {
  print('\n=== Taint Analysis Example ===');

  const vulnerableCode = '''
import 'dart:io';

void handleWebRequest(String userInput) {
  // Source: user input from web request
  String data = userInput;
  
  // Propagation: string manipulation
  String filename = '/tmp/' + data + '.txt';
  String command = 'cat ' + filename;
  
  // Sinks: vulnerable operations
  File(filename).writeAsString('content');  // Path traversal
  Process.run('sh', ['-c', command]);       // Command injection
  
  // Sanitized version
  String sanitizedData = sanitize(data);
  String safeFilename = '/tmp/' + sanitizedData + '.txt';
  File(safeFilename).writeAsString('content');
}

String sanitize(String input) {
  return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
}
''';

  final tempFile = File('/Users/yardex/StudioProjects/dart_shield/example/lib/temp_taint_example.dart')..createSync();
  await tempFile.writeAsString(vulnerableCode);

  try {
    final collection = AnalysisContextCollection(
      includedPaths: [tempFile.path],
    );

    final context = collection.contexts.first;
    final result = await context.currentSession.getResolvedUnit(tempFile.path);

    if (result is ResolvedUnitResult) {
      final engine = FlowAnalysisEngine();
      final analysisResult = engine.analyzeUnit(result);

      print(
          'Total vulnerabilities found: ${analysisResult.allVulnerabilities.length}');

      for (final vulnerability in analysisResult.allVulnerabilities) {
        print('Vulnerability Details:');
        print('  Source: ${vulnerability.source}');
        print('  Sink: ${vulnerability.sink}');
        print('  Tainted Argument: ${vulnerability.taintedArgument}');
        print(
            '  Location: ${vulnerability.location.toString().substring(0, 50)}...');
        print('---');
      }
    }
  } finally {
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  }
}

Future<void> demonstrateIntegration() async {
  print('\n=== Integration with Existing SAST Tool ===');

  // Example of how to integrate flow analysis with your existing rules
  const configWithFlowRules = '''
shield:
  rules:
    - prefer-https-over-http
    - avoid-hardcoded-secrets
  
  enable-experimental: true
  experimental-rules:
    - detect-sql-injection  
    - detect-command-injection
    - avoid-hardcoded-urls
    - avoid-weak-hashing
    - prefer-secure-random
''';

  final configFile = File('/Users/yardex/StudioProjects/dart_shield/example/lib/temp_shield_options.yaml')..createSync();
  await configFile.writeAsString(configWithFlowRules);

  print('Enhanced configuration with flow-based rules:');
  print(configWithFlowRules);

  print('\nFlow-based rules add these capabilities:');
  print('1. avoid-taint-flow: General taint flow detection');
  print('2. detect-sql-injection: SQL injection via taint analysis');
  print('3. detect-command-injection: Command injection via taint analysis');

  await configFile.delete();
}
