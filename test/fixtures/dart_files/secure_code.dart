// Test fixtures for secure Dart code
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

class SecureApiClient {
  static const String _baseUrl = 'https://api.example.com';
  
  final String apiKey;
  
  SecureApiClient({required this.apiKey});
  
  Future<void> makeRequest() async {
    // All URLs use HTTPS
    const secureUrl = 'https://api.example.com/v1/data';
    
    // All secrets from environment
    final secretKey = Platform.environment['API_SECRET'];
    
    // All random generation is secure
    final random = Random.secure();
  }
}

void main() {
  // All API keys from environment
  final client = SecureApiClient(
    apiKey: Platform.environment['API_KEY'] ?? '',
  );
}
''';
