import 'dart:async';

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:dart_shield/src/analyzers/code/rules/rules.dart';

class ShieldPlugin extends Plugin {
  @override
  String get name => 'dart_shield';

  @override
  FutureOr<void> register(PluginRegistry registry) {
    rules.forEach(registry.registerWarningRule);
  }
}
