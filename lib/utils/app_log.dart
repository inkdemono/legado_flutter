import 'package:flutter/foundation.dart';

/// 日志级别
enum LogLevel {
  all,
  debug, // 调试日志（仅开发模式）
  info, // 信息日志
  warning, // 警告日志
  error, // 错误日志
}

/// 日志分类
enum LogCategory {
  all,
  general,
  startup,
  serviceInit,
  performance,
  reader,
  network,
  storage,
  media,
  sync,
  ui,
  database,
}

/// 细粒度模块标签
abstract final class AppLogTag {
  static const String all = 'all';
  static const String general = 'general';
  static const String startup = 'startup';
  static const String startupFlow = 'startup_flow';
  static const String serviceInit = 'service_init';
  static const String performance = 'performance';
  static const String reader = 'reader';
  static const String parser = 'parser';
  static const String network = 'network';
  static const String protocol = 'protocol';
  static const String storage = 'storage';
  static const String media = 'media';
  static const String audio = 'audio';
  static const String video = 'video';
  static const String sync = 'sync';
  static const String ui = 'ui';
  static const String database = 'database';

  static String normalize(String tag) {
    if (tag.trim().isEmpty || tag == all) {
      return general;
    }
    return tag;
  }

  static String labelOf(String tag) {
    switch (tag) {
      case all:
        return '全部';
      case general:
        return '通用';
      case startup:
        return '启动';
      case startupFlow:
        return '启动流程';
      case serviceInit:
        return '服务初始化';
      case performance:
        return '性能';
      case reader:
        return '阅读器';
      case parser:
        return '解析器';
      case network:
        return '网络';
      case protocol:
        return '协议';
      case storage:
        return '存储';
      case media:
        return '媒体';
      case audio:
        return '音频';
      case video:
        return '视频';
      case sync:
        return '同步';
      case ui:
        return '界面';
      case database:
        return '数据库';
      default:
        return tag;
    }
  }
}

extension LogLevelX on LogLevel {
  String get label {
    switch (this) {
      case LogLevel.all:
        return '全部';
      case LogLevel.debug:
        return '调试';
      case LogLevel.info:
        return '信息';
      case LogLevel.warning:
        return '警告';
      case LogLevel.error:
        return '错误';
    }
  }
}

extension LogCategoryX on LogCategory {
  String get label {
    switch (this) {
      case LogCategory.all:
        return '全部';
      case LogCategory.general:
        return '通用';
      case LogCategory.startup:
        return '启动';
      case LogCategory.serviceInit:
        return '服务初始化';
      case LogCategory.performance:
        return '性能';
      case LogCategory.reader:
        return '阅读器';
      case LogCategory.network:
        return '网络';
      case LogCategory.storage:
        return '存储';
      case LogCategory.media:
        return '媒体';
      case LogCategory.sync:
        return '同步';
      case LogCategory.ui:
        return '界面';
      case LogCategory.database:
        return '数据库';
    }
  }
}

/// 应用日志管理
class AppLog {
  static final AppLog instance = AppLog._init();
  AppLog._init();

  final List<LogEntry> _logsList = [];
  static const int maxLogs = 200;

  /// 是否启用控制台输出（生产环境应关闭）
  static bool enableConsoleOutput = kDebugMode;

  /// 最小日志级别（低于此级别的日志不输出到控制台）
  static LogLevel minLogLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// 是否启用启动性能日志
  static bool enableStartupLogs = kDebugMode;

  /// 是否启用服务初始化日志
  static bool enableServiceInitLogs = kDebugMode;

  // 用于通知监听器
  final ValueNotifier<void> logsNotifier = ValueNotifier<void>(null);

  List<LogEntry> get logs => List.unmodifiable(_logsList);
  AppLogSummary get summary => AppLogSummary.fromLogs(_logsList);

  /// 添加日志
  void put(
    String? message, {
    Object? error,
    bool toast = false,
    LogLevel level = LogLevel.info,
    LogCategory category = LogCategory.general,
    String tag = AppLogTag.general,
    Duration? duration,
    Map<String, Object?>? metadata,
  }) {
    if (message == null || message.isEmpty) return;
    final resolvedTag = AppLogTag.normalize(tag);

    // 限制日志数量
    if (_logsList.length >= maxLogs) {
      _logsList.removeLast();
    }

    final resolvedLevel =
        error != null && level == LogLevel.info ? LogLevel.error : level;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      message: message,
      error: error?.toString(),
      stackTrace: error is Error ? error.stackTrace?.toString() : null,
      level: resolvedLevel,
      category: category,
      tag: resolvedTag,
      duration: duration,
      metadata: metadata,
    );

    _logsList.insert(0, entry);
    logsNotifier.value = null; // 触发通知

