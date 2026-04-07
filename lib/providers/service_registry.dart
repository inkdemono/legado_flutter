import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:legado_flutter/services/about/heap_dump_service.dart';
import 'package:legado_flutter/services/book/book_service.dart';
import 'package:legado_flutter/services/book/local_book_service.dart';
import 'package:legado_flutter/services/book/remote_book_service.dart';
import 'package:legado_flutter/services/book_group_service.dart';
import 'package:legado_flutter/services/bookmark_service.dart';
import 'package:legado_flutter/services/cover_search_service.dart';
import 'package:legado_flutter/services/crash_log_service.dart';
import 'package:legado_flutter/services/cookie_service.dart';
import 'package:legado_flutter/services/dict_rule_service.dart';
import 'package:legado_flutter/services/download_service.dart';
import 'package:legado_flutter/services/explore_service.dart';
import 'package:legado_flutter/services/file_manage_service.dart';
import 'package:legado_flutter/services/http_tts_service.dart';
import 'package:legado_flutter/services/keyboard_assist_service.dart';
import 'package:legado_flutter/services/local_config_service.dart';
import 'package:legado_flutter/services/media/audio_play_service.dart';
import 'package:legado_flutter/services/media/manga_service.dart';
import 'package:legado_flutter/services/media/tts_service.dart';
import 'package:legado_flutter/services/media/music/music_player_service.dart';
import 'package:legado_flutter/services/media/video/video_player_service.dart';
import 'package:legado_flutter/services/network/network_service.dart';
import 'package:legado_flutter/services/network/webview_protocol_handler.dart';
import 'package:legado_flutter/services/notification_service.dart';
import 'package:legado_flutter/services/read_config_service.dart';
import 'package:legado_flutter/services/read_record_service.dart';
import 'package:legado_flutter/services/reader/cache_export_service.dart';
import 'package:legado_flutter/services/reader/cache_service.dart';
import 'package:legado_flutter/services/reader/chapter_content_service.dart';
import 'package:legado_flutter/services/reader/chapter_downloader_service.dart';
import 'package:legado_flutter/services/receiver/share_receiver_service.dart';
import 'package:legado_flutter/services/replace_rule_service.dart';
import 'package:legado_flutter/services/rss/rss_parser_service.dart';
import 'package:legado_flutter/services/rss_read_record_service.dart';
import 'package:legado_flutter/services/rss_service.dart';
import 'package:legado_flutter/services/search_book_service.dart';
import 'package:legado_flutter/services/search_keyword_service.dart';
import 'package:legado_flutter/services/shortcut_service.dart';
import 'package:legado_flutter/services/source/book_source_debug_service.dart';
import 'package:legado_flutter/services/source/book_source_service.dart';
import 'package:legado_flutter/services/source/check_source_service.dart';
import 'package:legado_flutter/services/source/login_info_service.dart';
import 'package:legado_flutter/services/source/source_config_service.dart';
import 'package:legado_flutter/services/storage/backup_service.dart';
import 'package:legado_flutter/services/storage/restore_service.dart';
import 'package:legado_flutter/services/storage/webdav_service.dart';
import 'package:legado_flutter/services/theme_service.dart';
import 'package:legado_flutter/services/txt_toc_rule_service.dart';
import 'package:legado_flutter/services/url_scheme_service.dart';
import 'package:legado_flutter/services/about/log_save_service.dart';

ProviderContainer _appProviderContainer = ProviderContainer();

ProviderContainer get appProviderContainer => _appProviderContainer;

T readService<T>(Object provider) {
  return _appProviderContainer.read(provider as dynamic);
}

@visibleForTesting
void setAppProviderContainerForTesting(ProviderContainer container) {
  _appProviderContainer.dispose();
  _appProviderContainer = container;
}

@visibleForTesting
void resetAppProviderContainer() {
  _appProviderContainer.dispose();
  _appProviderContainer = ProviderContainer();
}

abstract final class AppServices {
  static final audioPlayService = Provider<AudioPlayService>((ref) {
    return AudioPlayService.instance;
  });

  static final backupService = Provider<BackupService>((ref) {
    return BackupService.instance;
  });

  static final bookGroupService = Provider<BookGroupService>((ref) {
    return BookGroupService.instance;
  });

  static final bookService = Provider<IBookService>((ref) {
    return BookService.instance;
  });

  static final bookSourceDebugService = Provider<BookSourceDebugService>((ref) {
    return BookSourceDebugService.instance;
  });

  static final bookSourceService = Provider<IBookSourceService>((ref) {
    return BookSourceService.instance;
  });

  static final bookmarkService = Provider<BookmarkService>((ref) {
    return BookmarkService.instance;
  });

