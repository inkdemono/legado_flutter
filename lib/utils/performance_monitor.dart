import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_log.dart';

class PerformanceMetric {
  const PerformanceMetric({
    required this.name,
    required this.scope,
    required this.category,
    required this.duration,
    required this.timestamp,
    required this.success,
    this.metadata = const {},
    this.error,
  });

  final String name;
  final String scope;
  final LogCategory category;
  final Duration duration;
  final DateTime timestamp;
  final bool success;
  final Map<String, Object?> metadata;
  final Object? error;
}

class PerformanceMonitor {
  PerformanceMonitor._();

  static final PerformanceMonitor instance = PerformanceMonitor._();
  static const int maxMetrics = 120;

  final List<PerformanceMetric> _metrics = [];
  final ValueNotifier<void> metricsNotifier = ValueNotifier<void>(null);

  List<PerformanceMetric> get metrics => List.unmodifiable(_metrics);

  Future<T> trackAsync<T>(
    String name,
    Future<T> Function() action, {
    String scope = 'app',
    LogCategory category = LogCategory.performance,
    Duration warningThreshold = const Duration(milliseconds: 500),
    bool logSuccess = true,
    Map<String, Object?>? metadata,
  }) async {
    final start = DateTime.now();
    try {
      final result = await action();
      _record(
        PerformanceMetric(
          name: name,
          scope: scope,
          category: category,
          duration: DateTime.now().difference(start),
          timestamp: DateTime.now(),
          success: true,
          metadata: metadata ?? const {},
        ),
        warningThreshold: warningThreshold,
        logSuccess: logSuccess,
      );
      return result;
    } catch (error) {
      _record(
        PerformanceMetric(
          name: name,
          scope: scope,
          category: category,
          duration: DateTime.now().difference(start),
          timestamp: DateTime.now(),
          success: false,
          metadata: metadata ?? const {},
          error: error,
        ),
        warningThreshold: warningThreshold,
        logSuccess: true,
      );
      rethrow;
    }
  }

  void record(
    String name, {
    required Duration duration,
    String scope = 'app',
    LogCategory category = LogCategory.performance,
    Duration warningThreshold = const Duration(milliseconds: 500),
    bool success = true,
    bool logSuccess = true,
    Map<String, Object?>? metadata,
    Object? error,
  }) {
    _record(
      PerformanceMetric(
        name: name,
        scope: scope,
        category: category,
        duration: duration,
        timestamp: DateTime.now(),
        success: success,
        metadata: metadata ?? const {},
        error: error,
      ),
      warningThreshold: warningThreshold,
      logSuccess: logSuccess,
    );
  }

  void reset() {
    _metrics.clear();
    metricsNotifier.value = null;
  }

  void _record(
    PerformanceMetric metric, {
    required Duration warningThreshold,
    required bool logSuccess,
  }) {
    if (_metrics.length >= maxMetrics) {
      _metrics.removeLast();
    }
    _metrics.insert(0, metric);
    metricsNotifier.value = null;

    if (!metric.success) {
      AppLog.instance.put(
        '性能监控阶段失败: ${metric.scope}.${metric.name}',
        error: metric.error,
        category: metric.category,
        level: LogLevel.error,
        duration: metric.duration,
        metadata: metric.metadata,
      );
      return;
    }

    if (!logSuccess) {
      return;
    }

    final level = metric.duration >= warningThreshold
        ? LogLevel.warning
        : LogLevel.debug;

    AppLog.instance.putPerformance(
      '性能阶段完成: ${metric.scope}.${metric.name}',
      duration: metric.duration,
      category: metric.category,
      level: level,
      metadata: metric.metadata,
    );

    if (kDebugMode) {
      debugPrint(
        'Performance: ${metric.scope}.${metric.name} ${metric.duration.inMilliseconds}ms',
      );
    }
  }
}
