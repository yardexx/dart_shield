import 'package:analyzer/source/line_info.dart';

/// Represents an information about rule suppression for dart_shield.
class Suppression {
  /// Initialize a newly created [Suppression] with the given [content]
  /// and [lineInfo].
  Suppression(String content, this.lineInfo) {
    _parseIgnoreComments(content);
    _parseIgnoreForFileComments(content);
  }
  static final _ignoreMatchers = RegExp(
    '//[ ]*shield_ignore:(.*)',
    multiLine: true,
  );
  static final _ignoreForFileMatcher = RegExp(
    '//[ ]*shield_ignore_for_file:(.*)',
    multiLine: true,
  );

  final _ignoreMap = <int, List<String>>{};
  final _ignoreForFileSet = <String>{};

  final LineInfo lineInfo;

  /// Checks that the [id] is globally suppressed for the entire file.
  bool isSuppressed(String id) => _ignoreForFileSet.contains(_canonicalize(id));

  /// Checks that the [id] is suppressed for the [lineIndex].
  bool isSuppressedAt(String id, int lineIndex) =>
      isSuppressed(id) ||
      (_ignoreMap[lineIndex]?.contains(_canonicalize(id)) ?? false);

  void _parseIgnoreComments(String content) {
    for (final match in _ignoreMatchers.allMatches(content)) {
      final ids = match.group(1)!.split(',').map(_canonicalize);
      final location = lineInfo.getLocation(match.start);
      final lineNumber = location.lineNumber;
      final offset = lineInfo.getOffsetOfLine(lineNumber - 1);
      final beforeMatch = content.substring(
        offset,
        offset + location.columnNumber - 1,
      );

      // If comment sits next to code, it refers to its own line, otherwise it
      // refers to the next line.
      final ignoredNextLine = beforeMatch.trim().isEmpty;
      _ignoreMap
          .putIfAbsent(
            ignoredNextLine ? lineNumber + 1 : lineNumber,
            () => <String>[],
          )
          .addAll(ids);
    }
  }

  void _parseIgnoreForFileComments(String content) {
    for (final match in _ignoreForFileMatcher.allMatches(content)) {
      final suppressed = match.group(1)!.split(',').map(_canonicalize);
      _ignoreForFileSet.addAll(suppressed);
    }
  }

  /// Canonicalizes rule IDs by trimming whitespace and converting to lowercase.
  String _canonicalize(String ruleId) {
    return ruleId.trim().toLowerCase();
  }
}