  static final cacheExportService = Provider<CacheExportService>((ref) {
    return CacheExportService.instance;
  });

  static final cacheService = Provider<CacheService>((ref) {
    return CacheService.instance;
  });

  static final chapterContentService = Provider<ChapterContentService>((ref) {
    return ChapterContentService.instance;
  });

  static final chapterDownloaderService =
      Provider<ChapterDownloaderService>((ref) {
    return ChapterDownloaderService.instance;
  });

  static final checkSourceService = Provider<CheckSourceService>((ref) {
    return CheckSourceService.instance;
  });

  static final cookieService = Provider<CookieService>((ref) {
    return CookieService.instance;
  });

  static final coverSearchService = Provider<CoverSearchService>((ref) {
    return CoverSearchService.instance;
  });

  static final crashLogService = Provider<CrashLogService>((ref) {
    return CrashLogService.instance;
  });

  static final dictRuleService = Provider<DictRuleService>((ref) {
    return DictRuleService.instance;
  });

  static final downloadService = Provider<DownloadService>((ref) {
    return DownloadService.instance;
  });

  static final exploreService = Provider<ExploreService>((ref) {
    return ExploreService.instance;
  });

  static final fileManageService = Provider<FileManageService>((ref) {
    return FileManageService.instance;
  });

  static final heapDumpService = Provider<HeapDumpService>((ref) {
    return HeapDumpService.instance;
  });

  static final httpTTSService = Provider<HttpTTSService>((ref) {
    return HttpTTSService.instance;
  });

  static final keyboardAssistService = Provider<KeyboardAssistService>((ref) {
    return KeyboardAssistService.instance;
  });

  static final localBookService = Provider<LocalBookService>((ref) {
    return LocalBookService.instance;
  });

  static final localConfigService = Provider<LocalConfigService>((ref) {
    return LocalConfigService.instance;
  });

  static final logSaveService = Provider<LogSaveService>((ref) {
    return LogSaveService.instance;
  });

  static final loginInfoService = Provider<LoginInfoService>((ref) {
    return LoginInfoService.instance;
  });

  static final mangaService = Provider<MangaService>((ref) {
    return MangaService.instance;
  });

  static final musicPlayerService = Provider<MusicPlayerService>((ref) {
    return MusicPlayerService.instance;
  });

  static final networkService = Provider<INetworkService>((ref) {
    return NetworkService.instance;
  });

  static final notificationService = Provider<NotificationService>((ref) {
    return NotificationService.instance;
  });

  static final readConfigService = Provider<ReadConfigService>((ref) {
    return ReadConfigService.instance;
  });

  static final readRecordService = Provider<ReadRecordService>((ref) {
    return ReadRecordService.instance;
  });

  static final remoteBookService = Provider<RemoteBookService>((ref) {
    return RemoteBookService.instance;
  });

  static final replaceRuleService = Provider<ReplaceRuleService>((ref) {
    return ReplaceRuleService.instance;
  });

  static final restoreService = Provider<RestoreService>((ref) {
    return RestoreService.instance;
  });

  static final rssParserService = Provider<RssParserService>((ref) {
    return RssParserService.instance;
  });

  static final rssReadRecordService = Provider<RssReadRecordService>((ref) {
    return RssReadRecordService.instance;
  });

  static final rssService = Provider<RssService>((ref) {
    return RssService.instance;
  });

  static final searchBookService = Provider<SearchBookService>((ref) {
    return SearchBookService.instance;
  });

  static final searchKeywordService = Provider<SearchKeywordService>((ref) {
    return SearchKeywordService.instance;
  });

  static final shareReceiverService = Provider<ShareReceiverService>((ref) {
    return ShareReceiverService.instance;
  });

  static final shortcutService = Provider<ShortcutService>((ref) {
    return ShortcutService.instance;
  });

  static final sourceConfigService = Provider<SourceConfigService>((ref) {
    return SourceConfigService.instance;
  });

  static final themeService = Provider<ThemeService>((ref) {
    return ThemeService.instance;
  });

  static final ttsService = Provider<TtsService>((ref) {
    return TtsService.instance;
  });

  static final txtTocRuleService = Provider<TxtTocRuleService>((ref) {
    return TxtTocRuleService.instance;
  });

  static final urlSchemeService = Provider<UrlSchemeService>((ref) {
    return UrlSchemeService.instance;
  });

  static final videoPlayerService = Provider<VideoPlayerService>((ref) {
    return VideoPlayerService.instance;
  });

  static final webDavService = Provider<WebDavService>((ref) {
    return WebDavService.instance;
  });

  static final webViewProtocolHandler = Provider<WebViewProtocolHandler>((ref) {
    return WebViewProtocolHandler.instance;
  });
}
