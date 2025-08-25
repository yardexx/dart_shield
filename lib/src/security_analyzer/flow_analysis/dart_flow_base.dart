import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_builder.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_extractor.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/control_flow_graph.dart';

/// Main API for the CFG library
class DartCFGAnalyzer {

  DartCFGAnalyzer._(this._collection);
  final AnalysisContextCollection _collection;

  static DartCFGAnalyzer forAnalysisContext(AnalysisContextCollection context) {
    return DartCFGAnalyzer._(context);
  }

  /// Create analyzer for a directory of Dart files
  static DartCFGAnalyzer forDirectory(String path) {
    final collection = AnalysisContextCollection(
      includedPaths: [path],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    return DartCFGAnalyzer._(collection);
  }

  /// Analyze a single Dart file and return CFGs for all functions
  Future<Map<String, ControlFlowGraph>> analyzeFile(String filePath) async {
    final context = _collection.contextFor(filePath);
    final result = await context.currentSession.getResolvedUnit(filePath);

    if (result is! ResolvedUnitResult) {
      throw Exception('Failed to parse file: $filePath');
    }

    final cfgs = <String, ControlFlowGraph>{};
    final builder = CFGBuilder();

    // Find all functions, methods, and constructors
    result.unit.accept(CFGExtractor(builder, cfgs));

    return cfgs;
  }

  /// Analyze all Dart files in the configured directory
  Future<Map<String, Map<String, ControlFlowGraph>>> analyzeAllFiles() async {
    final allResults = <String, Map<String, ControlFlowGraph>>{};

    for (final context in _collection.contexts) {
      final files = context.contextRoot.analyzedFiles()
          .where((file) => file.endsWith('.dart'))
          .toList();

      for (final file in files) {
        try {
          final cfgs = await analyzeFile(file);
          if (cfgs.isNotEmpty) {
            allResults[file] = cfgs;
          }
        } catch (e) {
          // Skip files that can't be analyzed
        }
      }
    }

    return allResults;
  }
}
