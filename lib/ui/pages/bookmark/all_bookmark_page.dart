import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/bookmark.dart';
import '../../../services/book/book_service.dart';
import '../../../services/bookmark_service.dart';
import '../../widgets/home/home_shell.dart';
import '../reader/reader_page.dart';
import 'bookmark_dialog.dart';

/// 所有书签页面
class AllBookmarkPage extends ConsumerStatefulWidget {
  const AllBookmarkPage({super.key});

  @override
  ConsumerState<AllBookmarkPage> createState() => _AllBookmarkPageState();
}

class _AllBookmarkPageState extends ConsumerState<AllBookmarkPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Bookmark> _bookmarks = [];
  List<Bookmark> _filteredBookmarks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted && _searchController.text.trim() == query) {
        setState(() {
          _searchQuery = query;
          _filterBookmarks();
        });
      }
    });
  }

  void _filterBookmarks() {
    if (_searchQuery.isEmpty) {
      _filteredBookmarks = List<Bookmark>.from(_bookmarks);
      return;
    }

    final queryLower = _searchQuery.toLowerCase();
    _filteredBookmarks = _bookmarks.where((bookmark) {
      return bookmark.bookName.toLowerCase().contains(queryLower) ||
          bookmark.bookAuthor.toLowerCase().contains(queryLower) ||
          bookmark.chapterName.toLowerCase().contains(queryLower) ||
          bookmark.bookText.toLowerCase().contains(queryLower) ||
          bookmark.content.toLowerCase().contains(queryLower);
    }).toList();
  }

  Map<String, List<Bookmark>> _groupBookmarks(List<Bookmark> bookmarks) {
    final grouped = <String, List<Bookmark>>{};
    for (final bookmark in bookmarks) {
      final key = '${bookmark.bookName}|${bookmark.bookAuthor}';
      grouped.putIfAbsent(key, () => []).add(bookmark);
    }
    return grouped;
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookmarks = await BookmarkService.instance.getAllBookmarks();
      if (!mounted) return;
      setState(() {
        _bookmarks = bookmarks;
        _isLoading = false;
      });
      _filterBookmarks();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showMessage('加载书签失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedBookmarks = _groupBookmarks(_filteredBookmarks);
    final bookCount = groupedBookmarks.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFFF59E0B), Color(0xFFFB7185)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadBookmarks,
                  child: _buildBody(
                    context,
                    groupedBookmarks: groupedBookmarks,
                    bookCount: bookCount,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              _buildHeaderButton(
                context,
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '书签',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '按书籍归档管理所有阅读标记',
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.tertiaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (_bookmarks.isNotEmpty) ...[
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  tooltip: '更多操作',
                  offset: const Offset(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: HomePalette.card(context),
                  icon: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: HomePalette.card(context).withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: HomePalette.lineColor(context)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: HomePalette.primaryText(context),
                    ),
                  ),
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'export_json',
                      child: Text('导出 JSON'),
                    ),
                    PopupMenuItem<String>(
                      value: 'export_md',
                      child: Text('导出 Markdown'),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'clear',
                      child: Text('清空书签'),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'export_json':
                        _exportBookmarksJson();
                        break;
                      case 'export_md':
                        _exportBookmarksMd();
                        break;
                      case 'clear':
                        _showClearDialog();
                        break;
                    }
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          HomeSearchField(
            controller: _searchController,
            hintText: '搜索书名、章节或摘录',
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required Map<String, List<Bookmark>> groupedBookmarks,
    required int bookCount,
  }) {
    if (_isLoading) {
      return ListView(
        padding: EdgeInsets.all(24),
        children: [
          SizedBox(height: 180),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    final children = <Widget>[
      _buildSummaryCard(
        context,
        bookmarkCount: _filteredBookmarks.length,
        bookCount: bookCount,
      ),
      const SizedBox(height: 18),
    ];

    if (_filteredBookmarks.isEmpty) {
      children.add(
        HomeSectionCard(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: HomePalette.mutedCard(context),
                    shape: BoxShape.circle,
                    border: Border.all(color: HomePalette.lineColor(context)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _searchQuery.isNotEmpty
                        ? Icons.search_off_rounded
                        : Icons.bookmark_border_rounded,
                    size: 38,
                    color: HomePalette.tertiaryText(context),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty ? '未找到匹配的书签' : '暂无书签',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty
                      ? '换个关键词试试，或者清空搜索查看全部书签。'
                      : '在阅读器中添加书签后，这里会按书籍自动聚合展示。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      groupedBookmarks.forEach((key, bookmarks) {
        final parts = key.split('|');
        final bookName = parts[0];
        final author = parts.length > 1 ? parts[1] : '';

        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _BookmarkGroupCard(
              bookName: bookName,
              author: author,
              bookmarks: bookmarks,
              onTapBookmark: (bookmark) {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => BookmarkDialog(
                    bookmark: bookmark,
                    isEdit: true,
                  ),
                ).then((_) => _loadBookmarks());
              },
              onLongPressBookmark: _jumpToBookmark,
              formatTime: _formatTime,
            ),
          ),
        );
      });
    }

    children.add(const SizedBox(height: 80));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: children,
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required int bookmarkCount,
    required int bookCount,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFFB7185)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFB7185).withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '阅读标记簿',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.98),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '点击书签可编辑摘录，长按则直接跳转回原章节位置。',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildSummaryMetric(value: '$bookmarkCount', label: '书签'),
              const SizedBox(width: 10),
              _buildSummaryMetric(value: '$bookCount', label: '书籍'),
              const SizedBox(width: 10),
              _buildSummaryMetric(
                value: _searchQuery.isEmpty ? '全部' : '筛选中',
                label: '状态',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: HomePalette.card(context).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomePalette.lineColor(context)),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: HomePalette.primaryText(context),
          ),
        ),
      ),
    );
  }

  Future<void> _jumpToBookmark(Bookmark bookmark) async {
    try {
      final books = await BookService.instance.getBookshelfBooks();
      if (books.isEmpty) {
        _showMessage('当前书架为空，无法跳转');
        return;
      }

      dynamic targetBook;
      for (final book in books) {
        if (book.name == bookmark.bookName &&
            book.author == bookmark.bookAuthor) {
          targetBook = book;
          break;
        }
      }

      if (targetBook == null) {
        _showMessage('未找到对应书籍: ${bookmark.bookName}');
        return;
      }

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReaderPage(
            book: targetBook,
            initialChapterIndex: bookmark.chapterIndex,
          ),
        ),
      );
    } catch (e) {
      _showMessage('跳转失败: $e');
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空书签'),
        content: const Text('确定要清空所有书签吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await BookmarkService.instance.clearAllBookmarks();
              await _loadBookmarks();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBookmarksJson() async {
    try {
      final jsonString = jsonEncode(_bookmarks.map((b) => b.toMap()).toList());
      final result = await FilePicker.platform.saveFile(
        dialogTitle: '导出书签',
        fileName: 'bookmark-${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(jsonString);
        _showMessage('导出成功');
      }
    } catch (e) {
      _showMessage('导出失败: $e');
    }
  }

  Future<void> _exportBookmarksMd() async {
    try {
      final buffer = StringBuffer();
      String? currentBookName;
      String? currentAuthor;

      for (final bookmark in _bookmarks) {
        if (bookmark.bookName != currentBookName ||
            bookmark.bookAuthor != currentAuthor) {
          currentBookName = bookmark.bookName;
          currentAuthor = bookmark.bookAuthor;
          buffer.writeln('## $currentBookName $currentAuthor\n');
        }

        buffer.writeln('#### ${bookmark.chapterName}\n');

        if (bookmark.bookText.isNotEmpty) {
          buffer.writeln('###### 原文\n${bookmark.bookText}\n');
        }

        if (bookmark.content.isNotEmpty) {
          buffer.writeln('###### 摘要\n${bookmark.content}\n');
        }
      }

      final mdString = buffer.toString();
      final result = await FilePicker.platform.saveFile(
        dialogTitle: '导出书签',
        fileName: 'bookmark-${DateTime.now().millisecondsSinceEpoch}.md',
        type: FileType.custom,
        allowedExtensions: ['md'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(mdString);
        _showMessage('导出成功');
      }
    } catch (e) {
      _showMessage('导出失败: $e');
    }
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _BookmarkGroupCard extends StatelessWidget {
  final String bookName;
  final String author;
  final List<Bookmark> bookmarks;
  final void Function(Bookmark bookmark) onTapBookmark;
  final Future<void> Function(Bookmark bookmark) onLongPressBookmark;
  final String Function(int timestamp) formatTime;

  const _BookmarkGroupCard({
    required this.bookName,
    required this.author,
    required this.bookmarks,
    required this.onTapBookmark,
    required this.onLongPressBookmark,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return HomeSectionCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: HomePalette.mutedCard(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: HomePalette.primaryText(context),
                        ),
                      ),
                      if (author.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          author,
                          style: TextStyle(
                            fontSize: 12,
                            color: HomePalette.tertiaryText(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '${bookmarks.length} 个书签',
                  style: TextStyle(
                    fontSize: 12,
                    color: HomePalette.tertiaryText(context),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(bookmarks.length, (index) {
            final bookmark = bookmarks[index];
            final preview = bookmark.bookText.isNotEmpty
                ? bookmark.bookText
                : bookmark.content;
            return Column(
              children: [
                InkWell(
                  onTap: () => onTapBookmark(bookmark),
                  onLongPress: () => onLongPressBookmark(bookmark),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.bookmark_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bookmark.chapterName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: HomePalette.primaryText(context),
                                ),
                              ),
                              if (preview.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  preview,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: HomePalette.secondaryText(context),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                formatTime(bookmark.time),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: HomePalette.tertiaryText(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: HomePalette.tertiaryText(context),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index != bookmarks.length - 1)
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(left: 68, right: 16),
                    color: HomePalette.lineColor(context),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
