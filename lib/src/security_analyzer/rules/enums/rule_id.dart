enum RuleId {
  preferHttpsOverHttp,
  avoidHardcodedUrls,
  avoidHardcodedSecrets,
  avoidWeakHashing,
  preferSecureRandom;

  static RuleId fromYamlName(String name) {
    // Convert kebab-case to camelCase
    final camelCaseName = name.replaceAllMapped(RegExp(r'-(\w)'), (match) {
      final matchStr = match.group(1);
      return matchStr != null ? matchStr.toUpperCase() : '';
    });

    // Use RuleId.values.byName to get the enum value
    return RuleId.values.byName(camelCaseName);
  }
}
