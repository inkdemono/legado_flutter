import 'package:cached_network_image/cached_network_image.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:flutter/material.dart';

import '../../../data/models/book.dart';
import '../../../data/models/book_chapter.dart';
import '../../../services/book/book_service.dart';
import '../../../services/reader/cache_service.dart';
import '../../../services/source/book_source_service.dart';
import '../../../utils/app_log.dart';
import '../../widgets/home/home_shell.dart';
import 'cache_export_dialog.dart';
import 'cache_manage_page.dart';

/// 缓存书籍列表项
class CacheBookItem extends StatefulWidget {
  final Book book;
  final CacheInfo? cacheInfo;
  final Future<void> Function()? onCacheCleared;

  const CacheBookItem({
    super.key,
    required this.book,
    this.cacheInfo,
    this.onCacheCleared,
  });

  @override
  State<CacheBookItem> createState() => _CacheBookItemState();
}

class _CacheBookItemState extends State<CacheBookItem> {
  bool _isClearing = false;
  bool _isCaching = false;
  double _cachingProgress = 0.0;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: Text('确定要清除《${widget.book.name}》的缓存吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isClearing = true;
    });

    try {
      await readService(AppServices.cacheService).clearBookCache(widget.book);
      await widget.onCacheCleared?.call();
      _showMessage('缓存已清除');
    } catch (e) {
      _showMessage('清除缓存失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }
  }

  Future<void> _startCaching() async {
    if (widget.book.isLocal) {
      _showMessage('本地书籍无需缓存');
      return;
    }

    setState(() {
      _isCaching = true;
      _cachingProgress = 0.0;
    });

    try {
      final source = await readService(AppServices.bookSourceService)
          .getBookSourceByUrl(widget.book.origin);
      if (source == null) {
        throw Exception('书源不存在');
      }

      final chapters = await readService(AppServices.bookService).getChapterList(widget.book);
      if (chapters.isEmpty) {
        throw Exception('章节列表为空');
      }

      final uncachedChapters = <BookChapter>[];
      for (final chapter in chapters) {
        final hasCache =
            await readService(AppServices.cacheService).hasChapterCache(widget.book, chapter);
        if (!hasCache) {
          uncachedChapters.add(chapter);
        }
      }

      if (uncachedChapters.isEmpty) {
        _showMessage('所有章节已缓存');
        return;
      }

      await readService(AppServices.cacheService).cacheChapters(
        widget.book,
        uncachedChapters,
        source,
        onProgress: (current, total) {
          if (!mounted) return;
          setState(() {
            _cachingProgress = current / total;
          });
        },
      );

      await widget.onCacheCleared?.call();
      _showMessage('缓存完成：${uncachedChapters.length} 个章节');
    } catch (e) {
      AppLog.instance.put('开始缓存失败: ${widget.book.name}', error: e);
      _showMessage('缓存失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCaching = false;
          _cachingProgress = 0.0;
        });
      }
    }
  }

  Future<void> _exportBook() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => CacheExportDialog(book: widget.book),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cacheInfo = widget.cacheInfo;
    final progress = cacheInfo?.progress ?? 0.0;

    return HomeSectionCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCover(context),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.book.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: HomePalette.primaryText(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.book.displayAuthor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: HomePalette.secondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildMenuButton(context),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      context,
                      icon: Icons.library_books_rounded,
                      text:
                          '${cacheInfo?.cachedChapters ?? 0}/${cacheInfo?.totalChapters ?? 0} 章',
                    ),
                    _buildInfoChip(
                      context,
                      icon: Icons.folder_zip_rounded,
                      text: '${cacheInfo?.cachedFiles.length ?? 0} 文件',
                    ),
                    _buildInfoChip(
                      context,
                      icon: Icons.percent_rounded,
                      text: '${(progress * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isCaching) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '正在缓存章节',
                        style: TextStyle(
                          fontSize: 12,
                          color: HomePalette.secondaryText(context),
                        ),
                      ),
                      Text(
                        '${(_cachingProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: HomePalette.primaryText(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: _cachingProgress,
                      minHeight: 6,
                      backgroundColor: HomePalette.lineColor(context),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF14B8A6),
                      ),
                    ),
                  ),
                ] else if (cacheInfo == null) ...[
                  Text(
                    '缓存信息统计中...',
                    style: TextStyle(
                      fontSize: 12,
                      color: HomePalette.tertiaryText(context),
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '缓存进度',
                        style: TextStyle(
                          fontSize: 12,
                          color: HomePalette.secondaryText(context),
                        ),
                      ),
                      Text(
                        '${cacheInfo.cachedChapters}/${cacheInfo.totalChapters} 章节',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: HomePalette.primaryText(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: HomePalette.lineColor(context),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF14B8A6),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    return Container(
      width: 60,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: HomePalette.mutedCard(context),
        border: Border.all(color: HomePalette.lineColor(context)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: widget.book.displayCover != null &&
                widget.book.displayCover!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: widget.book.displayCover!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildCoverFallback(
                  context,
                  icon: Icons.menu_book_rounded,
                ),
                errorWidget: (context, url, error) => _buildCoverFallback(
                  context,
                  icon: Icons.broken_image_outlined,
                ),
              )
            : _buildCoverFallback(
                context,
                icon: Icons.menu_book_rounded,
              ),
      ),
    );
  }

  Widget _buildCoverFallback(
    BuildContext context, {
    required IconData icon,
  }) {
    return Container(
      color: HomePalette.mutedCard(context),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: HomePalette.tertiaryText(context),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'cache':
            _startCaching();
            break;
          case 'export':
            _exportBook();
            break;
          case 'clear':
            _clearCache();
            break;
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: HomePalette.card(context),
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'cache',
          child: Row(
            children: [
              Icon(Icons.download_rounded, size: 20),
              SizedBox(width: 8),
              Text('开始缓存'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.file_download_outlined, size: 20),
              SizedBox(width: 8),
              Text('导出书籍'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'clear',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('清除缓存'),
            ],
          ),
        ),
      ],
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: HomePalette.mutedCard(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HomePalette.lineColor(context)),
        ),
        alignment: Alignment.center,
        child: _isClearing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.more_horiz_rounded,
                color: HomePalette.primaryText(context),
              ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: HomePalette.mutedCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HomePalette.lineColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HomePalette.secondaryText(context)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: HomePalette.secondaryText(context),
            ),
          ),
        ],
      ),
    );
  }
}
