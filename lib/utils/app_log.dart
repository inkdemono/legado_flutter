import 'package:flutter/foundation.dart';

/// 日志级别
enum LogLevel {
  debug,   // 调试日志（仅开发模式）
  info,    // 信息日志
  warning, // 警告日志
  error,   // 错误日志
}

/// 应用日志管理
class AppLog {
  static final AppLog instance = AppLog._init();
  AppLog._init();

  final List<LogEntry> _logsList = [];
  static const int maxLogs = 100;

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

  /// 添加日志
  void put(String? message, {Object? error, bool toast = false, LogLevel level = LogLevel.info}) {
    if (message == null || message.isEmpty) return;

    // 限制日志数量
    if (_logsList.length >= maxLogs) {
      _logsList.removeLast();
    }

    final entry = LogEntry(
      timestamp: DateTime.now(),
      message: message,
      error: error?.toString(),
      stackTrace: error is Error ? error.stackTrace?.toString() : null,
      level: level,
    );

    _logsList.insert(0, entry);
    logsNotifier.value = null; // 触发通知

    // 控制台输出（受日志级别控制）
    if (enableConsoleOutput && level.index >= minLogLevel.index) {
      if (error != null) {
        debugPrint('AppLog: $message\n$error');
      } else {
        debugPrint('AppLog: $message');
      }
    }
  }

  /// 添加调试日志（仅在开发模式下记录）
  void putDebug(String? message, {Object? error}) {
    if (!kDebugMode) return;
    put(message, error: error, level: LogLevel.debug);
  }

  /// 添加启动性能日志
  void putStartup(String? message, {Object? error}) {
    if (!enableStartupLogs) return;
    put(message, error: error, level: LogLevel.debug);
  }

  /// 添加服务初始化日志
  void putServiceInit(String? message, {Object? error}) {
    if (!enableServiceInitLogs) return;
    put(message, error: error, level: LogLevel.debug);
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

  LogEntry({
    required this.timestamp,
    required this.message,
    this.error,
    this.stackTrace,
    this.level = LogLevel.info,
  });

  String get formattedTime {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  String get fullMessage {
    if (error != null) {
      return '$message\n$error${stackTrace != null ? '\n$stackTrace' : ''}';
    }
    return message;
  }

  String get levelIcon {
    switch (level) {
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
