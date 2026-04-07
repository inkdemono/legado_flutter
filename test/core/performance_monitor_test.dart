import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/utils/app_log.dart';
import 'package:legado_flutter/utils/performance_monitor.dart';

void main() {
  setUp(() {
    AppLog.instance.clear();
    PerformanceMonitor.instance.reset();
  });

  test('trackAsync 成功时应该记录性能指标和日志', () async {
    final result = await PerformanceMonitor.instance.trackAsync<int>(
      'load_books',
      () async => 42,
      scope: 'startup',
      category: LogCategory.startup,
      warningThreshold: Duration.zero,
    );

    expect(result, 42);
    expect(PerformanceMonitor.instance.metrics, hasLength(1));

    final metric = PerformanceMonitor.instance.metrics.first;
    expect(metric.name, 'load_books');
    expect(metric.scope, 'startup');
    expect(metric.category, LogCategory.startup);
    expect(metric.success, isTrue);

    final log = AppLog.instance.logs.first;
    expect(log.message, contains('性能阶段完成: startup.load_books'));
    expect(log.category, LogCategory.startup);
    expect(log.level, LogLevel.warning);
  });

  test('trackAsync 失败时应该记录失败指标和错误日志', () async {
    await expectLater(
      PerformanceMonitor.instance.trackAsync<void>(
        'load_books',
        () async => throw StateError('network down'),
        scope: 'startup',
      ),
      throwsA(isA<StateError>()),
    );

    expect(PerformanceMonitor.instance.metrics, hasLength(1));

    final metric = PerformanceMonitor.instance.metrics.first;
    expect(metric.success, isFalse);
    expect(metric.error, isA<StateError>());

    final log = AppLog.instance.logs.first;
    expect(log.message, contains('性能监控阶段失败: startup.load_books'));
    expect(log.level, LogLevel.error);
  });
}
