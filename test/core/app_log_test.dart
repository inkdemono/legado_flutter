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
      tag: AppLogTag.network,
      level: LogLevel.warning,
    );
    AppLog.instance.put(
      '网络请求超时',
      category: LogCategory.network,
      tag: AppLogTag.network,
      level: LogLevel.warning,
    );
    AppLog.instance.put(
      '数据库升级失败',
      error: StateError('boom'),
      category: LogCategory.database,
      tag: AppLogTag.database,
    );

    final summary = AppLog.instance.summary;

    expect(summary.totalLogs, 3);
    expect(summary.levelCounts[LogLevel.warning], 2);
    expect(summary.levelCounts[LogLevel.error], 1);
    expect(summary.categoryCounts[LogCategory.network], 2);
    expect(summary.categoryCounts[LogCategory.database], 1);
    expect(summary.tagCounts[AppLogTag.network], 2);
    expect(summary.tagCounts[AppLogTag.database], 1);
    expect(summary.repeatedEntries, hasLength(1));
    expect(summary.repeatedEntries.first.message, '网络请求超时');
    expect(summary.repeatedEntries.first.count, 2);
    expect(summary.repeatedEntries.first.tag, AppLogTag.network);
  });

  test('LogEntry.fullMessage 应该包含 tag、耗时和 metadata', () {
    AppLog.instance.put(
      '启动阶段完成',
      category: LogCategory.startup,
      tag: AppLogTag.startup,
      duration: const Duration(milliseconds: 123),
      metadata: const {'stage': 'bootstrap'},
    );

    final entry = AppLog.instance.logs.first;

    expect(entry.fullMessage, contains('[tag: startup]'));
    expect(entry.fullMessage, contains('[耗时 123ms]'));
    expect(entry.fullMessage, contains('启动阶段完成'));
    expect(entry.fullMessage, contains('metadata: {stage: bootstrap}'));
  });

  test('AppLog 应该归一化空 tag 并支持全部标签文案', () {
    AppLog.instance.put('未显式指定 tag', tag: '');

    final entry = AppLog.instance.logs.first;

    expect(entry.tag, AppLogTag.general);
    expect(AppLogTag.labelOf(AppLogTag.all), '全部');
    expect(AppLogTag.labelOf(AppLogTag.audio), '音频');
  });
}
