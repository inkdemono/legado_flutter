import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:ui' show PlatformDispatcher;
import 'dart:io' show HttpException, Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'config/theme_config.dart';
import 'services/url_scheme_service.dart';
import 'services/receiver/network_changed_listener.dart';
import 'services/receiver/time_battery_listener.dart';
import 'services/receiver/media_button_handler.dart';
import 'services/receiver/share_receiver_channel.dart';
import 'services/receiver/file_receiver_channel.dart';
import 'services/notification_service.dart';
import 'services/crash_log_service.dart';
import 'utils/crash_handler.dart';
import 'utils/app_log.dart';
import 'services/media/audio_play_service.dart';
import 'services/shortcut_service.dart';
import 'services/book_group_service.dart';
import 'services/source/source_config_service.dart';
import 'services/local_config_service.dart';
import 'services/read_config_service.dart';
import 'utils/default_data.dart';
import 'utils/startup_performance_monitor.dart';

void main() async {
  // 初始化性能监控
  startupPerformanceMonitor.reset();
  startupPerformanceMonitor.start('total_app_startup');

  WidgetsFlutterBinding.ensureInitialized();
  startupPerformanceMonitor.end('widget_binding');

  try {
    startupPerformanceMonitor.start('app_config_init');
    // 第一阶段：关键初始化（优化为非阻塞预加载）
    // 预加载配置（不阻塞主线程）
    AppConfig.preload();
    await AppTheme.init();
    startupPerformanceMonitor.end('app_config_init');

    // 设置全局错误处理（必须在其他初始化之前）
    _setupErrorHandlers();

    // 第二阶段：关键服务初始化（只初始化最核心的服务）
    startupPerformanceMonitor.start('critical_services_init');

    // 优化：所有服务改为懒加载，首次使用时自动初始化
    // NetworkService 已经继承自 BaseService，支持自动懒加载
    // 当首次调用 NetworkService.instance.get() 时会自动调用 init()
    if (AppLog.enableStartupLogs) {
      debugPrint('Check: Critical services skipped (lazy loading)');
    }

    startupPerformanceMonitor.end('critical_services_init');

    // 第三阶段：其他服务延迟到首帧后初始化
    startupPerformanceMonitor.start('other_services_init');
    _schedulePostFrameInitialization();
    startupPerformanceMonitor.end('other_services_init');

    // 第四阶段：平台特定初始化延迟到后台
    if (!kIsWeb) {
      startupPerformanceMonitor.start('platform_specific_init');
      _schedulePlatformSpecificInit();
      startupPerformanceMonitor.end('platform_specific_init');
    }

    // 记录启动完成时间
    startupPerformanceMonitor.end('total_app_startup');

    // 输出性能报告
    if (AppLog.enableStartupLogs) {
      AppLog.instance.putStartup(
          '应用初始化完成，总耗时: ${startupPerformanceMonitor.getDuration('total_app_startup')?.inMilliseconds ?? 0}ms');
      startupPerformanceMonitor.printAllDurations();
    }
  } catch (e) {
    // 即使初始化失败也继续运行
    AppLog.instance.put('应用初始化过程中发生未预期的错误', error: e);
  }

  // 设置系统UI样式（Web平台不支持）
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  runApp(
    const ProviderScope(
      child: LegadoApp(),
    ),
  );
}

/// 初始化阅读配置服务
Future<void> _initReadConfigService() async {
  try {
    await ReadConfigService.instance.initConfigs();
  } catch (e) {
    AppLog.instance.putServiceInit('初始化阅读配置服务失败', error: e);
  }
}

/// 初始化本地配置服务
Future<void> _initLocalConfigService() async {
  try {
    await LocalConfigService.instance.init();
    // 初始化应用版本号（快速操作，不需要等待）
    LocalConfigService.instance.initVersionCode().catchError((e) {
      AppLog.instance.putServiceInit('初始化应用版本号失败', error: e);
    });
  } catch (e) {
    AppLog.instance.putServiceInit('初始化本地配置服务失败', error: e);
  }
}

/// 初始化基础服务
Future<void> _initBaseServices() async {
  // 目前暂时为空，可以添加更多基础服务
}

/// 初始化崩溃日志服务
Future<void> _initCrashLogService() async {
  try {
    await CrashLogService.instance.init();
  } catch (e) {
    AppLog.instance.putServiceInit('初始化崩溃日志服务失败', error: e);
  }
}

/// 优化版的书籍分组服务初始化
Future<void> _initBookGroupServiceOptimized() async {
  try {
    await BookGroupService.instance.init();
    // 延迟到后台执行默认分组初始化，避免阻塞启动
    Future.microtask(() async {
      try {
        await BookGroupService.instance.initDefaultGroups();
      } catch (e) {
        AppLog.instance.putServiceInit('初始化默认分组失败', error: e);
      }
    });
  } catch (e) {
    AppLog.instance.putServiceInit('初始化书籍分组服务失败', error: e);
  }
}

/// 初始化书源配置服务
Future<void> _initSourceConfigService() async {
  try {
    await SourceConfigService.instance.init();
  } catch (e) {
    AppLog.instance.putServiceInit('初始化书源配置服务失败', error: e);
  }
}

