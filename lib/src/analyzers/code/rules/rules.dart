import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/cryptography/avoid_weak_hashing.dart';
import 'package:dart_shield/src/analyzers/code/rules/cryptography/prefer_secure_random.dart';
import 'package:dart_shield/src/analyzers/code/rules/network/avoid_harcoded_urls.dart';
import 'package:dart_shield/src/analyzers/code/rules/network/prefer_https_over_http.dart';
import 'package:dart_shield/src/analyzers/code/rules/secrets/avoid_hardcoded_secrets.dart';

final List<AnalysisRule> rules = [
  AvoidHardcodedSecrets(),
  AvoidHardcodedUrls(),
  AvoidWeakHashing(),
  PreferHttpsOverHttp(),
  PreferSecureRandom(),
];