    // 控制台输出（受日志级别控制）
    if (enableConsoleOutput &&
        resolvedLevel != LogLevel.all &&
        resolvedLevel.index >= minLogLevel.index) {
      if (error != null) {
        debugPrint('AppLog: $message\n$error');
      } else {
        debugPrint('AppLog: $message');
      }
    }
  }

  /// 添加调试日志（仅在开发模式下记录）
  void putDebug(
    String? message, {
    Object? error,
    LogCategory category = LogCategory.general,
    String tag = AppLogTag.general,
  }) {
    if (!kDebugMode) return;
    put(
      message,
      error: error,
      level: LogLevel.debug,
      category: category,
      tag: tag,
    );
  }

  /// 添加启动性能日志
  void putStartup(
    String? message, {
    Object? error,
    Duration? duration,
    String tag = AppLogTag.startup,
  }) {
    if (!enableStartupLogs) return;
    put(
      message,
      error: error,
      level: LogLevel.debug,
      category: LogCategory.startup,
      tag: tag,
      duration: duration,
    );
  }

  /// 添加服务初始化日志
  void putServiceInit(
    String? message, {
    Object? error,
    Duration? duration,
    String tag = AppLogTag.serviceInit,
  }) {
    if (!enableServiceInitLogs) return;
    put(
      message,
      error: error,
      level: LogLevel.debug,
      category: LogCategory.serviceInit,
      tag: tag,
      duration: duration,
    );
  }

  /// 添加性能日志
  void putPerformance(
    String? message, {
    Duration? duration,
    LogCategory category = LogCategory.performance,
    String tag = AppLogTag.performance,
    LogLevel? level,
    Map<String, Object?>? metadata,
  }) {
    if (message == null || message.isEmpty) return;
    final resolvedLevel = level ??
        ((duration?.inMilliseconds ?? 0) >= 500
            ? LogLevel.warning
            : LogLevel.debug);
    put(
      message,
      level: resolvedLevel,
      category: category,
      tag: tag,
      duration: duration,
      metadata: metadata,
    );
  }

  /// 清空日志
  void clear() {
    _logsList.clear();
    logsNotifier.value = null; // 触发通知
  }
}

/// 日志条目
class LogEntry {
  final DateTime timestamp;
  final String message;
  final String? error;
  final String? stackTrace;
  final LogLevel level;
  final LogCategory category;
  final String tag;
  final Duration? duration;
  final Map<String, Object?> metadata;

  LogEntry({
    required this.timestamp,
    required this.message,
    this.error,
    this.stackTrace,
    this.level = LogLevel.info,
    this.category = LogCategory.general,
    this.tag = AppLogTag.general,
    this.duration,
    Map<String, Object?>? metadata,
  }) : metadata = Map.unmodifiable(metadata ?? const {});

  String get formattedTime {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  String get fullMessage {
    final buffer = StringBuffer();
    buffer.writeln('[tag: $tag]');
    if (duration != null) {
      buffer.writeln('[耗时 ${duration!.inMilliseconds}ms]');
    }
    buffer.write(message);
    if (error != null) {
      buffer.write('\n$error');
      if (stackTrace != null) {
        buffer.write('\n$stackTrace');
      }
    }
    if (metadata.isNotEmpty) {
      buffer.write('\nmetadata: $metadata');
    }
    return buffer.toString();
  }

  String get levelIcon {
    switch (level) {
      case LogLevel.all:
        return '•';
      case LogLevel.debug:
        return '🔧';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
}

class AppLogSummary {
  const AppLogSummary({
    required this.totalLogs,
    required this.levelCounts,
    required this.categoryCounts,
    required this.tagCounts,
    required this.repeatedEntries,
  });

  final int totalLogs;
  final Map<LogLevel, int> levelCounts;
  final Map<LogCategory, int> categoryCounts;
  final Map<String, int> tagCounts;
  final List<AggregatedLogEntry> repeatedEntries;

  factory AppLogSummary.fromLogs(List<LogEntry> logs) {
    final levelCounts = <LogLevel, int>{};
    final categoryCounts = <LogCategory, int>{};
    final tagCounts = <String, int>{};
    final groups = <String, AggregatedLogEntry>{};

    for (final log in logs) {
      levelCounts.update(log.level, (count) => count + 1, ifAbsent: () => 1);
      categoryCounts.update(
        log.category,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      tagCounts.update(log.tag, (count) => count + 1, ifAbsent: () => 1);

      final key =
          '${log.category.name}|${log.tag}|${log.level.name}|${log.message}|${log.error ?? ''}';
      final current = groups[key];
      if (current == null) {
        groups[key] = AggregatedLogEntry(
          category: log.category,
          tag: log.tag,
          level: log.level,
          message: log.message,
          count: 1,
          latestTimestamp: log.timestamp,
          latestDuration: log.duration,
        );
      } else {
        groups[key] = current.copyWith(
          count: current.count + 1,
          latestTimestamp: log.timestamp,
          latestDuration: log.duration ?? current.latestDuration,
        );
      }
    }

    final repeatedEntries =
        groups.values.where((entry) => entry.count > 1).toList()
          ..sort((a, b) {
            final countCompare = b.count.compareTo(a.count);
            if (countCompare != 0) return countCompare;
            return b.latestTimestamp.compareTo(a.latestTimestamp);
          });

    return AppLogSummary(
      totalLogs: logs.length,
      levelCounts: Map.unmodifiable(levelCounts),
      categoryCounts: Map.unmodifiable(categoryCounts),
      tagCounts: Map.unmodifiable(tagCounts),
      repeatedEntries: List.unmodifiable(repeatedEntries.take(5)),
    );
  }
}

class AggregatedLogEntry {
  const AggregatedLogEntry({
    required this.category,
    required this.tag,
    required this.level,
    required this.message,
    required this.count,
    required this.latestTimestamp,
    this.latestDuration,
  });

  final LogCategory category;
  final String tag;
  final LogLevel level;
  final String message;
  final int count;
  final DateTime latestTimestamp;
  final Duration? latestDuration;

  AggregatedLogEntry copyWith({
    int? count,
    DateTime? latestTimestamp,
    Duration? latestDuration,
  }) {
    return AggregatedLogEntry(
      category: category,
      tag: tag,
      level: level,
      message: message,
      count: count ?? this.count,
      latestTimestamp: latestTimestamp ?? this.latestTimestamp,
      latestDuration: latestDuration ?? this.latestDuration,
    );
  }
}
