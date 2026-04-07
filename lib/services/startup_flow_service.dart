import 'dart:async';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, visibleForTesting;
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/event/app_events.dart';
import '../config/app_config.dart';
import '../utils/app_log.dart';
import '../data/models/book.dart';
import '../providers/book_provider.dart';
import '../providers/book_update_count_provider.dart';
import '../providers/event_bus_provider.dart';
import '../ui/pages/about/markdown_viewer_page.dart';
import '../ui/pages/about/crash_logs_page.dart';
import '../utils/startup_performance_monitor.dart';

/// 启动流程服务：负责顺序与节奏控制，对应参考项目 MainActivity.onPostCreate() 中的各项检查。
/// 各子流程（隐私协议、本地密码、版本更新、崩溃日志、备份同步、自动刷新目录）按顺序执行。
class StartupFlowService {
  StartupFlowService._();

  /// 执行完整启动流程。需在首帧后调用，[isMounted] 用于在异步步骤间检查 widget 是否仍挂载。
  static Future<void> run(
    BuildContext context,
    WidgetRef ref,
    bool Function() isMounted,
  ) async {
    await startupPerformanceMonitor.trackAsync('startup_flow.total', () async {
      try {
        await readService(AppServices.localConfigService).init();
        if (!isMounted()) return;

        final privacyOk = await startupPerformanceMonitor.trackAsync(
          'startup_flow.privacy_policy',
          () => _checkPrivacyPolicy(context, isMounted),
        );
        if (!privacyOk && isMounted()) {
          AppLog.instance.put('用户拒绝隐私协议');
        }
        if (!isMounted()) return;

        await startupPerformanceMonitor.trackAsync(
          'startup_flow.local_password',
          () => _checkLocalPassword(context, isMounted),
        );
        if (!isMounted()) return;

        await startupPerformanceMonitor.trackAsync(
          'startup_flow.version_update',
          () => _checkVersionUpdate(context, isMounted),
        );
        if (!isMounted()) return;

        await startupPerformanceMonitor.trackAsync(
          'startup_flow.crash_log',
          () => _checkCrashLog(context, isMounted),
        );
        if (!isMounted()) return;

        await startupPerformanceMonitor.trackAsync(
          'startup_flow.backup_sync',
          () => _checkBackupSync(context, isMounted),
        );
        if (!isMounted()) return;

        unawaited(
          () async {
            try {
              if (!isMounted()) return;
              await startupPerformanceMonitor.trackAsync(
                'startup_flow.auto_refresh_books',
                () => _autoRefreshBooks(ref, isMounted),
              );
            } catch (e) {
              AppLog.instance.put('自动更新书籍目录失败', error: e);
            }
          }(),
        );
      } catch (e) {
        AppLog.instance.put('启动初始化失败', error: e);
      }
    });
  }

