// shield_ignore_for_file: avoid_hardcoded_secrets

// ignore_for_file: avoid_print

void main() {
  // shield_ignore: prefer_https_over_http
  const url = 'http://example.com';

  const key = 'secret'; // shield_ignore: avoid_hardcoded_secrets

  // shield_ignore: avoid_weak_hashing, prefer_secure_random
  const hash = 'md5';
  const random = '12345';

  // This should trigger violations since no suppression
  const anotherUrl = 'http://insecure.com';
  const anotherKey = 'another-secret';

  // Use variables to avoid unused variable warnings
  print('URL: $url');
  print('Key: $key');
  print('Hash: $hash');
  print('Random: $random');
  print('Another URL: $anotherUrl');
  print('Another Key: $anotherKey');
}
