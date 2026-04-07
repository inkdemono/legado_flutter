import 'dart:async';
import 'package:legado_flutter/providers/service_registry.dart';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../config/theme_config.dart';
import '../../services/receiver/file_receiver_channel.dart';
import '../../services/receiver/media_button_handler.dart';
import '../../services/receiver/network_changed_listener.dart';
import '../../services/receiver/share_receiver_channel.dart';
import '../../services/receiver/time_battery_listener.dart';
import '../../utils/app_log.dart';
import '../../utils/default_data.dart';
import '../../utils/startup_performance_monitor.dart';

typedef _StartupAction = Future<void> Function();

class _StartupTask {
  const _StartupTask({
    required this.stage,
    required this.errorMessage,
    required this.action,
  });

  final String stage;
  final String errorMessage;
  final _StartupAction action;
}

class _StartupBatch {
  const _StartupBatch({
    required this.stage,
    required this.tasks,
    this.dependsOn = const [],
  });

  final String stage;
  final List<_StartupTask> tasks;
  final List<String> dependsOn;
}

class AppStartupCoordinator {
  AppStartupCoordinator._();

  static Future<void> initialize() async {
    startupPerformanceMonitor.reset();
    startupPerformanceMonitor.start('total_app_startup');

    WidgetsFlutterBinding.ensureInitialized();
    startupPerformanceMonitor.end('widget_binding');

    try {
      await startupPerformanceMonitor.trackAsync(
        'app_config_init',
        () async {
          AppConfig.preload();
          await Future.wait([
            AppConfig.waitUntilReady(
              timeout: const Duration(milliseconds: 400),
            ),
            AppTheme.init(),
          ]);
        },
      );

      await startupPerformanceMonitor.trackAsync(
        'critical_services_init',
        () async {
          if (AppLog.enableStartupLogs) {
            debugPrint('Check: Critical services skipped (lazy loading)');
          }
        },
      );

      await startupPerformanceMonitor.trackAsync(
        'other_services_init',
        () async {
          _schedulePostFrameInitialization();
        },
      );

      if (!kIsWeb) {
        await startupPerformanceMonitor.trackAsync(
          'platform_specific_init',
          () async {
            _scheduleBatches(_platformBatches);
          },
        );
      }

      startupPerformanceMonitor.end('total_app_startup');
      if (AppLog.enableStartupLogs) {
        AppLog.instance.putStartup(
          '应用初始化完成，总耗时: ${startupPerformanceMonitor.getDuration('total_app_startup')?.inMilliseconds ?? 0}ms',
        );
        startupPerformanceMonitor.printAllDurations();
      }
    } catch (e) {
      AppLog.instance.put('应用初始化过程中发生未预期的错误', error: e);
    }
  }

  static final List<_StartupTask> _postFrameTasks = [
    _StartupTask(
      stage: 'post_frame.local_config_service',
      errorMessage: '后台初始化本地配置服务失败',
      action: () async {
        await readService(AppServices.localConfigService).init();
        readService(AppServices.localConfigService)
            .initVersionCode()
            .catchError((e) {
          AppLog.instance.putServiceInit('初始化应用版本号失败', error: e);
        });
      },
    ),
    _StartupTask(
      stage: 'post_frame.read_config_service',
      errorMessage: '后台初始化阅读配置服务失败',
      action: () async {
        await readService(AppServices.readConfigService).initConfigs();
      },
    ),
    _StartupTask(
      stage: 'post_frame.book_group_service',
      errorMessage: '后台初始化书籍分组服务失败',
      action: () async {
        await readService(AppServices.bookGroupService).init();
        unawaited(
          Future.microtask(() async {
            try {
              await readService(AppServices.bookGroupService)
                  .initDefaultGroups();
            } catch (e) {
              AppLog.instance.putServiceInit('初始化默认分组失败', error: e);
            }
          }),
        );
      },
    ),
    _StartupTask(
      stage: 'post_frame.source_config_service',
      errorMessage: '后台初始化书源配置服务失败',
      action: () async {
        await readService(AppServices.sourceConfigService).init();
      },
    ),
    _StartupTask(
      stage: 'post_frame.non_critical.crash_log_service',
      errorMessage: '后台初始化崩溃日志服务失败',
      action: () async {
        await readService(AppServices.crashLogService).init();
      },
    ),
    _StartupTask(
      stage: 'post_frame.non_critical.audio_play_service',
      errorMessage: '后台初始化音频播放服务失败',
      action: () async {
        await readService(AppServices.audioPlayService).init();
      },
    ),
    _StartupTask(
      stage: 'background.default_data_up_version',
      errorMessage: '版本升级检查失败',
      action: () async {
        await DefaultData.instance.upVersion();
      },
    ),
  ];