/// 初始化音频播放服务
Future<void> _initAudioPlayService() async {
  try {
    await AudioPlayService.instance.init();
  } catch (e) {
    AppLog.instance.putServiceInit('初始化音频播放服务失败', error: e);
  }
}

/// 初始化网络变化监听器
Future<void> _initNetworkChangedListener() async {
  try {
    await NetworkChangedListener.instance.init();
  } catch (e) {
    AppLog.instance.putServiceInit('初始化网络变化监听器失败', error: e);
  }
}

/// 初始化时间和电池监听器
Future<void> _initTimeBatteryListener() async {
  try {
    await TimeBatteryListener.instance.init();
  } catch (e) {
    AppLog.instance.putServiceInit('初始化时间和电池监听器失败', error: e);
  }
}

/// 初始化媒体按钮处理器
Future<void> _initMediaButtonHandler() async {
  try {
    await MediaButtonHandler.instance.init();
  } catch (e) {
    AppLog.instance.putServiceInit('初始化媒体按钮处理器失败', error: e);
  }
}

/// 初始化URL Scheme服务
Future<void> _initUrlSchemeService() async {
  try {
    UrlSchemeService.instance.init();
  } catch (e) {
    AppLog.instance.putServiceInit('初始化URL Scheme服务失败', error: e);
  }
}

/// 初始化分享接收平台通道
Future<void> _initShareReceiverChannel() async {
  try {
    await ShareReceiverChannel.init();
  } catch (e) {
    AppLog.instance.putServiceInit('初始化分享接收平台通道失败', error: e);
  }
}

/// 初始化文件接收平台通道
Future<void> _initFileReceiverChannel() async {
  try {
    await FileReceiverChannel.instance.init();
  } catch (e) {
    AppLog.instance.putServiceInit('初始化文件接收平台通道失败', error: e);
  }
}

/// 初始化通知服务
Future<void> _initNotificationService() async {
  try {
    await NotificationService.instance.init();
  } catch (e) {
    AppLog.instance.putServiceInit('初始化通知服务失败', error: e);
  }
}

/// 初始化快捷方式服务
Future<void> _initShortcutService() async {
  try {
    await ShortcutService.instance.buildShortcuts();
  } catch (e) {
    AppLog.instance.putServiceInit('初始化快捷方式服务失败', error: e);
  }
}

void _trackDetachedStartupTask(
  String stage,
  Future<void> Function() task,
) {
  Future.microtask(() async {
    await startupPerformanceMonitor.trackAsync(stage, task);
  });
}

/// 调度非关键服务初始化（后台执行，不阻塞启动）
void _scheduleNonCriticalServices() {
  _trackDetachedStartupTask('post_frame.non_critical.crash_log_service',
      () async {
    try {
      await _initCrashLogService();
    } catch (e) {
      AppLog.instance.putServiceInit('后台初始化崩溃日志服务失败', error: e);
    }
  });

  _trackDetachedStartupTask('post_frame.non_critical.audio_play_service',
      () async {
    try {
      await _initAudioPlayService();
    } catch (e) {
      AppLog.instance.putServiceInit('后台初始化音频播放服务失败', error: e);
    }
  });
}

/// 调度平台特定初始化（后台执行，不阻塞启动）
void _schedulePlatformSpecificInit() {
  if (kIsWeb) return;

  _trackDetachedStartupTask('platform.network_changed_listener', () async {
    try {
      await _initNetworkChangedListener();
    } catch (e) {
      AppLog.instance.putServiceInit('后台初始化网络变化监听器失败', error: e);
    }
  });

  _trackDetachedStartupTask('platform.time_battery_listener', () async {
    try {
      await _initTimeBatteryListener();
    } catch (e) {
      AppLog.instance.putServiceInit('后台初始化时间和电池监听器失败', error: e);
    }
  });

  _trackDetachedStartupTask('platform.media_button_handler', () async {
    try {
      await _initMediaButtonHandler();
    } catch (e) {
      AppLog.instance.putServiceInit('后台初始化媒体按钮处理器失败', error: e);
    }
  });

  _trackDetachedStartupTask('platform.url_scheme_service', () async {
    try {
      _initUrlSchemeService();
    } catch (e) {
      AppLog.instance.putServiceInit('后台初始化URL Scheme服务失败', error: e);
    }
  });

  // Android 特定初始化（延迟到后台）
  if (Platform.isAndroid) {
    _trackDetachedStartupTask('platform.share_receiver_channel', () async {
      try {
        await _initShareReceiverChannel();
      } catch (e) {
        AppLog.instance.putServiceInit('后台初始化分享接收平台通道失败', error: e);
      }
    });

    _trackDetachedStartupTask('platform.file_receiver_channel', () async {
      try {
        await _initFileReceiverChannel();
      } catch (e) {
        AppLog.instance.putServiceInit('后台初始化文件接收平台通道失败', error: e);
      }
    });

    _trackDetachedStartupTask('platform.notification_service', () async {
      try {
        await _initNotificationService();
      } catch (e) {
        AppLog.instance.putServiceInit('后台初始化通知服务失败', error: e);
      }
    });

    _trackDetachedStartupTask('platform.shortcut_service', () async {
      try {
        await _initShortcutService();
      } catch (e) {
        AppLog.instance.putServiceInit('后台初始化快捷方式服务失败', error: e);
      }
    });
  }
}

