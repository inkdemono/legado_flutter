import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// 高亮文本组件（辅助函数）
Widget _buildHighlightedText({
  required String text,
  required String keyword,
  required TextStyle style,
  required bool isEink,
}) {
  if (keyword.isEmpty) {
    return Text(
      text,
      style: style,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  final keywordLower = keyword.toLowerCase();
  final textLower = text.toLowerCase();
  final index = textLower.indexOf(keywordLower);

  if (index == -1) {
    return Text(
      text,
      style: style,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  final before = text.substring(0, index);
  final match = text.substring(index, index + keyword.length);
  final after = text.substring(index + keyword.length);

  return RichText(
    text: TextSpan(
      style: style,
      children: [
        TextSpan(text: before),
        TextSpan(
          text: match,
          style: style.copyWith(
            backgroundColor: isEink ? Colors.grey.shade400 : Colors.yellow.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(text: after),
      ],
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

/// TDesign 风格的书籍卡片组件
/// 支持 EInk 模式
class TDThemedBookCard extends StatelessWidget {
  /// 书籍数据
  final TDThemedBookData book;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 是否为搜索结果
  final bool isSearchResult;

  /// 高亮关键词
  final String? highlightKeyword;

  /// 封面宽度
  final double coverWidth;

  /// 封面高度
  final double coverHeight;

  /// 外边距
  final EdgeInsets? margin;

  /// 内边距
  final EdgeInsets? padding;

  /// 背景色
  final Color? backgroundColor;

  /// 是否显示阴影
  final bool showShadow;

  /// 是否显示边框
  final bool showBorder;

  /// 圆角
  final BorderRadius? borderRadius;

  const TDThemedBookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onLongPress,
    this.isSearchResult = false,
    this.highlightKeyword,
    this.coverWidth = 86,
    this.coverHeight = 118,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.showShadow = true,
    this.showBorder = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isEink ? Colors.white : tdTheme.colorMap['bgColorContainer']),
        borderRadius: borderRadius ??
            (isEink ? null : BorderRadius.circular(8)),
        border: showBorder || isEink
            ? Border.all(
                color: isEink ? Colors.black12 : (tdTheme.grayColor3),
                width: isEink ? 1 : 0.5,
              )
            : null,
        boxShadow: showShadow && !isEink
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: borderRadius ?? (isEink ? null : BorderRadius.circular(8)),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 封面图片
                if (book.bookUrl != null)
                  Hero(
                    tag: 'book_cover_${book.bookUrl}',
                    child: _buildCover(context, isEink, tdTheme),
                  )
                else
                  _buildCover(context, isEink, tdTheme),
                const SizedBox(width: 14),
                // 书籍信息
                Expanded(child: _buildInfo(context, isEink, tdTheme)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建封面
  Widget _buildCover(BuildContext context, bool isEink, TDThemeData tdTheme) {
    final coverUrl = book.coverUrl;

    // 构建默认封面
    Widget defaultCover = _buildDefaultCover(context, isEink, tdTheme);

    return Container(
      width: coverWidth,
      height: coverHeight,
      decoration: BoxDecoration(
        borderRadius: isEink ? null : BorderRadius.circular(6),
        border: isEink ? Border.all(color: Colors.black12, width: 1) : null,
        boxShadow: !isEink
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: isEink ? BorderRadius.zero : BorderRadius.circular(6),
        child: coverUrl != null && coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => defaultCover,
                errorWidget: (context, url, error) => defaultCover,
              )
            : defaultCover,
      ),
    );
  }

  /// 构建默认封面
  Widget _buildDefaultCover(BuildContext context, bool isEink, TDThemeData tdTheme) {
    final accentColor = isEink ? Colors.black : tdTheme.brandNormalColor;

    // 获取书名和作者
    final displayName = book.name.trim().isNotEmpty ? book.name.trim() : '未知书籍';
    var displayAuthor = book.author.trim();
    if (displayAuthor.startsWith('作者：') || displayAuthor.startsWith('作者:')) {
      displayAuthor = displayAuthor.replaceFirst(RegExp(r'^作者[：:]'), '').trim();
    }
    displayAuthor = displayAuthor.isNotEmpty ? displayAuthor : '未知作者';

    return Container(
      decoration: BoxDecoration(
        color: isEink ? Colors.grey.shade200 : tdTheme.brandLightColor,
        borderRadius: isEink ? null : BorderRadius.circular(4),
      ),
      child: CustomPaint(
        painter: _DefaultCoverPainter(
          name: displayName,
          author: displayAuthor,
          accentColor: accentColor,
        ),
        child: Container(),
      ),
    );
  }

  /// 构建信息
  Widget _buildInfo(BuildContext context, bool isEink, TDThemeData tdTheme) {
    final textColor = isEink ? Colors.black : tdTheme.fontGyColor1;
    final secondaryTextColor = isEink ? Colors.black54 : tdTheme.fontGyColor3;

    // 确保有内容显示
    final displayName = book.name.trim().isNotEmpty ? book.name.trim() : '未知书籍';
    var displayAuthor = book.author.trim();
    if (displayAuthor.startsWith('作者：') || displayAuthor.startsWith('作者:')) {
      displayAuthor = displayAuthor.replaceFirst(RegExp(r'^作者[：:]'), '').trim();
    }
    displayAuthor = displayAuthor.isNotEmpty ? displayAuthor : '未知作者';

    // 获取分类列表
    final kinds = book.kinds != null && book.kinds!.isNotEmpty
        ? book.kinds!.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList()
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 书名
        highlightKeyword != null && highlightKeyword!.isNotEmpty
            ? _buildHighlightedText(
                text: displayName,
                keyword: highlightKeyword!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                isEink: isEink,
              )
            : Text(
                displayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        const SizedBox(height: 6),
        // 作者
        Row(
          children: [
            Icon(Icons.person_outline, size: 14, color: secondaryTextColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                displayAuthor,
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 分类标签（搜索结果显示）
        if (isSearchResult && kinds.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: kinds.take(3).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isEink
                      ? Colors.grey.shade300
                      : tdTheme.brandLightColor.withValues(alpha: 0.3),
                  borderRadius: isEink ? null : BorderRadius.circular(4),
                  border: isEink
                      ? Border.all(color: Colors.black26, width: 0.5)
                      : null,
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isEink ? Colors.black : tdTheme.brandNormalColor,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
        ],
        // 阅读进度（书架显示）
        if (!isSearchResult) ...[
          if (book.currentChapter != null && book.currentChapter!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isEink
                    ? Colors.grey.shade200
                    : tdTheme.grayColor1,
                borderRadius: isEink ? null : BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_outlined, size: 12, color: secondaryTextColor),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      book.currentChapter!,
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              if (book.totalChapterNum > 0)
                Text(
                  '共${book.totalChapterNum}章',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryTextColor,
                  ),
                ),
              if (book.latestChapter != null && book.latestChapter!.isNotEmpty) ...[
                if (book.totalChapterNum > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('·', style: TextStyle(color: secondaryTextColor)),
                  ),
                Expanded(
                  child: Text(
                    '更新：${book.latestChapter}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isEink ? Colors.black : tdTheme.brandNormalColor.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
        // 简介（搜索结果显示）
        if (isSearchResult && book.intro != null && book.intro!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              book.intro!.trim().replaceAll(RegExp(r'\s+'), ' '),
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

/// 书籍数据模型
class TDThemedBookData {
  /// 书名
  final String name;

  /// 作者
  final String author;

  /// 封面URL
  final String? coverUrl;

  /// 书籍URL（用于Hero动画）
  final String? bookUrl;

  /// 分类（逗号分隔）
  final String? kinds;

  /// 当前章节标题
  final String? currentChapter;

  /// 最新章节标题
  final String? latestChapter;

  /// 总章节数
  final int totalChapterNum;

  /// 简介
  final String? intro;

  const TDThemedBookData({
    required this.name,
    required this.author,
    this.coverUrl,
    this.bookUrl,
    this.kinds,
    this.currentChapter,
    this.latestChapter,
    this.totalChapterNum = 0,
    this.intro,
  });

  /// 从 Book 模型创建
  factory TDThemedBookData.fromBook(dynamic book) {
    return TDThemedBookData(
      name: book.name ?? '',
      author: book.author ?? '',
      coverUrl: book.displayCover,
      bookUrl: book.bookUrl,
      kinds: book.kind,
      currentChapter: book.durChapterTitle,
      latestChapter: book.latestChapterTitle,
      totalChapterNum: book.totalChapterNum ?? 0,
      intro: book.displayIntro,
    );
  }
}

/// 默认封面绘制器
class _DefaultCoverPainter extends CustomPainter {
  final String name;
  final String author;
  final Color accentColor;

  _DefaultCoverPainter({
    required this.name,
    required this.author,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制书名
    if (name.isNotEmpty) {
      final nameChars = name.split('');
      final nameStyle = TextStyle(
        fontSize: size.width / 6,
        fontWeight: FontWeight.bold,
        color: accentColor,
      );

      var startX = size.width * 0.2;
      var startY = size.height * 0.2;
      var currentFontSize = nameStyle.fontSize!;
      final lineHeight = currentFontSize * 1.2;

      for (int i = 0; i < nameChars.length && i < 8; i++) {
        final char = nameChars[i];
        final charOffset = Offset(startX, startY);

        // 先绘制描边（白色）
        final strokeSpan = TextSpan(
          text: char,
          style: TextStyle(
            fontSize: currentFontSize,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = currentFontSize / 5
              ..color = Colors.white,
          ),
        );
        final strokePainter = TextPainter(
          text: strokeSpan,
          textDirection: TextDirection.ltr,
        );
        strokePainter.layout();
        strokePainter.paint(canvas, charOffset);

        // 再绘制填充（主题色）
        final fillSpan = TextSpan(
          text: char,
          style: TextStyle(
            fontSize: currentFontSize,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        );
        final fillPainter = TextPainter(
          text: fillSpan,
          textDirection: TextDirection.ltr,
        );
        fillPainter.layout();
        fillPainter.paint(canvas, charOffset);

        startY += lineHeight;

        // 如果超出范围，换列并缩小字体
        if (startY > size.height * 0.8 && i < nameChars.length - 1) {
          startX += currentFontSize * 1.2;
          startY = size.height * 0.2;
          currentFontSize = size.width / 10;
        }
      }
    }

    // 绘制作者
    if (author.isNotEmpty) {
      final authorChars = author.split('');
      final authorStyle = TextStyle(
        fontSize: size.width / 10,
        color: accentColor,
      );

      var startX = size.width * 0.8;
      var startY = size.height * 0.95;
      final lineHeight = authorStyle.fontSize! * 1.2;

      // 从下往上绘制
      for (int i = authorChars.length - 1; i >= 0 && i >= authorChars.length - 6; i--) {
        final char = authorChars[i];
        startY -= lineHeight;

        if (startY < size.height * 0.3) break;

        final charOffset = Offset(startX, startY);

        // 先绘制描边（白色）
        final strokeSpan = TextSpan(
          text: char,
          style: authorStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = authorStyle.fontSize! / 5
              ..color = Colors.white,
          ),
        );
        final strokePainter = TextPainter(
          text: strokeSpan,
          textDirection: TextDirection.ltr,
        );
        strokePainter.layout();
        strokePainter.paint(canvas, charOffset);

        // 再绘制填充（主题色）
        final fillSpan = TextSpan(
          text: char,
          style: authorStyle,
        );
        final fillPainter = TextPainter(
          text: fillSpan,
          textDirection: TextDirection.ltr,
        );
        fillPainter.layout();
        fillPainter.paint(canvas, charOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DefaultCoverPainter oldDelegate) {
    return oldDelegate.name != name ||
        oldDelegate.author != author ||
        oldDelegate.accentColor != accentColor;
  }
}

/// TDesign 风格的网格书籍卡片
class TDThemedBookGridCard extends StatelessWidget {
  /// 书籍数据
  final TDThemedBookData book;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 封面宽度
  final double coverWidth;

  /// 封面高度比例（相对于宽度）
  final double coverAspectRatio;

  const TDThemedBookGridCard({
    super.key,
    required this.book,
    this.onTap,
    this.onLongPress,
    this.coverWidth = 100,
    this.coverAspectRatio = 0.73,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 封面
          AspectRatio(
            aspectRatio: coverAspectRatio,
            child: _buildCover(context, isEink, tdTheme),
          ),
          const SizedBox(height: 6),
          // 书名
          Text(
            book.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isEink ? Colors.black : tdTheme.fontGyColor1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // 作者
          if (book.author.isNotEmpty)
            Text(
              book.author,
              style: TextStyle(
                fontSize: 11,
                color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildCover(BuildContext context, bool isEink, TDThemeData tdTheme) {
    final coverUrl = book.coverUrl;
    final accentColor = isEink ? Colors.black : tdTheme.brandNormalColor;

    Widget defaultCover = Container(
      decoration: BoxDecoration(
        color: isEink ? Colors.grey.shade200 : tdTheme.brandLightColor,
        borderRadius: isEink ? null : BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          Icons.book,
          size: 40,
          color: accentColor.withValues(alpha: 0.5),
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: isEink ? null : BorderRadius.circular(4),
        border: isEink ? Border.all(color: Colors.black12, width: 1) : null,
        boxShadow: !isEink
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: isEink ? BorderRadius.zero : BorderRadius.circular(4),
        child: coverUrl != null && coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => defaultCover,
                errorWidget: (context, url, error) => defaultCover,
              )
            : defaultCover,
      ),
    );
  }
}
