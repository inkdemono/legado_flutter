import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/models/book.dart';
import '../../../services/book/book_service.dart';
import '../../widgets/home/home_shell.dart';
import 'book_info/book_info_page.dart';

/// 书籍管理列表项
class BookManageItem extends StatelessWidget {
  final Book book;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Future<void> Function()? onDeleted;

  const BookManageItem({
    super.key,
    required this.book,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final tags = _buildTags();

    return HomeSectionCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      color: isSelected ? const Color(0xFFF4F7FF) : HomePalette.card(context),
      onTap: onTap,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? HomePalette.accent : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? HomePalette.accent
                      : HomePalette.tertiaryText(context)
                          .withValues(alpha: 0.45),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          _buildCover(context),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${book.displayAuthor} · ${_buildMeta()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags
                        .map((tag) => _TagChip(label: tag.$1, color: tag.$2))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.more_horiz_rounded,
              color: HomePalette.tertiaryText(context),
            ),
            onPressed: () => _showItemMenu(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    return Container(
      width: 52,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: HomePalette.mutedCard(context),
        border: Border.all(
          color: isSelected
              ? HomePalette.accent.withValues(alpha: 0.24)
              : HomePalette.lineColor(context),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: book.displayCover != null && book.displayCover!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: book.displayCover!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildCoverFallback(context),
                errorWidget: (context, url, error) =>
                    _buildCoverFallback(context),
              )
            : _buildCoverFallback(context),
      ),
    );
  }

  Widget _buildCoverFallback(BuildContext context) {
    return Container(
      color: HomePalette.mutedCard(context),
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_rounded,
        color: HomePalette.tertiaryText(context),
      ),
    );
  }

  String _buildMeta() {
    if (book.durChapterTitle != null &&
        book.durChapterTitle!.trim().isNotEmpty) {
      return '已读至 ${book.durChapterTitle}';
    }
    if (book.durChapterIndex > 0) {
      return '已读至 第 ${book.durChapterIndex + 1} 章';
    }
    if (book.durChapterTime > 0) {
      return '最近阅读 ${_formatRelativeTime(book.durChapterTime)}';
    }
    if (book.lastCheckTime > 0) {
      return '上次检查 ${_formatRelativeTime(book.lastCheckTime)}';
    }
    return book.isLocal ? '本地书籍' : '在线书籍';
  }

  List<(String, Color)> _buildTags() {
    final tags = <(String, Color)>[];
    final tagText = (book.customTag?.trim().isNotEmpty == true)
        ? book.customTag!.trim()
        : (book.kind?.trim().isNotEmpty == true ? book.kind!.trim() : null);
    if (tagText != null) {
      tags.add((tagText, const Color(0xFF86909C)));
    }

    if (book.isLocal) {
      tags.add(('本地书', const Color(0xFF1677FF)));
    } else if (!book.canUpdate) {
      tags.add(('不更新', const Color(0xFF8B5CF6)));
    } else if (book.lastCheckCount > 0) {
      tags.add(('待更新 ${book.lastCheckCount}', const Color(0xFF2BA471)));
    } else {
      tags.add(('可更新', const Color(0xFF2BA471)));
    }

    if (book.totalChapterNum > 0) {
      tags.add(('共 ${book.totalChapterNum} 章', const Color(0xFF86909C)));
    }

    return tags;
  }

  String _formatRelativeTime(int timestamp) {
    if (timestamp <= 0) return '未知';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showItemMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('查看详情'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookInfoPage(
                      key: ValueKey('book_info_${book.bookUrl}'),
                      bookUrl: book.bookUrl,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('确认删除'),
                    content: Text('确定要删除《${book.name}》吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('删除'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;

                try {
                  await BookService.instance.deleteBook(book.bookUrl);
                  await onDeleted?.call();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('删除成功')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('删除失败: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
