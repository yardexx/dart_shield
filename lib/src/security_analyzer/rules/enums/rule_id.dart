enum RuleId {
  preferHttpsOverHttp,
  avoidHardcodedUrls,
  avoidHardcodedSecrets,
  avoidWeakHashing,
  preferSecureRandom;

  static RuleId fromYamlName(String name) {
    // Convert snake_case to camelCase
    final camelCaseName = name.replaceAllMapped(RegExp(r'_(\w)'), (match) {
      final matchStr = match.group(1);
      return matchStr != null ? matchStr.toUpperCase() : '';
    });

    // Use RuleId.values.byName to get the enum value
    return RuleId.values.byName(camelCaseName);
  }

  /// Converts the enum name to underscore format for use in suppression
  /// comments.
  /// Example: preferHttpsOverHttp -> prefer_https_over_http
  String toUnderscoreCase() {
    final name = this.name;
    // Convert camelCase to underscore_case
    return name.replaceAllMapped(RegExp('([a-z])([A-Z])'), (match) {
      return '${match.group(1)}_${match.group(2)!.toLowerCase()}';
    });
  }
}
