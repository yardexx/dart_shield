import 'package:analyzer_plugin/protocol/protocol_common.dart';

enum Severity {
  critical('critical', AnalysisErrorSeverity.ERROR),
  warning('warning', AnalysisErrorSeverity.WARNING),
  info('info', AnalysisErrorSeverity.INFO);

  const Severity(this.value, this.analysisSeverity);

  final String value;
  final AnalysisErrorSeverity analysisSeverity;
}
