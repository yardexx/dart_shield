sealed class IssueContext {
  Map<String, dynamic> toJson();
}

class FileContext extends IssueContext {
  FileContext({
    required this.filePath,
    required this.line,
    required this.column,
  });

  final String filePath;
  final int line;
  final int column;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file',
    'filePath': filePath,
    'line': line,
    'column': column,
  };
}
