import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models/page_range.dart';
import 'paginator.dart';
import 'reading_position_manager.dart';

/// 分页服务 (参考Gemini文档: 分页引擎 Paginator.md)
///
/// 使用 Flutter 的 `compute` 在后台 Isolate 分页，避免长章节阻塞 UI。
class PaginationService {
  /// 在 Isolate 中执行分页计算
  static Future<List<PageRange>> computePages({
    required String content,
    required ReadingConfig config,
  }) async {
    return compute(
      _internalPaginate,
      _PaginationParams(
        content: content,
        config: _PaginationConfigPayload.fromReadingConfig(config),
      ).toMap(),
    );
  }

  /// 批量分页(多章节)
  static Future<List<List<PageRange>>> computeBatchPages({
    required List<String> chapters,
    required ReadingConfig config,
  }) async {
    return compute(
      _internalBatchPaginate,
      _BatchPaginationParams(
        chapters: chapters,
        config: _PaginationConfigPayload.fromReadingConfig(config),
      ).toMap(),
    );
  }

  /// 增量分页(渐进式渲染)
  static Future<List<PageRange>> computePagesIncremental({
    required String content,
    required ReadingConfig config,
    int initialPageCount = 5,
    void Function(List<PageRange> pages)? onProgress,
  }) async {
    final allPages = <PageRange>[];
    final existingPages = <PageRange>[];

    final initialPages = await compute(
      _internalPaginateIncremental,
      _IncrementalParams(
        content: content,
        config: _PaginationConfigPayload.fromReadingConfig(config),
        existingPages:
            existingPages.map((page) => _PageRangePayload.fromPage(page)).toList(),
        maxPages: initialPageCount,
      ).toMap(),
    );

    allPages.addAll(initialPages);
    existingPages.addAll(initialPages);
    onProgress?.call(List<PageRange>.from(allPages));

    while (
        existingPages.isNotEmpty && existingPages.last.end < content.length) {
      final morePages = await compute(
        _internalPaginateIncremental,
        _IncrementalParams(
          content: content,
          config: _PaginationConfigPayload.fromReadingConfig(config),
          existingPages: existingPages
              .map((page) => _PageRangePayload.fromPage(page))
              .toList(),
          maxPages: 10,
        ).toMap(),
      );

      if (morePages.isEmpty) {
        break;
      }

      allPages.addAll(morePages);
      existingPages.addAll(morePages);
      onProgress?.call(List<PageRange>.from(allPages));
    }

    return allPages;
  }

  static List<PageRange> _internalPaginate(Map<String, dynamic> params) {
    final payload = _PaginationParams.fromMap(params);
    return Paginator.paginate(
      content: payload.content,
      maxWidth: payload.config.renderWidth,
      maxHeight: payload.config.renderHeight,
      style: payload.config.textStyle,
    );
  }

  static List<List<PageRange>> _internalBatchPaginate(
    Map<String, dynamic> params,
  ) {
    final payload = _BatchPaginationParams.fromMap(params);
    return payload.chapters
        .map(
          (content) => Paginator.paginate(
            content: content,
            maxWidth: payload.config.renderWidth,
            maxHeight: payload.config.renderHeight,
            style: payload.config.textStyle,
          ),
        )
        .toList();
  }

  static List<PageRange> _internalPaginateIncremental(
    Map<String, dynamic> params,
  ) {
    final payload = _IncrementalParams.fromMap(params);
    return Paginator.paginateIncremental(
      existingPages: payload.existingPages.map((page) => page.page).toList(),
      content: payload.content,
      maxWidth: payload.config.renderWidth,
      maxHeight: payload.config.renderHeight,
      style: payload.config.textStyle,
      maxPages: payload.maxPages,
    );
  }

  /// 内容清洗(段落缩进)
  static String cleanContent(String content) {
    return content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => '\u3000\u3000$line')
        .join('\n\n');
  }
}

class _PaginationParams {
  final String content;
  final _PaginationConfigPayload config;

  const _PaginationParams({
    required this.content,
    required this.config,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'config': config.toMap(),
    };
  }

  factory _PaginationParams.fromMap(Map<String, dynamic> map) {
    return _PaginationParams(
      content: map['content'] as String,
      config: _PaginationConfigPayload.fromMap(
        Map<String, dynamic>.from(map['config'] as Map),
      ),
    );
  }
}

class _BatchPaginationParams {
  final List<String> chapters;
  final _PaginationConfigPayload config;

  const _BatchPaginationParams({
    required this.chapters,
    required this.config,
  });

  Map<String, dynamic> toMap() {
    return {
      'chapters': chapters,
      'config': config.toMap(),
    };
  }

  factory _BatchPaginationParams.fromMap(Map<String, dynamic> map) {
    return _BatchPaginationParams(
      chapters: List<String>.from(map['chapters'] as List),
      config: _PaginationConfigPayload.fromMap(
        Map<String, dynamic>.from(map['config'] as Map),
      ),
    );
  }
}

class _IncrementalParams {
  final String content;
  final _PaginationConfigPayload config;
  final List<_PageRangePayload> existingPages;
  final int maxPages;

  const _IncrementalParams({
    required this.content,
    required this.config,
    required this.existingPages,
    required this.maxPages,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'config': config.toMap(),
      'existingPages': existingPages.map((page) => page.toMap()).toList(),
      'maxPages': maxPages,
    };
  }

  factory _IncrementalParams.fromMap(Map<String, dynamic> map) {
    return _IncrementalParams(
      content: map['content'] as String,
      config: _PaginationConfigPayload.fromMap(
        Map<String, dynamic>.from(map['config'] as Map),
      ),
      existingPages: (map['existingPages'] as List)
          .map(
            (page) => _PageRangePayload.fromMap(
              Map<String, dynamic>.from(page as Map),
            ),
          )
          .toList(),
      maxPages: map['maxPages'] as int,
    );
  }
}