  /// 参考项目：MainActivity.privacyPolicy()
  static Future<bool> _checkPrivacyPolicy(
    BuildContext context,
    bool Function() isMounted,
  ) async {
    final localConfig = readService(AppServices.localConfigService);
    if (localConfig.privacyPolicyOk) return true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('隐私政策'),
        content: SingleChildScrollView(
          child: FutureBuilder<String>(
            future: rootBundle.loadString('assets/privacyPolicy.md'),
            builder: (ctx, snapshot) {
              if (snapshot.hasData) return Text(snapshot.data!);
              if (snapshot.hasError) {
                return Text('加载隐私政策失败: ${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('拒绝'),
          ),
          TextButton(
            onPressed: () async {
              await localConfig.setPrivacyPolicyOk(true);
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop(true);
            },
            child: const Text('同意'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 参考项目：MainActivity.setLocalPassword()
  static Future<void> _checkLocalPassword(
    BuildContext context,
    bool Function() isMounted,
  ) async {
    // 不再在每次启动时强制弹出本地密码设置。
    // 本地密码改为在相关功能入口中按需由用户手动设置。
    return;
  }

  /// 参考项目：MainActivity.upVersion()
  static Future<void> _checkVersionUpdate(
    BuildContext context,
    bool Function() isMounted,
  ) async {
    final localConfig = readService(AppServices.localConfigService);
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;
    final savedVersionCode = localConfig.versionCode;

    if (currentVersionCode == savedVersionCode) return;
    await localConfig.setVersionCode(currentVersionCode);
    if (!context.mounted) return;
    if (!isMounted()) return;

    if (localConfig.isFirstOpenApp) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const MarkdownViewerPage(
            title: '帮助',
            assetPath: 'assets/web/help/md/appHelp.md',
          ),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MarkdownViewerPage(
          title: '更新日志',
          assetPath: 'assets/updateLog.md',
        ),
      ),
    );
  }

  /// 参考项目：MainActivity.notifyAppCrash()
  static Future<void> _checkCrashLog(
    BuildContext context,
    bool Function() isMounted,
  ) async {
    final localConfig = readService(AppServices.localConfigService);
    if (!localConfig.appCrash || kDebugMode) return;
    await localConfig.setAppCrash(false);
    if (!context.mounted) return;
    if (!isMounted()) return;
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('提示'),
        content: const Text(
          '检测到阅读发生了崩溃，是否打开崩溃日志以便报告问题？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('否'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('是'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (open == true && isMounted()) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CrashLogsPage(),
        ),
      );
    }
  }

  /// 参考项目：MainActivity.backupSync()
  static Future<void> _checkBackupSync(
    BuildContext context,
    bool Function() isMounted,
  ) async {
    if (!AppConfig.getAutoCheckNewBackup()) return;

    try {
      final webDavService = readService(AppServices.webDavService);
      await webDavService.loadConfig();
      if (!webDavService.isConfigured) return;

      final lastBackupFile = await webDavService.getLastBackup();
      if (lastBackupFile == null) return;

      final localConfig = readService(AppServices.localConfigService);
      final lastBackupTime = localConfig.lastBackup;
      final cloudTime = lastBackupFile.lastModified.millisecondsSinceEpoch;

      if (cloudTime - lastBackupTime <= 60 * 1000) return;

      await localConfig.setLastBackup(cloudTime);
      if (!context.mounted) return;
      if (!isMounted()) return;

      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('恢复'),
          content: const Text('检测到WebDAV中有新的备份，是否恢复？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      if (!context.mounted) return;
      if (result == true && isMounted()) {
        // TODO: 导航到备份恢复页面
      }
    } catch (e) {
      AppLog.instance.put('备份同步检查失败', error: e);
    }
  }

  /// 参考项目：MainActivity.onPostCreate() -> viewModel.upAllBookToc()
  static Future<void> _autoRefreshBooks(
    WidgetRef ref,
    bool Function() isMounted,
  ) async {
    if (!AppConfig.getAutoRefresh()) return;
    await _runAutoRefreshWorkflow(
      waitForDependencies: () async {
        await ref.read(bookshelfBooksProvider.future);
      },
      loadBookshelfBooks: () => ref.read(bookServiceProvider).getBookshelfBooks(),
      updateChapterLists: (books) =>
          ref.read(bookServiceProvider).updateChapterLists(books),
      fireCollectionChanged: () {
        ref.read(eventBusProvider).fire(
              const BookCollectionChangedEvent(reason: 'auto_refresh_books'),
            );
      },
      refreshUpdateCount: () =>
          ref.read(bookUpdateCountProvider.notifier).refresh(),
      isMounted: isMounted,
    );
  }

  @visibleForTesting
  static Future<void> runAutoRefreshWorkflowForTesting({
    required Future<void> Function() waitForDependencies,
    required Future<List<Book>> Function() loadBookshelfBooks,
    required Future<Map<String, bool>> Function(List<Book> books)
        updateChapterLists,
    required void Function() fireCollectionChanged,
    required Future<void> Function() refreshUpdateCount,
    required bool Function() isMounted,
  }) {
    return _runAutoRefreshWorkflow(
      waitForDependencies: waitForDependencies,
      loadBookshelfBooks: loadBookshelfBooks,
      updateChapterLists: updateChapterLists,
      fireCollectionChanged: fireCollectionChanged,
      refreshUpdateCount: refreshUpdateCount,
      isMounted: isMounted,
    );
  }

  static Future<void> _runAutoRefreshWorkflow({
    required Future<void> Function() waitForDependencies,
    required Future<List<Book>> Function() loadBookshelfBooks,
    required Future<Map<String, bool>> Function(List<Book> books)
        updateChapterLists,
    required void Function() fireCollectionChanged,
    required Future<void> Function() refreshUpdateCount,
    required bool Function() isMounted,
  }) async {
    if (!isMounted()) return;

    try {
      await waitForDependencies();
      if (!isMounted()) return;

      final allBooks = await loadBookshelfBooks();
      final booksToUpdate =
          allBooks.where((book) => !book.isLocal && book.canUpdate).toList();
      if (booksToUpdate.isEmpty) return;

      final results = await updateChapterLists(booksToUpdate);
      final successCount = results.values.where((v) => v == true).length;
      final failCount = results.length - successCount;
      AppLog.instance.put(
        '自动更新书籍目录完成: 成功 $successCount 本，失败 $failCount 本',
      );

      if (!isMounted()) return;
      fireCollectionChanged();
      await refreshUpdateCount();
    } catch (e) {
      AppLog.instance.put('自动更新书籍目录失败', error: e);
    }
  }
}
