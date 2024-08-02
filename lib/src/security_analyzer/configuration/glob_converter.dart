import 'package:glob/glob.dart';
import 'package:json_annotation/json_annotation.dart';

class GlobConverter implements JsonConverter<Glob, String> {
  const GlobConverter();

  @override
  Glob fromJson(String json) {
    return Glob(json);
  }

  @override
  String toJson(Glob object) {
    return object.pattern;
  }
}
