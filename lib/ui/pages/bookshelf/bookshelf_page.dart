import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/models/book.dart';
import '../../../data/models/book_group.dart';
import '../../../providers/book_provider.dart';
import '../../../providers/bookshelf_layout_provider.dart';
import '../../../providers/bookshelf_settings_provider.dart';
import '../../../providers/main_page_index_provider.dart';
import '../../../providers/scroll_control_provider.dart';
import '../../../providers/book_update_count_provider.dart';
import '../../../services/book/book_service.dart';
import '../../../services/book/local_book_service.dart';
import '../../widgets/book/book_card.dart';
import '../../widgets/book/book_grid_card.dart';
import '../reader/reader_page.dart';
import '../search/search_page.dart';
import 'book_info/book_info_page.dart';
import 'book_info/book_info_edit_page.dart';
import 'bookshelf_layout_settings_page.dart';
import 'group_manage_dialog.dart';
import 'book_manage_page.dart';
import 'bookshelf_manage_dialog.dart';
import 'cache_export_dialog.dart';
import 'log_dialog.dart';
import 'remote_book_dialog.dart';
import 'widgets/bookshelf_empty_state.dart';
import 'widgets/bookshelf_add_book_sheet.dart';
import '../../widgets/home/home_shell.dart';

/// 书架页面
class BookshelfPage extends ConsumerStatefulWidget {
  const BookshelfPage({super.key});