class _PaginationConfigPayload {
  final double maxWidth;
  final double maxHeight;
  final double fontSize;
  final double lineHeight;
  final String? fontFamily;
  final int fontWeightIndex;
  final double letterSpacing;
  final double paragraphSpacing;
  final double paddingLeft;
  final double paddingTop;
  final double paddingRight;
  final double paddingBottom;
  final int backgroundColorValue;
  final int textColorValue;
  final String themeName;
  final bool clickToFlip;
  final bool volumeKeyFlip;

  const _PaginationConfigPayload({
    required this.maxWidth,
    required this.maxHeight,
    required this.fontSize,
    required this.lineHeight,
    required this.fontFamily,
    required this.fontWeightIndex,
    required this.letterSpacing,
    required this.paragraphSpacing,
    required this.paddingLeft,
    required this.paddingTop,
    required this.paddingRight,
    required this.paddingBottom,
    required this.backgroundColorValue,
    required this.textColorValue,
    required this.themeName,
    required this.clickToFlip,
    required this.volumeKeyFlip,
  });

  factory _PaginationConfigPayload.fromReadingConfig(ReadingConfig config) {
    return _PaginationConfigPayload(
      maxWidth: config.maxWidth,
      maxHeight: config.maxHeight,
      fontSize: config.fontSize,
      lineHeight: config.lineHeight,
      fontFamily: config.fontFamily,
      fontWeightIndex: config.fontWeight.index,
      letterSpacing: config.letterSpacing,
      paragraphSpacing: config.paragraphSpacing,
      paddingLeft: config.padding.left,
      paddingTop: config.padding.top,
      paddingRight: config.padding.right,
      paddingBottom: config.padding.bottom,
      backgroundColorValue: config.backgroundColor.toARGB32(),
      textColorValue: config.textColor.toARGB32(),
      themeName: config.themeName,
      clickToFlip: config.clickToFlip,
      volumeKeyFlip: config.volumeKeyFlip,
    );
  }

  factory _PaginationConfigPayload.fromMap(Map<String, dynamic> map) {
    return _PaginationConfigPayload(
      maxWidth: (map['maxWidth'] as num).toDouble(),
      maxHeight: (map['maxHeight'] as num).toDouble(),
      fontSize: (map['fontSize'] as num).toDouble(),
      lineHeight: (map['lineHeight'] as num).toDouble(),
      fontFamily: map['fontFamily'] as String?,
      fontWeightIndex: map['fontWeightIndex'] as int,
      letterSpacing: (map['letterSpacing'] as num).toDouble(),
      paragraphSpacing: (map['paragraphSpacing'] as num).toDouble(),
      paddingLeft: (map['paddingLeft'] as num).toDouble(),
      paddingTop: (map['paddingTop'] as num).toDouble(),
      paddingRight: (map['paddingRight'] as num).toDouble(),
      paddingBottom: (map['paddingBottom'] as num).toDouble(),
      backgroundColorValue: map['backgroundColorValue'] as int,
      textColorValue: map['textColorValue'] as int,
      themeName: map['themeName'] as String,
      clickToFlip: map['clickToFlip'] as bool,
      volumeKeyFlip: map['volumeKeyFlip'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'fontFamily': fontFamily,
      'fontWeightIndex': fontWeightIndex,
      'letterSpacing': letterSpacing,
      'paragraphSpacing': paragraphSpacing,
      'paddingLeft': paddingLeft,
      'paddingTop': paddingTop,
      'paddingRight': paddingRight,
      'paddingBottom': paddingBottom,
      'backgroundColorValue': backgroundColorValue,
      'textColorValue': textColorValue,
      'themeName': themeName,
      'clickToFlip': clickToFlip,
      'volumeKeyFlip': volumeKeyFlip,
    };
  }

  ReadingConfig get config => ReadingConfig(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        fontSize: fontSize,
        lineHeight: lineHeight,
        fontFamily: fontFamily,
        fontWeight: FontWeight.values[fontWeightIndex],
        letterSpacing: letterSpacing,
        paragraphSpacing: paragraphSpacing,
        padding: EdgeInsets.fromLTRB(
          paddingLeft,
          paddingTop,
          paddingRight,
          paddingBottom,
        ),
        backgroundColor: Color(backgroundColorValue),
        textColor: Color(textColorValue),
        themeName: themeName,
        clickToFlip: clickToFlip,
        volumeKeyFlip: volumeKeyFlip,
      );

  double get renderWidth => config.renderWidth;
  double get renderHeight => config.renderHeight;
  TextStyle get textStyle => config.textStyle;
}

class _PageRangePayload {
  final int start;
  final int end;
  final int pageIndex;
  final double height;

  const _PageRangePayload({
    required this.start,
    required this.end,
    required this.pageIndex,
    required this.height,
  });

  factory _PageRangePayload.fromPage(PageRange page) {
    return _PageRangePayload(
      start: page.start,
      end: page.end,
      pageIndex: page.pageIndex,
      height: page.height,
    );
  }

  factory _PageRangePayload.fromMap(Map<String, dynamic> map) {
    return _PageRangePayload(
      start: map['start'] as int,
      end: map['end'] as int,
      pageIndex: map['pageIndex'] as int,
      height: (map['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start': start,
      'end': end,
      'pageIndex': pageIndex,
      'height': height,
    };
  }

  PageRange get page => PageRange(
        start: start,
        end: end,
        pageIndex: pageIndex,
        height: height,
      );
}
