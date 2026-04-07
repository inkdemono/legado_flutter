import 'dart:io' show HttpException, Platform;
import 'package:legado_flutter/providers/service_registry.dart';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';

import '../../utils/app_log.dart';
import '../../utils/crash_handler.dart';

enum ErrorLevel { warning, error, critical }

class GlobalErrorHandler {
  GlobalErrorHandler._();

  static final RegExp _httpStatusCodePattern = RegExp(
    r'(?:^|\b)(?:invalid\s+)?status\s*code\s*[:=]\s*(\d{3})(?:\b|$)',
    caseSensitive: false,
  );

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void install() {
    FlutterError.onError = (details) {
      final stack = details.stack ?? StackTrace.current;
      if (_shouldIgnore(
          details.exception, stack, details.exceptionAsString())) {
        return;
      }

      final exception = details.exception;
      if (CrashHandler.shouldAbsorb(exception)) {
        AppLog.instance
            .put('发生未捕获的异常\n${exception.toString()}', error: exception);
        return;
      }

      FlutterError.presentError(details);
      handle(
        exception,
        stack,
        context: details.context?.toString() ?? 'FlutterError',
        silent: _shouldSilence(exception),
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (_shouldIgnore(error, stack, error.toString())) {
        return true;
      }

      if (CrashHandler.shouldAbsorb(error)) {
        AppLog.instance.put('发生未捕获的异常\n${error.toString()}', error: error);
        return true;
      }

      handle(
        error,
        stack,
        context: 'PlatformDispatcher',
        silent: _shouldSilence(error),
      );
      return true;
    };
  }

  static Future<void> handle(
    Object error,
    StackTrace stackTrace, {
    String? context,
    bool silent = false,
  }) async {
    final level = _classify(error);
    final label = context != null ? '[$context] ' : '';
    AppLog.instance.put(
      '$label${error.runtimeType}: $error',
      error: '$error\n$stackTrace',
      level: _toLogLevel(level),
    );

    await CrashHandler.handleException(error, stackTrace);
    await readService(AppServices.crashLogService).saveCrashLog(
      error: error.toString(),
      stackTrace: stackTrace.toString(),
      details: context,
    );

    if (!silent) {
      final messenger = scaffoldMessengerKey.currentState;
      messenger?.showSnackBar(
        SnackBar(content: Text(_toUserMessage(error))),
      );
    }
  }

  static ErrorLevel _classify(Object error) {
    if (error is HttpException) {
      return ErrorLevel.warning;
    }
    if (error is FormatException) {
      return ErrorLevel.error;
    }
    return ErrorLevel.critical;
  }

  static LogLevel _toLogLevel(ErrorLevel level) {
    switch (level) {
      case ErrorLevel.warning:
        return LogLevel.warning;
      case ErrorLevel.error:
        return LogLevel.error;
      case ErrorLevel.critical:
        return LogLevel.error;
    }
  }

  static String _toUserMessage(Object error) {
    if (error is HttpException) {
      return '网络请求失败，请稍后重试';
    }
    if (error is FormatException) {
      return '数据解析失败';
    }
    return '发生异常，请稍后重试';
  }

  static bool _shouldSilence(Object error) => isIgnorableMediaHttpError(error);

  static bool _shouldIgnore(
    Object error,
    StackTrace? stack,
    String details,
  ) {
    if (isIgnorableMediaHttpError(error)) {
      return true;
    }
    return _shouldIgnoreMouseTrackerAssertion(
      error: error,
      stack: stack,
      details: details,
    );
  }

  /// 可静默忽略的媒体资源扩展名（404 时不展示给用户）
  ///
  /// 包含图片、音频、视频常见格式。
  /// 使用列表而非硬编码字符串，方便后续维护扩展。
  static const List<String> _ignoredMediaExtensions = [
    // 图片
    '.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.svg',
    // 音频
    '.mp3', '.m4a', '.wav', '.ogg', '.aac', '.flac', '.opus',
    // 视频
    '.mp4', '.m4v', '.mkv', '.webm', '.mov', '.avi',
    // 流媒体清单（非实际内容，404 也可忽略）
    '.m3u8', '.mpd',
  ];

  /// 判断路径是否属于可忽略的媒体资源类型
  static bool _isMediaExtension(String? path) {
    if (path == null || path.isEmpty) return false;
    final lower = path.toLowerCase();
    return _ignoredMediaExtensions.any((ext) => lower.endsWith(ext));
  }

  /// `dart:io` 的 [HttpException] 不直接暴露 statusCode。
  ///
  /// 这里改为从 message 中提取数值状态码，而不是依赖完整固定文案，
  /// 从而降低第三方库调整错误前缀/大小写时的脆弱性。
  @visibleForTesting
  static int? extractHttpStatusCode(Object error) {
    if (error is! HttpException) return null;
    final match = _httpStatusCodePattern.firstMatch(error.message);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  /// 判断是否为可忽略的媒体资源 404 错误。
  @visibleForTesting
  static bool isIgnorableMediaHttpError(Object error) {
    if (error is! HttpException) return false;
    if (extractHttpStatusCode(error) != 404) return false;
    return _isMediaExtension(error.uri?.path);
  }

  static bool _shouldIgnoreMouseTrackerAssertion({
    required Object error,
    StackTrace? stack,
    required String details,
  }) {
    if (kIsWeb) {
      return false;
    }

    if (!(Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      return false;
    }

    final text = '$details\n${error.toString()}\n${stack?.toString() ?? ''}';
    final isMouseTrackerAssertion = text.contains('mouse_tracker.dart') &&
        text.contains('!_debugDuringDeviceUpdate');
    if (isMouseTrackerAssertion) {
      AppLog.instance.putDebug('已忽略桌面端 MouseTracker 断言噪音');
    }
    return isMouseTrackerAssertion;
  }
}
