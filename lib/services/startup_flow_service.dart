import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../utils/app_log.dart';
import '../services/local_config_service.dart';
import '../services/storage/webdav_service.dart';
import '../services/book/book_service.dart';
import '../providers/book_update_count_provider.dart';
import '../ui/pages/about/markdown_viewer_page.dart';
import '../ui/pages/about/crash_logs_page.dart';

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
    try {
      final privacyOk = await _checkPrivacyPolicy(context, isMounted);
      if (!privacyOk && isMounted()) {
        AppLog.instance.put('用户拒绝隐私协议');
      }
      if (!isMounted()) return;

      await _checkLocalPassword(context, isMounted);
      if (!isMounted()) return;

      await _checkVersionUpdate(context, isMounted);
      if (!isMounted()) return;

      await _checkCrashLog(context, isMounted);
      if (!isMounted()) return;

      await _checkBackupSync(context, isMounted);
      if (!isMounted()) return;

      unawaited(
        Future.delayed(const Duration(milliseconds: 500), () async {
          try {
            if (!isMounted()) return;
            await _autoRefreshBooks(ref, isMounted);
          } catch (e) {
            AppLog.instance.put('自动更新书籍目录失败', error: e);
          }
        }),
      );
    } catch (e) {
      AppLog.instance.put('启动初始化失败', error: e);
    }
  }

  /// 参考项目：MainActivity.privacyPolicy()
  static Future<bool> _checkPrivacyPolicy(
    BuildContext context,
    bool Function() isMounted,
  ) async {
    final localConfig = LocalConfigService.instance;
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
    final localConfig = LocalConfigService.instance;
    if (localConfig.password != null) return;
    if (!isMounted()) return;

    final controller = TextEditingController();
    try {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('设置本地密码'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'password',
              labelText: '本地密码',
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(''),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      if (result != null) {
        await localConfig.setPassword(result.isEmpty ? null : result);
      }
    } finally {
      controller.dispose();
    }
  }

  /// 参考项目：MainActivity.upVersion()
  static Future<void> _checkVersionUpdate(
    BuildContext context,
    bool Function() isMounted,
  ) async {
    final localConfig = LocalConfigService.instance;
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;
    final savedVersionCode = localConfig.versionCode;

    if (currentVersionCode == savedVersionCode) return;
    await localConfig.setVersionCode(currentVersionCode);
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
    final localConfig = LocalConfigService.instance;
    if (!localConfig.appCrash || kDebugMode) return;
    await localConfig.setAppCrash(false);
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
      final webDavService = WebDavService.instance;
      await webDavService.loadConfig();
      if (!webDavService.isConfigured) return;

      final lastBackupFile = await webDavService.getLastBackup();
      if (lastBackupFile == null) return;

      final localConfig = LocalConfigService.instance;
      final lastBackupTime = localConfig.lastBackup;
      final cloudTime = lastBackupFile.lastModified.millisecondsSinceEpoch;

      if (cloudTime - lastBackupTime <= 60 * 1000) return;

      await localConfig.setLastBackup(cloudTime);
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
    await Future.delayed(const Duration(seconds: 2));
    if (!isMounted()) return;

    try {
      final allBooks = await BookService.instance.getBookshelfBooks();
      final booksToUpdate =
          allBooks.where((book) => !book.isLocal && book.canUpdate).toList();
      if (booksToUpdate.isEmpty) return;

      final results = await BookService.instance.updateChapterLists(booksToUpdate);
      final successCount = results.values.where((v) => v == true).length;
      final failCount = results.length - successCount;
      AppLog.instance.put(
        '自动更新书籍目录完成: 成功 $successCount 本，失败 $failCount 本',
      );

      if (isMounted()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isMounted()) {
            ref.read(bookUpdateCountProvider.notifier).refresh();
          }
        });
      }
    } catch (e) {
      AppLog.instance.put('自动更新书籍目录失败', error: e);
    }
  }
}
