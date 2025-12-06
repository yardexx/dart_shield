/// Root object representing the result of `dart analyze --format=json`
class AnalyzeResult {
  AnalyzeResult({
    required this.version,
    required this.diagnostics,
  });

  factory AnalyzeResult.fromJson(Map<String, dynamic> json) {
    return AnalyzeResult(
      version: json['version'] as int,
      diagnostics: (json['diagnostics'] as List<dynamic>)
          .map((e) => Diagnostic.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int version;
  final List<Diagnostic> diagnostics;
}

class Diagnostic {
  Diagnostic({
    required this.code,
    required this.severity,
    required this.type,
    required this.problemMessage,
    this.location,
    this.correctionMessage,
    this.documentation,
  });

  factory Diagnostic.fromJson(Map<String, dynamic> json) {
    return Diagnostic(
      code: json['code'] as String,
      severity: json['severity'] as String,
      type: json['type'] as String,
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      problemMessage: json['problemMessage'] as String,
      correctionMessage: json['correctionMessage'] as String?,
      documentation: json['documentation'] as String?,
    );
  }

  final String code;
  final String severity;
  final String type;
  final Location? location;
  final String problemMessage;
  final String? correctionMessage;
  final String? documentation;
}

class Location {
  Location({
    required this.file,
    required this.range,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      file: json['file'] as String,
      range: SourceRange.fromJson(json['range'] as Map<String, dynamic>),
    );
  }

  final String file;
  final SourceRange range;
}

class SourceRange {
  SourceRange({
    required this.start,
    required this.end,
  });

  factory SourceRange.fromJson(Map<String, dynamic> json) {
    return SourceRange(
      start: SourcePosition.fromJson(json['start'] as Map<String, dynamic>),
      end: SourcePosition.fromJson(json['end'] as Map<String, dynamic>),
    );
  }

  final SourcePosition start;
  final SourcePosition end;
}

class SourcePosition {
  SourcePosition({
    required this.offset,
    required this.line,
    required this.column,
  });

  factory SourcePosition.fromJson(Map<String, dynamic> json) {
    return SourcePosition(
      offset: json['offset'] as int,
      line: json['line'] as int,
      column: json['column'] as int,
    );
  }

  final int offset;
  final int line;
  final int column;
}
