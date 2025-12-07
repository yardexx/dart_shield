import 'package:dart_shield/src/analyzers/code/code_analyzer.dart';
import 'package:dart_shield/src/configuration/shield_config.dart';
import 'package:dart_shield/src/core/analyzer_factory.dart';
import 'package:test/test.dart';

void main() {
  group('AnalyzerFactory', () {
    const defaultConfig = ShieldConfig();
    const emptyPaths = <String>[];

    test('resolves default analyzers (code)', () {
      final analyzers = AnalyzerFactory.resolve(
        paths: emptyPaths,
        config: defaultConfig,
      );
      expect(analyzers, hasLength(1));
      expect(analyzers.first, isA<CodeAnalyzer>());
    });

    test('respects config disabling analyzers', () {
      const config = ShieldConfig(
        analyzers: ShieldAnalyzersConfig(code: false),
      );
      final analyzers = AnalyzerFactory.resolve(
        paths: emptyPaths,
        config: config,
      );
      expect(analyzers, isEmpty);
    });

    test('respects "only" argument (overrides config)', () {
      const config = ShieldConfig(
        analyzers: ShieldAnalyzersConfig(code: false),
      );
      final analyzers = AnalyzerFactory.resolve(
        paths: emptyPaths,
        config: config,
        only: ['code'],
      );
      expect(analyzers, hasLength(1));
      expect(analyzers.first, isA<CodeAnalyzer>());
    });

    test('respects "exclude" argument (overrides everything)', () {
      final analyzers = AnalyzerFactory.resolve(
        paths: emptyPaths,
        config: defaultConfig,
        exclude: ['code'],
      );
      expect(analyzers, isEmpty);
    });

    test('exclude takes precedence over only', () {
      final analyzers = AnalyzerFactory.resolve(
        paths: emptyPaths,
        config: defaultConfig,
        only: ['code'],
        exclude: ['code'],
      );
      expect(analyzers, isEmpty);
    });
  });
}
