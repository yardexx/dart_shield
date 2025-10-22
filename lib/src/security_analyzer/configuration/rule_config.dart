/// Configuration for a single rule that supports both string and object formats.
class RuleConfig {
  /// The name of the rule (e.g., 'avoid-hardcoded-secrets').
  final String name;
  
  /// List of file patterns to exclude for this rule.
  final List<String> exclude;

  const RuleConfig({
    required this.name,
    this.exclude = const [],
  });

  /// Creates a RuleConfig from a dynamic value that can be either a String or Map.
  factory RuleConfig.fromDynamic(dynamic value) {
    if (value is String) {
      return RuleConfig(name: value);
    } 
    
    if (value is Map) {
      final entries = value.entries.toList();
      if (entries.length != 1) {
        throw ArgumentError('Rule config map must have exactly one entry');
      }
      
      final entry = entries.first;
      final name = entry.key.toString();
      final configValue = entry.value;
      
      List<String> exclude = [];
      if (configValue is Map) {
        final excludeList = configValue['exclude'];
        if (excludeList is List) {
          exclude = excludeList.map((e) => e.toString()).toList();
        }
      }
      
      return RuleConfig(name: name, exclude: exclude);
    } else {
      throw ArgumentError('Rule config must be a String or Map, got ${value.runtimeType}');
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'exclude': exclude,
  };
}
