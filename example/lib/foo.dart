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

void handleWebRequest(String userInput) {
  // Source: user input from web request
  String data = userInput;

  // Propagation: string manipulation
  String filename = '/tmp/' + data + '.txt';
  String command = 'cat ' + filename;

  // Sinks: vulnerable operations
  File(filename).writeAsString('content'); // Path traversal
  Process.run('sh', ['-c', command]); // Command injection

  // Sanitized version
  String sanitizedData = sanitize(data);
  String safeFilename = '/tmp/' + sanitizedData + '.txt';
  File(safeFilename).writeAsString('content');
}

String sanitize(String input) {
  return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
}
