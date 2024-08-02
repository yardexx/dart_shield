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
  final random = Random();
}
