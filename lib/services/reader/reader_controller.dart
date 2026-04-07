import 'dart:async';
import 'package:flutter/material.dart';
import 'models/page_range.dart';
import 'pagination_service.dart';
import 'paginator.dart';
import 'pagination_cache.dart';
import 'reading_position_manager.dart';

typedef PaginationExecutor = Future<List<PageRange>> Function(
  String content,
  ReadingConfig config,
);

/// 阅读控制器 (整合分页、缓存、位置管理)
///
/// 这是一个高级控制器,集成了Gemini文档推荐的所有功能:
/// 1. 基于TextPainter的精确分页算法
/// 2. LRU缓存机制(当前章+相邻章)
/// 3. 字符偏移量的阅读位置保持
/// 4. 后台预读相邻章节
/// 5. 配置变化时自动重新分页
class ReaderController extends ValueNotifier<PaginationState> {
  static const int isolateThreshold = 50000;

  /// 当前章节URL
  String? _currentChapterUrl;

  /// 分页状态
  PaginationState get state => value;

  /// 阅读配置
  ReadingConfig _config;
  ReadingConfig get config => _config;

  /// 缓存管理器
  final PaginationCache _cache = PaginationCache();

  /// 字符偏移量(用于位置保持)
  int _charOffset = 0;

  /// 是否启用缓存
  final bool enableCache;

  /// 是否启用预读
  final bool enablePreload;

  final PaginationExecutor _paginationExecutor;

  ReaderController({
    required ReadingConfig config,
    this.enableCache = true,
    this.enablePreload = true,
    PaginationExecutor? paginationExecutor,
  })  : _config = config,
        _paginationExecutor = paginationExecutor ??
            ((content, cfg) => PaginationService.computePages(
                  content: content,
                  config: cfg,
                )),
        super(const PaginationState());

  /// 加载章节并分页
  ///
  /// [chapterUrl] 章节URL
  /// [content] 章节内容
  /// [charOffset] 阅读位置(字符偏移量,用于恢复位置)
  /// [onSavePosition] 保存阅读位置的回调
  Future<void> loadChapter({
    required String chapterUrl,
    required String content,
    int charOffset = 0,
    Future<void> Function(String chapterUrl, int offset)? onSavePosition,
  }) async {
    _currentChapterUrl = chapterUrl;
    _charOffset = charOffset;

    // 设置加载状态
    value = state.copyWith(
      content: content,
      isPaginating: true,
      error: null,
    );

    try {
      // 尝试从缓存获取
      List<PageRange>? pages;

      if (enableCache) {
        pages = _cache.get(
          chapterUrl: chapterUrl,
          maxWidth: _config.visibleWidth,
          maxHeight: _config.visibleHeight,
          fontSize: _config.fontSize,
          lineHeight: _config.lineHeight,
          letterSpacing: _config.letterSpacing,
          fontWeight: _config.fontWeight,
          fontFamily: _config.fontFamily,
        );
      }

      // 如果缓存未命中,执行分页
      if (pages == null) {
        pages = await _paginateContent(content);

        // 存入缓存
        if (enableCache && pages.isNotEmpty) {
          _cache.put(
            chapterUrl: chapterUrl,
            pages: pages,
            maxWidth: _config.visibleWidth,
            maxHeight: _config.visibleHeight,
            fontSize: _config.fontSize,
            lineHeight: _config.lineHeight,
            letterSpacing: _config.letterSpacing,
            fontWeight: _config.fontWeight,
            fontFamily: _config.fontFamily,
          );
        }
      }

      // 恢复阅读位置
      final currentPage = ReadingPositionManager.restorePosition(
        chapterUrl: chapterUrl,
        charOffset: charOffset,
        pages: pages,
      );

      // 更新状态
      value = state.copyWith(
        pages: pages,
        currentPage: currentPage,
        isPaginating: false,
      );

      debugPrint('章节加载完成: $chapterUrl, 总页数=${pages.length}, 当前页=$currentPage');
    } catch (e) {
      value = state.copyWith(
        isPaginating: false,
        error: '分页失败: $e',
      );
      debugPrint('分页错误: $e');
    }
  }

  /// 执行分页(在后台执行)
  Future<List<PageRange>> _paginateContent(String content) async {
    if (content.length > isolateThreshold) {
      return _paginationExecutor(content, _config);
    }

    return Paginator.paginate(
      content: content,
      maxWidth: _config.visibleWidth,
      maxHeight: _config.visibleHeight,
      style: _config.textStyle,
    );
  }

