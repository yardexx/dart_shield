import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:dart_shield/src/security_analyzer/configuration/shield_config.dart';
import 'package:dart_shield/src/security_analyzer/extensions.dart';
import 'package:dart_shield/src/security_analyzer/report/report.dart';
import 'package:dart_shield/src/security_analyzer/utils/suppression.dart';
import 'package:dart_shield/src/security_analyzer/workspace.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';

class _AnalysisContextResult {
  _AnalysisContextResult(this.reports, this.skippedFiles);

  final List<FileReport> reports;
  final List<String> skippedFiles;
}

class SecurityAnalyzer {
  Future<ProjectReport> analyzeFromCli(
    Workspace workspace,
    ShieldConfig config,
  ) async {
    final projectReport = ProjectReport.empty(workspace.rootFolder);
    final collection = _createCollection(workspace);
    final allSkippedFiles = <String>[];

    for (final context in collection.contexts) {
      final result = await _analyzeContext(workspace, context, config);
      projectReport.addLintReports(result.reports);
      allSkippedFiles.addAll(result.skippedFiles);
    }

    // Store skipped files in the project report for logging
    projectReport.skippedFiles = allSkippedFiles;

    return projectReport;
  }

  Future<_AnalysisContextResult> _analyzeContext(
    Workspace workspace,
    AnalysisContext context,
    ShieldConfig config,
  ) async {
    final dartFiles = _parseDartFiles(workspace, config);
    final analyzerResults = <FileReport>[];
    final skippedFiles = <String>[];

    for (final file in dartFiles) {
      final result = await context.currentSession.tryGetResolvedUnit(file);
      if (result != null) {
        final fileReport = _analyzeUnit(workspace, result, config);
        analyzerResults.add(fileReport);
      } else {
        skippedFiles.add(file);
      }
    }

    return _AnalysisContextResult(analyzerResults, skippedFiles);
  }

  FileReport _analyzeUnit(
    Workspace workspace,
    ResolvedUnitResult result,
    ShieldConfig config,
  ) {
    final relativePath = relative(result.path, from: workspace.rootFolder);
    final suppression = Suppression(result.content, result.lineInfo);

    // Filter rules by file-level suppression
    final applicableRules = config.allRules.where(
      (rule) => !suppression.isSuppressed(rule.id.toUnderscoreCase()),
    );

    // Check rules and filter issues by line-level suppression
    final issues = applicableRules
        .expand((rule) => rule.check(result))
        .where(
          (issue) => !suppression.isSuppressedAt(
            issue.ruleId,
            issue.location.start.line,
          ),
        )
        .toList();

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