  @override
  ConsumerState<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends ConsumerState<BookshelfPage> {
  int _selectedGroupIndex = 0;

  // 批量操作相关
  bool _isBatchMode = false;
  final Set<String> _selectedBookUrls = <String>{};

  // 滚动控制
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  /// 滚动到顶部
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 打开书籍
  void _openBook(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReaderPage(
          book: book,
          initialChapterIndex: book.durChapterIndex,
        ),
      ),
    );
  }

  /// 删除书籍
  Future<void> _deleteBook(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除书籍'),
        content: Text('确定要删除《${book.name}》吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(bookOperationsProvider).removeBook(book.bookUrl, ref);

        // 刷新所有分组的书籍列表，确保界面更新
        final groupsAsync = ref.read(bookGroupsProvider);
        final groups = groupsAsync.value ?? [];
        for (final group in groups) {
          ref.invalidate(booksByGroupProvider(group.groupId));
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已删除')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }

  /// 显示添加书籍对话框
  void _showAddBookDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => BookshelfAddBookSheet(
        onSearchOnline: () {
          ref.read(mainPageIndexProvider.notifier).switchToExplore();
        },
        onImportLocal: _importLocalBooks,
      ),
    );
  }

  /// 导入本地书籍
  Future<void> _importLocalBooks() async {
    try {
      // 显示加载提示
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final books = await LocalBookService.instance.importLocalFiles();

      if (!mounted) return;
      Navigator.pop(context); // 关闭加载对话框

      if (books.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未选择文件或导入失败')),
        );
        return;
      }

      // 刷新书架 - 需要同时刷新所有分组的书籍列表
      ref.invalidate(refreshBookshelfProvider);
      // 刷新当前分组的书籍列表
      final groupsAsync = ref.read(bookGroupsProvider);
      final groups = groupsAsync.value ?? [];
      if (groups.isNotEmpty && _selectedGroupIndex < groups.length) {
        ref.invalidate(
            booksByGroupProvider(groups[_selectedGroupIndex].groupId));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功导入 ${books.length} 本书籍')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(bookGroupsProvider);
    final settings = ref.watch(bookshelfSettingsProvider);
    final layoutType = settings.layoutType;

    // 监听滚动控制Provider
    ref.listen(bookshelfScrollControlProvider, (previous, next) {
      if (next > 0 && mounted) {
        _scrollToTop();
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildBookshelfHeader(groupsAsync),
              Expanded(
                child: groupsAsync.when(
                  data: (groups) {
                    if (groups.isEmpty) {
                      return const Center(child: Text('暂无分组'));
                    }

                    if (_selectedGroupIndex >= groups.length) {
                      _selectedGroupIndex = 0;
                    }

                    final selectedGroup = groups[_selectedGroupIndex];
                    return _buildBodyWithGroup(
                        context, selectedGroup, layoutType);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('加载失败: $error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(bookGroupsProvider);
                          },
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isBatchMode
          ? FloatingActionButton.extended(
              onPressed: _selectedBookUrls.isEmpty ? null : _showBatchActions,
              backgroundColor: HomePalette.accent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.more_vert),
              label: Text('已选择 ${_selectedBookUrls.length}'),
            )
          : FloatingActionButton(
              onPressed: _showAddBookDialog,
              backgroundColor: HomePalette.accent,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded),
            ),
    );
  }

  /// 构建带分组的书架内容
  Widget _buildBodyWithGroup(
      BuildContext context, BookGroup group, BookshelfLayoutType layoutType) {
    final settings = ref.watch(bookshelfSettingsProvider);
    final booksAsync = ref.watch(booksByGroupProvider(group.groupId));

    final globalSortType = settings.sortType;
    final groupBookSort = group.getRealBookSort(_sortTypeToInt(globalSortType));
    final effectiveSortType = _intToSortType(groupBookSort);

    return booksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return _buildEmptyState();
        }
        return _buildBooksList(books, layoutType, effectiveSortType);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('加载失败: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(refreshBookshelfProvider);
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: HomeSectionCard(
          margin: EdgeInsets.zero,
          child: BookshelfEmptyState(
            onSearchOnline: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
            onImportLocal: _importLocalBooks,
          ),
        ),
      ),
    );
  }

  Widget _buildBookshelfHeader(AsyncValue<List<BookGroup>> groupsAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: HomePalette.card(context).withValues(alpha: 0.96),
        border: Border(
          bottom: BorderSide(color: HomePalette.lineColor(context)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildHeaderActionButton(
                icon: _isBatchMode ? Icons.close_rounded : Icons.menu_rounded,
                onTap: () {
                  setState(() {
                    _isBatchMode = !_isBatchMode;
                    if (!_isBatchMode) {
                      _selectedBookUrls.clear();
                    }
                  });
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '书架',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
              ),
              _buildHeaderActionButton(
                icon: Icons.search_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                position: PopupMenuPosition.under,
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  _buildPopupMenuItem(
                      'update_toc', Icons.refresh_rounded, '更新目录'),
                  const PopupMenuDivider(),
                  _buildPopupMenuItem(
                      'add_local', Icons.add_box_outlined, '添加本地'),
                  _buildPopupMenuItem(
                      'add_remote', Icons.cloud_download_outlined, '远程书籍'),
                  _buildPopupMenuItem('add_url', Icons.link_rounded, '添加网址'),
                  const PopupMenuDivider(),
                  _buildPopupMenuItem('bookshelf_manage',
                      Icons.manage_accounts_outlined, '书架管理'),
                  _buildPopupMenuItem(
                      'cache_export', Icons.storage_rounded, '缓存/导出'),
                  _buildPopupMenuItem(
                      'group', Icons.folder_open_rounded, '分组管理'),
                  _buildPopupMenuItem(
                      'layout', Icons.dashboard_customize_outlined, '书架布局'),
                  const PopupMenuDivider(),
                  _buildPopupMenuItem(
                      'export_booklist', Icons.upload_rounded, '导出书单'),
                  _buildPopupMenuItem(
                      'import_booklist', Icons.download_rounded, '导入书单'),
                  const PopupMenuDivider(),
                  _buildPopupMenuItem('log', Icons.history_edu_rounded, '更新日志'),
                ],
                child: IgnorePointer(
                  child: _buildHeaderActionButton(
                    icon: Icons.more_horiz_rounded,
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          groupsAsync.when(
            data: _buildGroupTabs,
            loading: () => const SizedBox(height: 36),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: HomePalette.mutedCard(context),
            shape: BoxShape.circle,
            border: Border.all(color: HomePalette.lineColor(context)),
          ),
          child: Icon(
            icon,
            size: 22,
            color: HomePalette.primaryText(context),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupTabs(List<BookGroup> groups) {
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_selectedGroupIndex >= groups.length) {
      _selectedGroupIndex = 0;
    }

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == _selectedGroupIndex;
          final group = groups[index];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                if (index == _selectedGroupIndex) return;
                setState(() {
                  _selectedGroupIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? HomePalette.accentSoft
                      : HomePalette.mutedCard(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  group.groupName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected
                        ? HomePalette.accentStrong
                        : HomePalette.secondaryText(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建书籍列表
  Widget _buildBooksList(List<Book> books, BookshelfLayoutType layoutType,
      [SortType? sortType]) {
    final settings = ref.watch(bookshelfSettingsProvider);
    final effectiveSortType = sortType ?? settings.sortType;
    final sortedBooks = _sortBooks(books, effectiveSortType);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(refreshBookshelfProvider);
        // 刷新当前分组的书籍列表
        final groupsAsync = ref.read(bookGroupsProvider);
        final groups = groupsAsync.value ?? [];
        if (groups.isNotEmpty && _selectedGroupIndex < groups.length) {
          ref.invalidate(
              booksByGroupProvider(groups[_selectedGroupIndex].groupId));
        }
      },
      child: layoutType == BookshelfLayoutType.list
          ? _buildListView(sortedBooks, settings, effectiveSortType)
          : _buildGridView(
              sortedBooks, getGridCrossAxisCount(layoutType), settings),
    );
  }

  /// 排序书籍
  List<Book> _sortBooks(List<Book> books, SortType sortType) {
    final sorted = List<Book>.from(books);

    switch (sortType) {
      case SortType.byReadTime:
        sorted.sort((a, b) => b.durChapterTime.compareTo(a.durChapterTime));
        break;
      case SortType.byUpdateTime:
        sorted
            .sort((a, b) => b.latestChapterTime.compareTo(a.latestChapterTime));
        break;
      case SortType.byBookName:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.manual:
        sorted.sort((a, b) => a.order.compareTo(b.order));
        break;
      case SortType.comprehensive:
        // 综合排序：先按阅读时间，再按更新时间
        sorted.sort((a, b) {
          final readTimeCompare = b.durChapterTime.compareTo(a.durChapterTime);
          if (readTimeCompare != 0) return readTimeCompare;
          return b.latestChapterTime.compareTo(a.latestChapterTime);
        });
        break;
    }

    return sorted;
  }

  /// 将SortType转换为int（用于BookGroup.bookSort）
  int _sortTypeToInt(SortType sortType) {
    switch (sortType) {
      case SortType.byReadTime:
        return 0;
      case SortType.byUpdateTime:
        return 1;
      case SortType.byBookName:
        return 2;
      case SortType.manual:
        return 3;
      case SortType.comprehensive:
        return 4;
    }
  }

  /// 将int转换为SortType（用于BookGroup.bookSort）
  SortType _intToSortType(int sortInt) {
    switch (sortInt) {
      case 0:
        return SortType.byReadTime;
      case 1:
        return SortType.byUpdateTime;
      case 2:
        return SortType.byBookName;
      case 3:
        return SortType.manual;
      case 4:
        return SortType.comprehensive;
      default:
        return SortType.byReadTime;
    }
  }

  /// 构建列表视图
  Widget _buildListView(
      List<Book> books, BookshelfSettings settings, SortType sortType) {
    // 如果需要分组，先分组
    if (settings.groupingStyle != GroupingStyle.none) {
      return _buildGroupedListView(books, settings, sortType);
    }

    // 如果是手动排序，使用可拖拽列表
    // 注意：ReorderableListView不支持controller，需要使用其他方式实现滚动
    if (sortType == SortType.manual) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: books.length,
        onReorder: (oldIndex, newIndex) {
          _handleReorder(books, oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final book = books[index];
          return _buildReorderableBookCard(
            key: ValueKey(book.bookUrl),
            book: book,
            index: index,
          );
        },
      );
    }

    // 其他排序方式使用普通列表
    final listView = ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isSelected =
            _isBatchMode && _selectedBookUrls.contains(book.bookUrl);
        return _buildBookCardWithSelection(
          book: book,
          isSelected: isSelected,
          onTap: _isBatchMode
              ? () => _toggleBookSelection(book)
              : () => _openBook(book),
          onLongPress: _isBatchMode
              ? () => _toggleBookSelection(book)
              : () => _showBookMenu(book),
        );
      },
    );

    // 如果启用了快速滚动条，包装Scrollbar
    if (settings.showQuickScrollBar) {
      return Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: listView,
      );
    }

    return listView;
  }

  /// 构建分组列表视图
  Widget _buildGroupedListView(
      List<Book> books, BookshelfSettings settings, SortType sortType) {
    final grouped = _groupBooks(books, settings.groupingStyle);

    // 如果是手动排序，需要特殊处理（分组模式下不支持拖拽排序）
    if (sortType == SortType.manual) {
      // 提示用户：分组模式下不支持拖拽排序
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: grouped.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '分组模式下不支持拖拽排序，请先取消分组',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            );
          }
          final group = grouped[index - 1];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (group['title'] != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    group['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ...(group['books'] as List<Book>).map((book) => BookCard(
                    book: book,
                    isSearchResult: false,
                    onTap: () => _openBook(book),
                    onLongPress: () => _showBookMenu(book),
                  )),
            ],
          );
        },
      );
    }

    final groupedListView = ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final group = grouped[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group['title'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  group['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ...(group['books'] as List<Book>).map((book) => BookCard(
                  book: book,
                  isSearchResult: false,
                  onTap: () => _openBook(book),
                  onLongPress: () => _showBookMenu(book),
                )),
          ],
        );
      },
    );

    // 如果启用了快速滚动条，包装Scrollbar
    if (settings.showQuickScrollBar) {
      return Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: groupedListView,
      );
    }

    return groupedListView;
  }

  /// 分组书籍
  List<Map<String, dynamic>> _groupBooks(
      List<Book> books, GroupingStyle style) {
    if (style == GroupingStyle.none) {
      return [
        {'title': null, 'books': books}
      ];
    }

    final Map<String, List<Book>> groups = {};

    for (final book in books) {
      String key;
      switch (style) {
        case GroupingStyle.byTag:
          key = book.customTag ?? book.kind ?? '未分类';
          break;
        case GroupingStyle.byAuthor:
          key = book.author.isNotEmpty ? book.author : '未知作者';
          break;
        default:
          key = '其他';
      }
      groups.putIfAbsent(key, () => []).add(book);
    }

    // 转换为列表并排序
    final result = groups.entries
        .map((entry) => {
              'title': entry.key,
              'books': entry.value,
            })
        .toList();

    result
        .sort((a, b) => (a['title'] as String).compareTo(b['title'] as String));

    return result;
  }

  /// 构建网格视图
  Widget _buildGridView(
      List<Book> books, int crossAxisCount, BookshelfSettings settings) {
    // 如果需要分组，先分组
    if (settings.groupingStyle != GroupingStyle.none) {
      return _buildGroupedGridView(books, crossAxisCount, settings);
    }

    final gridView = GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.68, // 优化比例，防止过高
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookGridCard(
          book: book,
          isSearchResult: false,
          onTap: () => _openBook(book),
          onLongPress: () => _showBookMenu(book),
        );
      },
    );

    // 如果启用了快速滚动条，包装Scrollbar
    if (settings.showQuickScrollBar) {
      return Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: gridView,
      );
    }

    return gridView;
  }

  /// 构建分组网格视图
  Widget _buildGroupedGridView(
      List<Book> books, int crossAxisCount, BookshelfSettings settings) {
    final grouped = _groupBooks(books, settings.groupingStyle);

    final groupedGridView = ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final group = grouped[index];
        final groupBooks = group['books'] as List<Book>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group['title'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  group['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.68,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: groupBooks.length,
              itemBuilder: (context, bookIndex) {
                final book = groupBooks[bookIndex];
                return BookGridCard(
                  book: book,
                  isSearchResult: false,
                  onTap: () => _openBook(book),
                  onLongPress: () => _showBookMenu(book),
                );
              },
            ),
          ],
        );
      },
    );

    // 如果启用了快速滚动条，包装Scrollbar
    if (settings.showQuickScrollBar) {
      return Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: groupedGridView,
      );
    }

    return groupedGridView;
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String value, IconData icon, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  /// 处理菜单操作
  void _handleMenuAction(String value) {
    switch (value) {
      case 'update_toc':
        _updateToc();
        break;
      case 'add_local':
        _showAddBookDialog();
        break;
      case 'add_remote':
        _showRemoteBookDialog();
        break;
      case 'add_url':
        _showAddUrlDialog();
        break;
      case 'bookshelf_manage':
        _openBookManagePage();
        break;
      case 'cache_export':
        _showCacheExportDialog();
        break;
      case 'group':
        showDialog(
          context: context,
          builder: (context) => const GroupManageDialog(),
        );
        break;
      case 'layout':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const BookshelfLayoutSettingsPage(),
          ),
        );
        break;
      case 'export_booklist':
        _exportBooklist();
        break;
      case 'import_booklist':
        _importBooklist();
        break;
      case 'log':
        _showLogDialog();
        break;
    }
  }

  /// 更新目录
  Future<void> _updateToc() async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final groupsAsync = ref.read(bookGroupsProvider);
      final groups = groupsAsync.value ?? [];
      if (groups.isEmpty) return;

      // 确保 _selectedGroupIndex 在有效范围内
      if (_selectedGroupIndex >= groups.length) {
        _selectedGroupIndex = 0;
      }

      final currentGroup = groups[_selectedGroupIndex];
      final books =
          await ref.read(booksByGroupProvider(currentGroup.groupId).future);

      if (books.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('当前分组没有书籍')),
        );
        return;
      }

      if (!mounted) return;
      // 显示进度对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在更新目录...'),
                ],
              ),
            ),
          ),
        ),
      );

      // 批量更新目录
      final results = await BookService.instance.updateChapterLists(books);

      if (!mounted) return;
      navigator.pop(); // 关闭进度对话框

      final successCount = results.values.where((v) => v == true).length;
      final failCount = results.length - successCount;

      // 刷新书架
      ref.invalidate(refreshBookshelfProvider);
      // 刷新更新数量Badge
      ref.read(bookUpdateCountProvider.notifier).refresh();

      messenger.showSnackBar(
        SnackBar(
          content: Text('更新完成：成功 $successCount 本，失败 $failCount 本'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // 关闭进度对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新目录失败: $e')),
        );
      }
    }
  }

  /// 显示远程书籍对话框
  void _showRemoteBookDialog() {
    showDialog(
      context: context,
      builder: (context) => const RemoteBookDialog(),
    );
  }

  /// 显示添加网址对话框
  void _showAddUrlDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加网址'),
        content: TextField(
          controller: urlController,
          autofocus: true,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: '请输入书籍网址，多个网址请换行',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final urls = urlController.text.trim();
              if (urls.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('网址不能为空')),
                );
                return;
              }

              Navigator.pop(context);

              // 显示进度对话框
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('正在添加书籍...'),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final groupsAsync = ref.read(bookGroupsProvider);
                final groups = groupsAsync.value ?? [];
                final currentGroup =
                    groups.isNotEmpty ? groups[_selectedGroupIndex] : null;

                final successCount = await BookService.instance.addBookByUrl(
                  urls,
                  groupId: currentGroup?.groupId,
                );

                if (!mounted) return;
                navigator.pop(); // 关闭进度对话框

                // 刷新书架
                ref.invalidate(refreshBookshelfProvider);

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(successCount > 0
                        ? '成功添加 $successCount 本书籍'
                        : '添加失败，请检查网址是否正确或书源是否匹配'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                navigator.pop(); // 关闭进度对话框
                messenger.showSnackBar(
                  SnackBar(content: Text('添加失败: $e')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 打开书架管理对话框（针对特定书籍的分组）
  void _openBookshelfManageDialog(Book book) {
    final groupsAsync = ref.read(bookGroupsProvider);
    groupsAsync.when(
      data: (groups) {
        if (groups.isEmpty || !mounted) return;

        // 获取书籍所在的分组ID
        final bookGroupId = book.group;

        // 查找该分组是否存在
        final group = groups.firstWhere(
          (g) => g.groupId == bookGroupId,
          orElse: () {
            // 如果找不到，使用当前选中的分组
            if (_selectedGroupIndex < groups.length) {
              return groups[_selectedGroupIndex];
            }
            return groups.isNotEmpty ? groups[0] : groups[0];
          },
        );

        // 显示该分组的书架管理对话框
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BookshelfManageDialog(
            groupId: group.groupId,
          ),
        );
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  /// 打开书籍管理页面
  void _openBookManagePage() {
    final groupsAsync = ref.read(bookGroupsProvider);
    groupsAsync.when(
      data: (groups) {
        if (groups.isEmpty || !mounted) return;

        // 确保 _selectedGroupIndex 在有效范围内
        if (_selectedGroupIndex >= groups.length) {
          _selectedGroupIndex = 0;
        }

        final currentGroup = groups[_selectedGroupIndex];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BookManagePage(groupId: currentGroup.groupId),
          ),
        );
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  /// 显示缓存/导出对话框
  void _showCacheExportDialog() {
    final groupsAsync = ref.read(bookGroupsProvider);
    groupsAsync.when(
      data: (groups) {
        if (groups.isEmpty || !mounted) return;

        // 确保 _selectedGroupIndex 在有效范围内
        if (_selectedGroupIndex >= groups.length) {
          _selectedGroupIndex = 0;
        }

        final currentGroup = groups[_selectedGroupIndex];
        showDialog(
          context: context,
          builder: (context) =>
              CacheExportDialog(groupId: currentGroup.groupId),
        );
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  /// 导出书单
  Future<void> _exportBooklist() async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      final groupsAsync = ref.read(bookGroupsProvider);
      final groups = groupsAsync.value ?? [];
      if (groups.isEmpty) return;

      // 确保 _selectedGroupIndex 在有效范围内
      if (_selectedGroupIndex >= groups.length) {
        _selectedGroupIndex = 0;
      }

      final currentGroup = groups[_selectedGroupIndex];
      final books =
          await ref.read(booksByGroupProvider(currentGroup.groupId).future);

      if (books.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('当前分组没有书籍')),
        );
        return;
      }

      // 构建JSON数据
      final bookList = books
          .map((book) => {
                'name': book.name,
                'author': book.author,
                'intro': book.intro ?? '',
              })
          .toList();

      final jsonString = const JsonEncoder.withIndent('  ').convert(bookList);

      if (!mounted) return;
      // 显示导出结果
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('导出书单'),
          content: SingleChildScrollView(
            child: SelectableText(jsonString),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
            TextButton(
              onPressed: () async {
                final dialogNavigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                dialogNavigator.pop();
                try {
                  // 使用share_plus分享文件，让用户选择保存位置
                  final directory = await getApplicationDocumentsDirectory();
                  final file = File(
                      '${directory.path}/bookshelf_${DateTime.now().millisecondsSinceEpoch}.json');
                  await file.writeAsString(jsonString);

                  if (!mounted) return;
                  await SharePlus.instance.share(
                    ShareParams(
                      files: [XFile(file.path)],
                      text: '导出书单',
                    ),
                  );
                  messenger.showSnackBar(
                    const SnackBar(content: Text('导出成功')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('保存失败: $e')),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出书单失败: $e')),
        );
      }
    }
  }

  /// 导入书单
  Future<void> _importBooklist() async {
    final jsonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入书单'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jsonController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '请输入JSON格式的书单数据或URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.file_upload),
              label: const Text('选择文件'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json', 'txt'],
                    allowMultiple: false,
                  );

                  if (result != null && result.files.single.path != null) {
                    final file = File(result.files.single.path!);
                    final content = await file.readAsString();
                    jsonController.text = content;
                  }
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('选择文件失败: $e')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final jsonText = jsonController.text.trim();
              if (jsonText.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('请输入书单数据')),
                );
                return;
              }

              navigator.pop();

              // 显示进度对话框
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('正在导入书单...'),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              try {
                final groupsAsync = ref.read(bookGroupsProvider);
                final groups = groupsAsync.value ?? [];
                final currentGroup =
                    groups.isNotEmpty ? groups[_selectedGroupIndex] : null;

                final successCount = await BookService.instance.importBooklist(
                  jsonText,
                  groupId: currentGroup?.groupId,
                );

                if (!mounted) return;
                navigator.pop(); // 关闭进度对话框

                // 刷新书架
                ref.invalidate(refreshBookshelfProvider);

                messenger.showSnackBar(
                  SnackBar(
                    content: Text('导入完成：成功添加 $successCount 本书籍'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                navigator.pop(); // 关闭进度对话框
                messenger.showSnackBar(
                  SnackBar(content: Text('导入失败: $e')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示日志对话框
  void _showLogDialog() {
    showDialog(
      context: context,
      builder: (context) => const LogDialog(),
    );
  }

  /// 显示书籍菜单
  void _showBookMenu(Book book) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('打开'),
              onTap: () {
                Navigator.pop(context);
                _openBook(book);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                _editBook(book);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('书籍详情'),
              onTap: () {
                Navigator.pop(context);
                _showBookInfo(book);
              },
            ),
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: Text(book.order < 0 ? '取消置顶' : '置顶'),
              onTap: () {
                Navigator.pop(context);
                _togglePinBook(book);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('书架管理'),
              onTap: () {
                Navigator.pop(context);
                _openBookshelfManageDialog(book);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('删除'),
              onTap: () {
                Navigator.pop(context);
                _deleteBook(book);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 编辑书籍
  Future<void> _editBook(Book book) async {
    final updatedBook = await Navigator.of(context).push<Book>(
      MaterialPageRoute(
        builder: (context) => BookInfoEditPage(book: book),
      ),
    );

    if (updatedBook != null && mounted) {
      // 刷新书架
      ref.invalidate(booksByGroupProvider);
      final groupsAsync = ref.read(bookGroupsProvider);
      final groups = groupsAsync.value ?? [];
      if (groups.isNotEmpty && _selectedGroupIndex < groups.length) {
        ref.invalidate(
            booksByGroupProvider(groups[_selectedGroupIndex].groupId));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('书籍信息已更新')),
      );
    }
  }

  /// 显示书籍详情
  void _showBookInfo(Book book) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => BookInfoPage(
          key: ValueKey('book_info_${book.bookUrl}'),
          bookUrl: book.bookUrl,
          bookName: book.name,
          author: book.author,
          sourceUrl: book.origin,
          coverUrl: book.displayCover,
          intro: book.displayIntro,
        ),
      ),
    )
        .then((shouldRefresh) {
      // 如果返回 true，刷新书架
      if (shouldRefresh == true) {
        ref.invalidate(booksByGroupProvider);
      }
    });
  }

  /// 构建可拖拽的书籍卡片
  Widget _buildReorderableBookCard({
    required Key key,
    required Book book,
    required int index,
  }) {
    return Container(
      key: key,
      child: Stack(
        children: [
          BookCard(
            book: book,
            isSearchResult: false,
            onTap: () => _openBook(book),
            onLongPress: () => _showBookMenu(book),
          ),
          // 拖拽手柄
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 30,
              alignment: Alignment.center,
              child: const Icon(Icons.drag_handle, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建带选择状态的书籍卡片
  Widget _buildBookCardWithSelection({
    required Book book,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return Stack(
      children: [
        BookCard(
          book: book,
          isSearchResult: false,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
        if (_isBatchMode)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue
                    : Colors.grey.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
      ],
    );
  }

  /// 切换书籍选择状态
  void _toggleBookSelection(Book book) {
    setState(() {
      if (_selectedBookUrls.contains(book.bookUrl)) {
        _selectedBookUrls.remove(book.bookUrl);
      } else {
        _selectedBookUrls.add(book.bookUrl);
      }
    });
  }

  /// 显示批量操作菜单
  void _showBatchActions() {
    if (_selectedBookUrls.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('删除'),
              onTap: () {
                Navigator.pop(context);
                _batchDeleteBooks();
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('移动到分组'),
              onTap: () {
                Navigator.pop(context);
                _showMoveToGroupDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: const Text('置顶'),
              onTap: () {
                Navigator.pop(context);
                _batchPinBooks();
              },
            ),
            ListTile(
              leading: const Icon(Icons.unarchive),
              title: const Text('取消置顶'),
              onTap: () {
                Navigator.pop(context);
                _batchUnpinBooks();
              },
            ),
            ListTile(
              leading: const Icon(Icons.select_all),
              title: const Text('全选'),
              onTap: () {
                Navigator.pop(context);
                _selectAllBooks();
              },
            ),
            ListTile(
              leading: const Icon(Icons.deselect),
              title: const Text('取消全选'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedBookUrls.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 批量删除书籍
  Future<void> _batchDeleteBooks() async {
    if (_selectedBookUrls.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${_selectedBookUrls.length} 本书籍吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final count = _selectedBookUrls.length;
      for (final bookUrl in _selectedBookUrls) {
        await BookService.instance.deleteBook(bookUrl);
      }
      setState(() {
        _isBatchMode = false;
        _selectedBookUrls.clear();
      });
      ref.invalidate(refreshBookshelfProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已删除 $count 本书籍')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  /// 显示移动到分组对话框
  void _showMoveToGroupDialog() async {
    if (_selectedBookUrls.isEmpty) return;

    final groupsAsync = ref.read(bookGroupsProvider);
    final groups = groupsAsync.value ?? [];
    if (groups.isEmpty) return;

    final selectedGroup = await showDialog<BookGroup>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择分组'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                title: Text(group.groupName),
                onTap: () => Navigator.pop(context, group),
              );
            },
          ),
        ),
      ),
    );

    if (selectedGroup == null) return;

    try {
      final count = _selectedBookUrls.length;
      for (final bookUrl in _selectedBookUrls) {
        await BookService.instance
            .updateBookGroup(bookUrl, selectedGroup.groupId);
      }
      setState(() {
        _isBatchMode = false;
        _selectedBookUrls.clear();
      });
      ref.invalidate(refreshBookshelfProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('已移动 $count 本书籍到"${selectedGroup.groupName}"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('移动失败: $e')),
        );
      }
    }
  }

  /// 批量置顶书籍
  Future<void> _batchPinBooks() async {
    if (_selectedBookUrls.isEmpty) return;

    try {
      final count = _selectedBookUrls.length;
      for (final bookUrl in _selectedBookUrls) {
        await BookService.instance.updateBookOrder(bookUrl, -1);
      }
      ref.invalidate(refreshBookshelfProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已置顶 $count 本书籍')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  /// 批量取消置顶书籍
  Future<void> _batchUnpinBooks() async {
    if (_selectedBookUrls.isEmpty) return;

    try {
      // 获取当前书籍列表以确定新的order值
      final groupsAsync = ref.read(bookGroupsProvider);
      final groups = groupsAsync.value ?? [];
      if (groups.isEmpty) return;
      final currentGroup = groups[_selectedGroupIndex];
      final allBooks =
          await ref.read(booksByGroupProvider(currentGroup.groupId).future);
      final maxOrder = allBooks
          .where((b) => b.order >= 0)
          .map((b) => b.order)
          .fold<int>(0, (a, b) => a > b ? a : b);

      int newOrder = maxOrder + 1;
      final count = _selectedBookUrls.length;
      for (final bookUrl in _selectedBookUrls) {
        await BookService.instance.updateBookOrder(bookUrl, newOrder++);
      }
      ref.invalidate(refreshBookshelfProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已取消置顶 $count 本书籍')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  /// 全选书籍
  void _selectAllBooks() {
    // 需要从当前显示的书籍列表中获取所有书籍
    final groupsAsync = ref.read(bookGroupsProvider);
    groupsAsync.when(
      data: (groups) async {
        if (groups.isEmpty || !mounted) return;
        final currentGroup = groups[_selectedGroupIndex];
        final books =
            await ref.read(booksByGroupProvider(currentGroup.groupId).future);
        if (mounted) {
          setState(() {
            _selectedBookUrls.clear();
            _selectedBookUrls.addAll(books.map((b) => b.bookUrl));
          });
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  /// 处理拖拽重排序
  Future<void> _handleReorder(
      List<Book> books, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final movedBook = books.removeAt(oldIndex);
    books.insert(newIndex, movedBook);

    // 更新所有书籍的order字段
    try {
      for (int i = 0; i < books.length; i++) {
        final book = books[i];
        // 如果书籍原本是置顶的（order < 0），保持置顶状态
        final newOrder = book.order < 0 ? book.order : i;
        await BookService.instance.updateBookOrder(book.bookUrl, newOrder);
      }

      // 刷新书架
      ref.invalidate(refreshBookshelfProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('排序已保存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存排序失败: $e')),
        );
      }
    }
  }

  /// 置顶/取消置顶书籍
  Future<void> _togglePinBook(Book book) async {
    try {
      final newOrder = book.order < 0 ? 0 : -1;
      await BookService.instance.updateBookOrder(book.bookUrl, newOrder);
      ref.invalidate(refreshBookshelfProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newOrder < 0 ? '已置顶' : '已取消置顶')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }
}
