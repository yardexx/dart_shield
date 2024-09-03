import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart';
import 'package:source_span/source_span.dart';

extension GlobX on Glob {
  Iterable<String> normalizePaths(String path) =>
      listSync(root: path, followLinks: false)
          .whereType<File>()
          .map((file) => normalize(file.path));
}

extension AnalysisSessionX on AnalysisSession {
  Future<ResolvedUnitResult?> tryGetResolvedUnit(String path) async {
    final result = await getResolvedUnit(path);
    if (result is ResolvedUnitResult) {
      return result;
    }

    return null;
  }
}

extension SourceSpanX on SourceSpan {
  static SourceSpan fromNode({
    required SyntacticEntity node,
    required ResolvedUnitResult source,
    SyntacticEntity? endNode,
    bool withCommentOrMetadata = false,
  }) {
    final offset = !withCommentOrMetadata && node is AnnotatedNode
        ? node.firstTokenAfterCommentAndMetadata.offset
        : node.offset;
    final end = endNode?.end ?? node.end;
    final sourceUrl = Uri.file(source.path);

    final offsetLocation = source.lineInfo.getLocation(offset);
    final endLocation = source.lineInfo.getLocation(end);

    return SourceSpan(
      SourceLocation(
        offset,
        sourceUrl: sourceUrl,
        line: offsetLocation.lineNumber,
        column: offsetLocation.columnNumber,
      ),
      SourceLocation(
        end,
        sourceUrl: sourceUrl,
        line: endLocation.lineNumber,
        column: endLocation.columnNumber,
      ),
      source.content.substring(offset, end),
    );
  }

  Map<String, Object?> toJson() => {
        'startLine': start.line,
        'startColumn': start.column,
        'endLine': end.line,
        'endColumn': end.column,
      };

  String get string => 'Line ${start.line}, Column ${start.column}';
}

String _parsePackageName(String identifier) {
  // Matches: package:[somePackage]/[packagePath].dart or dart:[some_package]
  // Returns: package:[somePackage] or dart:[some_package]
  // ignore: unnecessary_raw_strings
  final regex = RegExp(r'^(package:[^/]+|dart:[^/]+)');
  return regex.firstMatch(identifier)?.group(0) ?? '';
}

extension ExpressionX on Expression {
  bool belongsToPackage(String packageName) {
    final identifier = staticType?.element?.library?.identifier ?? '';
    final nodePackageName = _parsePackageName(identifier);
    return nodePackageName == packageName;
  }
}
