// Test fixtures for vulnerable Dart code
const String vulnerableCode = '''
import 'dart:math';

void main() {
  // Hardcoded secrets
  const apiKey = 'sk-1234567890abcdef';
  const secret = 'my-secret-key';
  const password = 'password123';
  
  // HTTP URLs
  const url = 'http://example.com/api';
  const endpoint = 'http://api.example.com/v1/users';
  
  // Weak random
  final random = Random();
  final insecureRandom = Random(123);
  
  // Hardcoded URLs
  const apiUrl = 'https://api.example.com/v1/users';
  const webhookUrl = 'https://webhook.example.com/callback';
  
  // MD5 usage
  final hash = md5.convert(utf8.encode('password'));
  
  // SHA1 usage
  final sha1Hash = sha1.convert(utf8.encode('data'));
}
''';

const String secureCode = '''
import 'dart:math';
import 'dart:io';

void main() {
  // Secure random
  final random = Random.secure();
  
  // HTTPS URLs
  const url = 'https://example.com/api';
  const endpoint = 'https://api.example.com/v1/users';
  
  // Environment variables
  final apiKey = Platform.environment['API_KEY'];
  final secret = Platform.environment['SECRET_KEY'];
  
  // Secure hashing
  final hash = sha256.convert(utf8.encode('password'));
  final secureHash = sha512.convert(utf8.encode('data'));
}
''';

const String mixedCode = '''
import 'dart:math';

void main() {
  // Mix of secure and insecure code
  const apiKey = 'sk-1234567890abcdef'; // Insecure - hardcoded secret
  final random = Random.secure(); // Secure - secure random
  
  const httpUrl = 'http://example.com'; // Insecure - HTTP
  const httpsUrl = 'https://secure.example.com'; // Secure - HTTPS
  
  // Environment variable usage
  final envKey = Platform.environment['API_KEY']; // Secure
  
  // Weak hashing
  final weakHash = md5.convert(utf8.encode('data')); // Insecure
  
  // Secure hashing
  final secureHash = sha256.convert(utf8.encode('data')); // Secure
}
''';

const String complexCode = '''
import 'dart:math';
import 'dart:io';

class ApiClient {
  static const String _baseUrl = 'https://api.example.com'; // Secure - HTTPS
  
  final String apiKey;
  
  ApiClient({required this.apiKey});
  
  Future<void> makeRequest() async {
    // Insecure - HTTP URL
    const insecureUrl = 'http://legacy.example.com/api';
    
    // Secure - HTTPS URL
    const secureUrl = 'https://api.example.com/v1/data';
    
    // Insecure - hardcoded secret
    const secretKey = 'sk-abcdef1234567890';
    
    // Secure - environment variable
    final envKey = Platform.environment['API_SECRET'];
    
    // Insecure - weak random
    final random = Random();
    
    // Secure - secure random
    final secureRandom = Random.secure();
  }
}

void main() {
  // Insecure - hardcoded API key
  const client = ApiClient(apiKey: 'sk-1234567890abcdef');
  
  // Secure - environment variable
  final secureClient = ApiClient(
    apiKey: Platform.environment['API_KEY'] ?? '',
  );
}
''';
