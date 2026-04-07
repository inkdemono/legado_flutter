import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/utils/app_log.dart';

void main() {
  setUp(() {
    AppLog.instance.clear();
  });

  test('AppLogSummary 应该按级别和分类聚合重复日志', () {
    AppLog.instance.put(
      '网络请求超时',
      category: LogCategory.network,
      level: LogLevel.warning,
    );
    AppLog.instance.put(
      '网络请求超时',
      category: LogCategory.network,
      level: LogLevel.warning,
    );
    AppLog.instance.put(
      '数据库升级失败',
      error: StateError('boom'),
      category: LogCategory.database,
    );

    final summary = AppLog.instance.summary;

    expect(summary.totalLogs, 3);
    expect(summary.levelCounts[LogLevel.warning], 2);
    expect(summary.levelCounts[LogLevel.error], 1);
    expect(summary.categoryCounts[LogCategory.network], 2);
    expect(summary.categoryCounts[LogCategory.database], 1);
    expect(summary.repeatedEntries, hasLength(1));
    expect(summary.repeatedEntries.first.message, '网络请求超时');
    expect(summary.repeatedEntries.first.count, 2);
  });

  test('LogEntry.fullMessage 应该包含耗时和 metadata', () {
    AppLog.instance.put(
      '启动阶段完成',
      category: LogCategory.startup,
      duration: const Duration(milliseconds: 123),
      metadata: const {'stage': 'bootstrap'},
    );

    final entry = AppLog.instance.logs.first;

    expect(entry.fullMessage, contains('[耗时 123ms]'));
    expect(entry.fullMessage, contains('启动阶段完成'));
    expect(entry.fullMessage, contains('metadata: {stage: bootstrap}'));
  });
}
