class ShieldRunConfig {
  const ShieldRunConfig({
    required this.paths,
    this.only = const [],
    this.exclude = const [],
    this.reporterMode = 'console',
  });

  final List<String> paths;
  final List<String> only;
  final List<String> exclude;
  final String reporterMode;
}