  /// 跳转到指定页
  void goToPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= state.totalPages) {
      debugPrint('无效的页码: $pageIndex');
      return;
    }

    value = state.copyWith(currentPage: pageIndex);

    // 保存阅读位置
    _saveCurrentPosition();
  }

  /// 下一页
  void nextPage() {
    if (state.currentPage < state.totalPages - 1) {
      goToPage(state.currentPage + 1);
    }
  }

  /// 上一页
  void previousPage() {
    if (state.currentPage > 0) {
      goToPage(state.currentPage - 1);
    }
  }

  /// 是否可以翻到下一页
  bool get canGoNext => state.currentPage < state.totalPages - 1;

  /// 是否可以翻到上一页
  bool get canGoPrevious => state.currentPage > 0;

  /// 更新阅读配置
  ///
  /// **重要：配置变化时会自动重新分页并保持阅读位置**
  Future<void> updateConfig(ReadingConfig newConfig) async {
    if (_config == newConfig) return;

    final oldConfig = _config;
    _config = newConfig;

    // 检查是否需要重新分页
    final needRepaginate = oldConfig.fontSize != newConfig.fontSize ||
        oldConfig.lineHeight != newConfig.lineHeight ||
        oldConfig.letterSpacing != newConfig.letterSpacing ||
        oldConfig.fontWeight != newConfig.fontWeight ||
        oldConfig.fontFamily != newConfig.fontFamily ||
        oldConfig.maxWidth != newConfig.maxWidth ||
        oldConfig.maxHeight != newConfig.maxHeight;

    if (needRepaginate &&
        _currentChapterUrl != null &&
        state.content.isNotEmpty) {
      debugPrint('配置变化，重新分页');

      // 记录当前字符偏移量
      if (state.pages.isNotEmpty && state.currentPage < state.pages.length) {
        _charOffset = state.pages[state.currentPage].start;
      }

      // 重新加载章节(会自动恢复位置)
      await loadChapter(
        chapterUrl: _currentChapterUrl!,
        content: state.content,
        charOffset: _charOffset,
      );
    } else {
      notifyListeners();
    }
  }

  /// 保存当前阅读位置
  Future<void> _saveCurrentPosition() async {
    if (_currentChapterUrl == null || state.pages.isEmpty) return;
    if (state.currentPage < 0 || state.currentPage >= state.pages.length) {
      return;
    }

    // 更新字符偏移量
    _charOffset = state.pages[state.currentPage].start;

    // 这里可以保存到数据库
    debugPrint('阅读位置: $_currentChapterUrl, 字符偏移=$_charOffset');
  }

  /// 获取当前页内容
  String? getCurrentPageContent() {
    if (state.pages.isEmpty || state.currentPage >= state.pages.length) {
      return null;
    }

    return state.pages[state.currentPage].getContent(state.content);
  }

  /// 获取阅读进度(0.0-1.0)
  double get progress {
    if (state.content.isEmpty) return 0.0;

    return ReadingPositionManager.getProgress(
      currentPage: state.currentPage,
      pages: state.pages,
      totalChars: state.content.length,
    );
  }

  /// 根据进度跳转
  void seekToProgress(double progress) {
    final pageIndex = ReadingPositionManager.getPageByProgress(
      progress: progress.clamp(0.0, 1.0),
      pages: state.pages,
      totalChars: state.content.length,
    );

    goToPage(pageIndex);
  }

  /// 预读相邻章节
  Future<void> preloadAdjacentChapters({
    String? prevChapterUrl,
    String? nextChapterUrl,
    required Future<String?> Function(String url) getContent,
  }) async {
    if (!enablePreload || !enableCache) return;

    await _cache.preloadAdjacentChapters(
      currentChapterUrl: _currentChapterUrl ?? '',
      prevChapterUrl: prevChapterUrl,
      nextChapterUrl: nextChapterUrl,
      getContent: getContent,
      paginate: _paginateContent,
      maxWidth: _config.visibleWidth,
      maxHeight: _config.visibleHeight,
      fontSize: _config.fontSize,
      lineHeight: _config.lineHeight,
      letterSpacing: _config.letterSpacing,
      fontWeight: _config.fontWeight,
      fontFamily: _config.fontFamily,
    );
  }

  /// 清空缓存
  void clearCache() {
    _cache.clear();
  }

  /// 获取缓存统计
  Map<String, dynamic> getCacheStats() {
    return _cache.getStats();
  }
}
