import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:dart_shield/src/security_analyzer/configuration/shield_config.dart';
import 'package:dart_shield/src/security_analyzer/extensions.dart';
import 'package:dart_shield/src/security_analyzer/report/report.dart';
import 'package:dart_shield/src/security_analyzer/workspace.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';

class SecurityAnalyzer {
  Future<ProjectReport> analyzeFromCli(
    Workspace workspace,
    ShieldConfig config,
  ) async {
    final projectReport = ProjectReport.empty(workspace.rootFolder);
    final collection = _createCollection(workspace);

    for (final context in collection.contexts) {
      final report = await _analyzeContext(workspace, context, config);
      projectReport.addLintReports(report);
    }

    return projectReport;
  }

  Future<List<FileReport>> _analyzeContext(
    Workspace workspace,
    AnalysisContext context,
    ShieldConfig config,
  ) async {
    final dartFiles = _parseDartFiles(workspace, config);
    final analyzerResults = <FileReport>[];

    for (final file in dartFiles) {
      final result = await context.currentSession.tryGetResolvedUnit(file);
      if (result != null) {
        final fileReport = _analyzeUnit(workspace, result, config);
        analyzerResults.add(fileReport);
      }
    }
    return analyzerResults;
  }

  FileReport _analyzeUnit(
    Workspace workspace,
    ResolvedUnitResult result,
    ShieldConfig config,
  ) {
    final relativePath = relative(result.path, from: workspace.rootFolder);
    // TODO: Should be able to skip experimental rules
    final issues =
        config.allRules.expand((rule) => rule.check(result)).toList();
    return FileReport.fromIssues(relativePath, issues);
  }

  AnalysisContextCollection _createCollection(Workspace workspace) {
    return AnalysisContextCollection(
      includedPaths: workspace.normalizedFolders,
    );
  }

  Set<String> _parseDartFiles(Workspace workspace, ShieldConfig config) {
    final dartGlob = Glob('**.dart');
    final excludePatterns = config.exclude.map(Glob.new);

    return workspace.normalizedFolders
        .expand(dartGlob.normalizePaths)
        .where((path) => excludePatterns.every((glob) => !glob.matches(path)))
        .toSet();
  }
}
