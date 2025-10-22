// shield_ignore_for_file: avoid_hardcoded_secrets

void main() {
  // shield_ignore: prefer_https_over_http
  final url = 'http://example.com';
  
  final key = 'secret'; // shield_ignore: avoid_hardcoded_secrets
  
  // shield_ignore: avoid_weak_hashing, prefer_secure_random
  final hash = 'md5';
  final random = '12345';
  
  // This should trigger violations since no suppression
  final anotherUrl = 'http://insecure.com';
  final anotherKey = 'another-secret';
  
  // Use variables to avoid unused variable warnings
  print('URL: $url');
  print('Key: $key');
  print('Hash: $hash');
  print('Random: $random');
  print('Another URL: $anotherUrl');
  print('Another Key: $anotherKey');
}