/// 调度首帧后初始化任务（优化：首帧渲染完成后执行）
void _schedulePostFrameInitialization() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _trackDetachedStartupTask('post_frame.local_config_service', () async {
      try {
        await _initLocalConfigService();
      } catch (e) {
        AppLog.instance.putServiceInit('后台初始化本地配置服务失败', error: e);
      }
    });

    _trackDetachedStartupTask('post_frame.read_config_service', () async {
      try {
        await _initReadConfigService();
      } catch (e) {
        AppLog.instance.putServiceInit('后台初始化阅读配置服务失败', error: e);
      }
    });

    _trackDetachedStartupTask('post_frame.base_services', () async {
      try {
        await _initBaseServices();
      } catch (e) {
        AppLog.instance.putServiceInit('后台初始化基础服务失败', error: e);
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () async {
      await startupPerformanceMonitor.trackAsync(
        'post_frame.book_group_service',
        () async {
          try {
            await _initBookGroupServiceOptimized();
          } catch (e) {
            AppLog.instance.putServiceInit('后台初始化书籍分组服务失败', error: e);
          }
        },
      );
    });

    Future.delayed(const Duration(milliseconds: 100), () async {
      await startupPerformanceMonitor.trackAsync(
        'post_frame.source_config_service',
        () async {
          try {
            await _initSourceConfigService();
          } catch (e) {
            AppLog.instance.putServiceInit('后台初始化书源配置服务失败', error: e);
          }
        },
      );
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      _scheduleNonCriticalServices();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _scheduleBackgroundInitialization();
    });
  });
}

/// 调度后台初始化任务
void _scheduleBackgroundInitialization() {
  _trackDetachedStartupTask('background.default_data_up_version', () async {
    try {
      await DefaultData.instance.upVersion();
    } catch (e) {
      AppLog.instance.putServiceInit('版本升级检查失败', error: e);
    }
  });
}

/// 设置全局错误处理
void _setupErrorHandlers() {
  // 捕获Flutter框架错误
  FlutterError.onError = (FlutterErrorDetails details) {
    if (_shouldIgnoreMouseTrackerAssertion(
      error: details.exception,
      stack: details.stack,
      details: details.exceptionAsString(),
    )) {
      return;
    }

    // 过滤掉图片加载的 404 错误，不显示在控制台
    final exception = details.exception;
    if (exception is HttpException &&
        exception.message.contains('Invalid statusCode: 404') &&
        (exception.uri?.path.contains('.jpg') == true ||
            exception.uri?.path.contains('.png') == true ||
            exception.uri?.path.contains('.jpeg') == true ||
            exception.uri?.path.contains('.webp') == true)) {
      // 静默处理图片加载失败的错误
      return;
    }

    // 检查是否应该吸收异常
    if (CrashHandler.shouldAbsorb(exception)) {
      AppLog.instance
          .put('发生未捕获的异常\n${exception.toString()}', error: exception);
      return;
    }

    FlutterError.presentError(details);

    // 使用增强的 CrashHandler 处理异常
    CrashHandler.handleException(exception, details.stack);

    // 保存崩溃日志（兼容性）
    CrashLogService.instance.saveCrashLog(
      error: details.exceptionAsString(),
      stackTrace: details.stack?.toString() ?? '无堆栈信息',
      details: details.context?.toString(),
    );
  };

  // 捕获异步错误（非Flutter框架错误）
  PlatformDispatcher.instance.onError = (error, stack) {
    if (_shouldIgnoreMouseTrackerAssertion(
      error: error,
      stack: stack,
      details: error.toString(),
    )) {
      return true;
    }

    // 过滤掉图片加载的 404 错误
    if (error is HttpException &&
        error.message.contains('Invalid statusCode: 404') &&
        (error.uri?.path.contains('.jpg') == true ||
            error.uri?.path.contains('.png') == true ||
            error.uri?.path.contains('.jpeg') == true ||
            error.uri?.path.contains('.webp') == true)) {
      // 静默处理图片加载失败的错误
      return true;
    }

    // 检查是否应该吸收异常
    if (CrashHandler.shouldAbsorb(error)) {
      AppLog.instance.put('发生未捕获的异常\n${error.toString()}', error: error);
      return true;
    }

    // 使用增强的 CrashHandler 处理异常
    CrashHandler.handleException(error, stack);

    // 保存崩溃日志（兼容性）
    CrashLogService.instance.saveCrashLog(
      error: error.toString(),
      stackTrace: stack.toString(),
    );

    return true; // 表示错误已处理
  };
}

bool _shouldIgnoreMouseTrackerAssertion({
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
      (text.contains('!_debugDuringDeviceUpdate') ||
          text.contains(
            '(event is PointerAddedEvent) == (lastEvent is PointerRemovedEvent)',
          ) ||
          error is AssertionError);

  return isMouseTrackerAssertion;
}
