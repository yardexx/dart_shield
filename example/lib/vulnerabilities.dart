// ignore_for_file: unused_local_variable

import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

// dart_shield rule: prefer-https-over-http
void usingHttp() {
  // Violation: Using `http` constructor instead of `https`
  final unsafeUri = Uri.http('example.com', 'path');

  // Violation: URL link uses `http` instead of `https`
  final unsafeParsedUri = Uri.parse('http://example.com');

  // Violation: URL link uses `http` instead of `https`
  final url = 'http://example.com';
}

// dart_shield rule: avoid-hardcoded-urls
void hardcodedUrls() {
  // Violation: URL link is hardcoded
  final url = 'https://example.com';

  // Violation: URL link is hardcoded in the constructor
  http.get(Uri.parse('https://example.com'));
}

// dart_shield rule: avoid-weak-hashing
void weakHashes() {
  // Violation: Using weak hash function
  final md5Hash = md5.convert('message'.codeUnits);

  // Violation: Using weak hash function
  final sha1Hash = sha1.convert('message'.codeUnits);

  // Violation: Assigning weak hash function to a variable
  final hasher = md5;
}

// dart_shield rule: prefer-secure-random
void unsecureRandom() {
  // Violation: Using `Random` instead of `Random.secure()`
  final random = Random.secure();
}

// dart_shield rule: avoid-hardcoded-secrets
void hardcodedSecrets() {
  // Violation: Hardcoded Gitlab Personal Access Token
  final gitlabPersonalToken = 'glpat-xxxxxxxxxxxxxxxxxxxx';

  // Violation: Hardcoded GitHub Personal Access Token
  final githubPersonalToken = 'ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

  // Violation: Hardcoded GitHub OAuth Token
  final githubOAuthToken = 'gho_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

  // Violation: Hardcoded GitHub App Token
  final githubAppTokenFirst = 'gho_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  final githubAppTokenSecond = 'ghs_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

  // Violation: Hardcoded AWS Access Token
  final awsAccessToken = 'AKIAxxxxxxxxxxxxxxxx';

  // Violation: Hardcoded Stripe Live API Key
  final stripeLiveApiKey = 'sk_live_xxxxxxxxxxxxxxxxxxxxxxxx';

  // Violation: Hardcoded Google API Key
  final googleApiKey = 'AIzaxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
}
