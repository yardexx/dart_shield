import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/cryptography/avoid_weak_hashing.dart';
import 'package:dart_shield/src/analyzers/code/rules/cryptography/prefer_secure_random.dart';
import 'package:dart_shield/src/analyzers/code/rules/flutter/avoid_insecure_webview_settings.dart';
import 'package:dart_shield/src/analyzers/code/rules/flutter/avoid_unvalidated_deep_link.dart';
import 'package:dart_shield/src/analyzers/code/rules/flutter/avoid_webview_javascript_bridge.dart';
import 'package:dart_shield/src/analyzers/code/rules/network/avoid_harcoded_urls.dart';
import 'package:dart_shield/src/analyzers/code/rules/network/prefer_https_over_http.dart';
import 'package:dart_shield/src/analyzers/code/rules/secrets/avoid_hardcoded_secrets.dart';

final List<AnalysisRule> rules = [
  // Cryptography
  AvoidWeakHashing(),
  PreferSecureRandom(),
  // Flutter
  AvoidInsecureWebviewSettings(),
  AvoidUnvalidatedDeepLink(),
  AvoidWebviewJavascriptBridge(),
  // Network
  AvoidHardcodedUrls(),
  PreferHttpsOverHttp(),
  // Secrets
  AvoidHardcodedSecrets(),
];
