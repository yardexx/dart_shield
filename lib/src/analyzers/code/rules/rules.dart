import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/avoid_harcoded_urls.dart';
import 'package:dart_shield/src/analyzers/code/rules/avoid_weak_hashing.dart';
import 'package:dart_shield/src/analyzers/code/rules/prefer_https_over_http.dart';
import 'package:dart_shield/src/analyzers/code/rules/prefer_secure_random.dart';

final List<AnalysisRule> rules = [
  AvoidHardcodedUrls(),
  AvoidWeakHashing(),
  PreferHttpsOverHttp(),
  PreferSecureRandom(),
];
