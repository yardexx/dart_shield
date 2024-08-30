import 'package:json_annotation/json_annotation.dart';

part 'matching_pattern.g.dart';

@JsonSerializable(fieldRename: FieldRename.kebab, createToJson: false)
class MatchingPattern {
  MatchingPattern({
    required this.name,
    required this.pattern,
  });

  factory MatchingPattern.fromJson(Map<String, dynamic> json) =>
      _$MatchingPatternFromJson(json);

  final String name;
  final String pattern;

  RegExp get regex => RegExp(pattern);
}