  static final List<_StartupBatch> _postFrameBatches = [
    _StartupBatch(
      stage: 'post_frame.batch.config_services',
      tasks: [
        _postFrameTasks[0],
        _postFrameTasks[1],
      ],
    ),
    _StartupBatch(
      stage: 'post_frame.batch.data_services',
      dependsOn: ['post_frame.batch.config_services'],
      tasks: [
        _postFrameTasks[2],
        _postFrameTasks[3],
      ],
    ),
    _StartupBatch(
      stage: 'post_frame.batch.non_critical_services',
      dependsOn: ['post_frame.batch.data_services'],
      tasks: [
        _postFrameTasks[4],
        _postFrameTasks[5],
      ],
    ),
    _StartupBatch(
      stage: 'post_frame.batch.default_data',
      dependsOn: ['post_frame.batch.non_critical_services'],
      tasks: [
        _postFrameTasks[6],
      ],
    ),
  ];

  static final List<_StartupBatch> _platformBatches = [
    _StartupBatch(
      stage: 'platform.batch.base',
      tasks: [
        _StartupTask(
          stage: 'platform.network_changed_listener',
          errorMessage: '后台初始化网络变化监听器失败',
          action: () async {
            await NetworkChangedListener.instance.init();
          },
        ),
        _StartupTask(
          stage: 'platform.time_battery_listener',
          errorMessage: '后台初始化时间和电池监听器失败',
          action: () async {
            await TimeBatteryListener.instance.init();
          },
        ),
        _StartupTask(
          stage: 'platform.media_button_handler',
          errorMessage: '后台初始化媒体按钮处理器失败',
          action: () async {
            await MediaButtonHandler.instance.init();
          },
        ),
        _StartupTask(
          stage: 'platform.url_scheme_service',
          errorMessage: '后台初始化URL Scheme服务失败',
          action: () async {
            await readService(AppServices.urlSchemeService).init();
          },
        ),
        _StartupTask(
          stage: 'platform.notification_service',
          errorMessage: '后台初始化通知服务失败',
          action: () async {
            await readService(AppServices.notificationService).init();
          },
        ),
        _StartupTask(
          stage: 'platform.shortcut_service',
          errorMessage: '后台初始化快捷方式服务失败',
          action: () async {
            await readService(AppServices.shortcutService).buildShortcuts();
          },
        ),
      ],
    ),
  ];

  static final List<_StartupBatch> _androidOnlyBatches = [
    _StartupBatch(
      stage: 'platform.batch.android_channels',
      tasks: [
        _StartupTask(
          stage: 'platform.share_receiver_channel',
          errorMessage: '后台初始化分享接收平台通道失败',
          action: () async {
            await ShareReceiverChannel.init();
          },
        ),
        _StartupTask(
          stage: 'platform.file_receiver_channel',
          errorMessage: '后台初始化文件接收平台通道失败',
          action: () async {
            await FileReceiverChannel.instance.init();
          },
        ),
      ],
    ),
  ];

  static void _schedulePostFrameInitialization() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleBatches(_postFrameBatches);
    });
  }

  static void _scheduleBatches(List<_StartupBatch> batches) {
    final batchFutures = <String, Future<void>>{};

    for (final batch in batches) {
      _registerDetachedBatch(batch, batchFutures);
    }

    if (!kIsWeb && Platform.isAndroid && identical(batches, _platformBatches)) {
      for (final batch in _androidOnlyBatches) {
        _registerDetachedBatch(batch, batchFutures);
      }
    }
  }

  static void _registerDetachedBatch(
    _StartupBatch batch,
    Map<String, Future<void>> batchFutures,
  ) {
    batchFutures[batch.stage] = Future.microtask(() async {
      await _waitForBatchDependencies(batch, batchFutures);
      await startupPerformanceMonitor.trackAsync(batch.stage, () async {
        await Future.wait(batch.tasks.map(_runTaskSafely));
      });
    });
  }

  static Future<void> _waitForBatchDependencies(
    _StartupBatch batch,
    Map<String, Future<void>> batchFutures,
  ) async {
    if (batch.dependsOn.isEmpty) {
      return;
    }

    await Future.wait(
      batch.dependsOn.map((dependencyStage) async {
        final dependencyFuture = batchFutures[dependencyStage];
        if (dependencyFuture == null) {
          AppLog.instance.putStartup(
            '启动批次 ${batch.stage} 缺少依赖: $dependencyStage',
          );
          return;
        }
        await dependencyFuture;
      }),
    );
  }

  static Future<void> _runTaskSafely(_StartupTask task) async {
    await startupPerformanceMonitor.trackAsync(task.stage, () async {
      try {
        await task.action();
      } catch (e) {
        AppLog.instance.putServiceInit(task.errorMessage, error: e);
      }
    });
  }
}
