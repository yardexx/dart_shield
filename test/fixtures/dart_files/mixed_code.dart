// Test fixtures for mixed Dart code (secure and insecure)
const String mixedCode = '''
import 'dart:math';
import 'dart:io';

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

class MixedApiClient {
  static const String _baseUrl = 'https://api.example.com'; // Secure - HTTPS
  
  final String apiKey;
  
  MixedApiClient({required this.apiKey});
  
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
  const client = MixedApiClient(apiKey: 'sk-1234567890abcdef');
  
  // Secure - environment variable
  final secureClient = MixedApiClient(
    apiKey: Platform.environment['API_KEY'] ?? '',
  );
}
''';
