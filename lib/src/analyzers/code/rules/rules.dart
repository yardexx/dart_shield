import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:dart_shield/src/analyzers/code/rules/auth/avoid_empty_catch.dart';
import 'package:dart_shield/src/analyzers/code/rules/cryptography/avoid_weak_hashing.dart';
import 'package:dart_shield/src/analyzers/code/rules/cryptography/prefer_secure_random.dart';
import 'package:dart_shield/src/analyzers/code/rules/injection/avoid_dynamic_sql_queries.dart';
import 'package:dart_shield/src/analyzers/code/rules/logging/avoid_logging_sensitive_data.dart';
import 'package:dart_shield/src/analyzers/code/rules/network/avoid_certificate_pinning_bypass.dart';
import 'package:dart_shield/src/analyzers/code/rules/network/avoid_harcoded_urls.dart';
import 'package:dart_shield/src/analyzers/code/rules/network/prefer_https_over_http.dart';
import 'package:dart_shield/src/analyzers/code/rules/secrets/avoid_hardcoded_secrets.dart';
import 'package:dart_shield/src/analyzers/code/rules/storage/avoid_insecure_file_storage.dart';
import 'package:dart_shield/src/analyzers/code/rules/storage/avoid_shared_preferences_for_secrets.dart';

final List<AnalysisRule> rules = [
  // Auth
  AvoidEmptyCatch(),
  // Cryptography
  AvoidWeakHashing(),
  PreferSecureRandom(),
  // Injection
  AvoidDynamicSqlQueries(),
  // Logging
  AvoidLoggingSensitiveData(),
  // Network
  AvoidCertificatePinningBypass(),
  AvoidHardcodedUrls(),
  PreferHttpsOverHttp(),
  // Secrets
  AvoidHardcodedSecrets(),
  // Storage
  AvoidInsecureFileStorage(),
  AvoidSharedPreferencesForSecrets(),
];
