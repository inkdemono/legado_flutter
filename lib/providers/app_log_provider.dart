import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:legado_flutter/providers/helpers/listenable_stream.dart';
import 'package:legado_flutter/utils/app_log.dart';

final appLogProvider = Provider<AppLog>((ref) {
  return AppLog.instance;
});

final appLogEntriesProvider = StreamProvider<List<LogEntry>>((ref) {
  final appLog = ref.watch(appLogProvider);
  return streamFromListenables(
    ref,
    listenables: [appLog.logsNotifier],
    read: () => appLog.logs,
  );
});

final appLogSummaryProvider = Provider<AppLogSummary>((ref) {
  final logs = ref.watch(appLogEntriesProvider).asData?.value ??
      ref.watch(appLogProvider).logs;
  return AppLogSummary.fromLogs(logs);
});
