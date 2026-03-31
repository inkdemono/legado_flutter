import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'config/theme_config.dart';
import 'config/app_config.dart';
import 'core/constants/prefer_key.dart';
import 'ui/pages/welcome/welcome_page.dart';
import 'ui/pages/search/search_page.dart';
import 'services/receiver/media_button_handler.dart';
import 'utils/localization_helper.dart';
import 'providers/main_page_index_provider.dart';
import 'utils/app_log.dart';
import 'services/media/audio_play_service.dart';
import 'ui/pages/audio/audio_play_page.dart';
import 'ui/pages/book_source/book_source_manage_page.dart';
import 'ui/dialogs/add_to_bookshelf_dialog.dart';
import 'ui/dialogs/unsupported_file_dialog.dart';
import 'package:open_filex/open_filex.dart';
import 'ui/pages/main/main_page.dart';
import 'dart:async';

class LegadoApp extends ConsumerStatefulWidget {
  const LegadoApp({super.key});

  @override
  ConsumerState<LegadoApp> createState() => _LegadoAppState();
}

class _LegadoAppState extends ConsumerState<LegadoApp>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingNavigation();
    });
    // 注意：StartupFlowService.run() 移到 MainPage 中调用
    // 因为这里 context 在 MaterialApp 外部，无法显示 Material 对话框
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkPendingNavigation();
    }
  }

  Future<void> _checkPendingNavigation() async {
    try {
      final pendingNav = AppConfig.getString('pending_navigation');
      if (pendingNav.isEmpty) {
        return;
      }

      // 清除pending_navigation，避免重复处理
      await AppConfig.setString('pending_navigation', '');

      if (!mounted) return;

      final navigator = Navigator.of(context);

      switch (pendingNav) {
        case 'search':
          final searchText = AppConfig.getString('pending_search_text');
          await AppConfig.setString('pending_search_text', '');
          navigator.push(
            MaterialPageRoute(
              builder: (context) => SearchPage(
                initialKeyword: searchText.isNotEmpty ? searchText : null,
              ),
            ),
          );
          break;

        case 'bookshelf':
          // 导航到书架（已经是主页面，不需要额外操作）
          // 可以通过Provider切换到书架tab
          ref.read(mainPageIndexProvider.notifier).switchToBookshelf();
          break;

        case 'read':
          // 阅读页面导航需要书籍URL，暂时不处理
          break;

        case 'readAloud':
          // 启动朗读功能（通过媒体按钮处理器）
          MediaButtonHandler.instance.startReadAloud(isMediaKey: false);
          break;

        case 'web_service':
          // 导航到Web服务页面（我的页面中的Web服务设置）
          ref.read(mainPageIndexProvider.notifier).switchToMy();
          // TODO: 可以进一步导航到Web服务设置页面
          break;

        case 'book_source':
          // 导航到书源管理页面
          ref.read(mainPageIndexProvider.notifier).switchToMy();
          // 延迟导航，确保页面已切换
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            navigator.push(
              MaterialPageRoute(
                builder: (context) => const BookSourceManagePage(),
              ),
            );
          }
          break;

        case 'download':
          // 下载完成，可以打开文件
          final downloadPath = AppConfig.getString('pending_download_path');
          await AppConfig.setString('pending_download_path', '');
          if (downloadPath.isNotEmpty) {
            try {
              // 使用 open_filex 打开文件
              final result = await OpenFilex.open(downloadPath);
              if (result.type != ResultType.done) {
                AppLog.instance.put('无法打开文件: ${result.message}');
              } else {
                AppLog.instance.put('打开下载文件: $downloadPath');
              }
            } catch (e) {
              AppLog.instance.put('打开文件失败: $downloadPath', error: e);
            }
          }
          break;

        case 'audio_play':
          // 导航到音频播放页面
          try {
            final audioService = AudioPlayService.instance;
            final currentBook = audioService.currentBook;
            if (currentBook != null) {
              navigator.push(
                MaterialPageRoute(
                  builder: (context) => AudioPlayPage(book: currentBook),
                ),
              );
            } else {
              AppLog.instance.put('没有正在播放的音频书籍');
            }
          } catch (e) {
            AppLog.instance.put('导航到音频播放页面失败', error: e);
          }
          break;

        case 'addToBookshelf':
          // 显示添加到书架对话框
          final bookUrl = AppConfig.getString('pending_book_url');
          await AppConfig.setString('pending_book_url', '');
          if (bookUrl.isNotEmpty) {
            try {
              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AddToBookshelfDialog(
                  bookUrl: bookUrl,
                  finishOnDismiss: false,
                ),
              );
            } catch (e) {
              AppLog.instance.put('显示添加到书架对话框失败', error: e);
            }
          }
          break;

        case 'unsupported_file':
          // 显示不支持的文件类型对话框
          final fileName = AppConfig.getString('pending_unsupported_file_name');
          final fileExtension =
              AppConfig.getString('pending_unsupported_file_extension');
          await AppConfig.setString('pending_unsupported_file_name', '');
          await AppConfig.setString('pending_unsupported_file_extension', '');
          if (fileName.isNotEmpty) {
            try {
              if (!mounted) return;
              await UnsupportedFileDialog.show(
                context,
                fileName,
                fileExtension: fileExtension.isNotEmpty ? fileExtension : null,
              );
            } catch (e) {
              AppLog.instance.put('显示不支持文件类型对话框失败', error: e);
            }
          }
          break;
      }
    } catch (e) {
      // 忽略错误
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = ref.watch(appThemeProvider);
    final tdTheme = ref.watch(tdThemeProvider);
    final localizationHelper = LocalizationHelper.instance;
    final customWelcome =
        AppConfig.getBool(PreferKey.customWelcome, defaultValue: false);
    final defaultToRead =
        AppConfig.getBool(PreferKey.defaultToRead, defaultValue: false);
    final initialHome =
        (customWelcome || defaultToRead) ? const WelcomePage() : const MainPage();

    return TDTheme(
      data: tdTheme,
      child: MaterialApp(
        title: 'Legado',
        debugShowCheckedModeBanner: false,
        theme: theme.lightTheme,
        darkTheme: theme.darkTheme,
        themeMode: themeMode,
        locale: localizationHelper.getCurrentLocale(),
        supportedLocales: LocalizationHelper.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          // 应用字体缩放
          final mediaQuery = MediaQuery.of(context);
          final textScaleFactor = localizationHelper.getTextScaleFactor();
          return MediaQuery(
            data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(textScaleFactor)),
            child: child!,
          );
        },
        home: initialHome,
      ),
    );
  }
}
