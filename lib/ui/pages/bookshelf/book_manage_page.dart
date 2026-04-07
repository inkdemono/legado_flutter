import 'package:flutter/material.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/book.dart';
import '../../../data/models/book_group.dart';
import '../../../services/book/book_service.dart';
import '../../../services/book_group_service.dart';
import '../../../services/reader/cache_service.dart';
import '../../widgets/home/home_shell.dart';
import 'book_info/book_info_page.dart';
import 'book_manage_action_bar.dart';
import 'book_manage_batch_actions.dart';
import 'book_manage_item.dart';

/// 书籍管理页面
class BookManagePage extends ConsumerStatefulWidget {
  final int? groupId;

  const BookManagePage({
    super.key,
    this.groupId,
  });

  @override
  ConsumerState<BookManagePage> createState() => _BookManagePageState();
}

class _BookManagePageState extends ConsumerState<BookManagePage> {
  final TextEditingController _searchController = TextEditingController();

  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  Set<String> _selectedBookUrls = {};
  bool _isLoading = true;
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.groupId;
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final books = _selectedGroupId != null
          ? await readService(AppServices.bookService).getBooksByGroup(_selectedGroupId!)
          : await readService(AppServices.bookService).getBookshelfBooks();

      final keyword = _searchController.text.trim();
      final existingUrls = books.map((book) => book.bookUrl).toSet();

      if (!mounted) return;
      setState(() {
        _books = books;
        _selectedBookUrls = _selectedBookUrls.intersection(existingUrls);
        _filteredBooks = _applyFilter(books, keyword);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showMessage('加载失败: $e');
    }
  }

  List<Book> _applyFilter(List<Book> books, String keyword) {
    final normalized = keyword.trim().toLowerCase();
    if (normalized.isEmpty) {
      return List<Book>.from(books);
    }
    return books.where((book) {
      return book.name.toLowerCase().contains(normalized) ||
          book.author.toLowerCase().contains(normalized) ||
          (book.kind?.toLowerCase().contains(normalized) ?? false) ||
          (book.customTag?.toLowerCase().contains(normalized) ?? false);
    }).toList();
  }

  void _filterBooks(String keyword) {
    setState(() {
      _filteredBooks = _applyFilter(_books, keyword);
    });
  }

  void _toggleSelection(String bookUrl) {
    setState(() {
      if (_selectedBookUrls.contains(bookUrl)) {
        _selectedBookUrls.remove(bookUrl);
      } else {
        _selectedBookUrls.add(bookUrl);
      }
    });
  }

  void _toggleSelectAllVisible() {
    final visibleUrls = _filteredBooks.map((book) => book.bookUrl).toSet();
    if (visibleUrls.isEmpty) return;

    setState(() {
      final allSelected =
          visibleUrls.every((url) => _selectedBookUrls.contains(url));
      if (allSelected) {
        _selectedBookUrls.removeAll(visibleUrls);
      } else {
        _selectedBookUrls.addAll(visibleUrls);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedBookUrls.clear();
    });
  }

  List<Book> get _selectedBooks {
    return _books
        .where((book) => _selectedBookUrls.contains(book.bookUrl))
        .toList();
  }

  bool get _allVisibleSelected {
    return _filteredBooks.isNotEmpty &&
        _filteredBooks
            .every((book) => _selectedBookUrls.contains(book.bookUrl));
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedBookUrls.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: hasSelection ? _buildBottomBar(context) : null,
      body: HomePageBackground(
        glowColors: const [Color(0xFF165DFF), Color(0xFF4F7CFF)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context, hasSelection),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadBooks,
                  child: _buildBody(context, hasSelection),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool hasSelection) {
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
                      '书籍管理',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '批量整理书架中的书籍、分组和缓存',
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.tertiaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildHeaderButton(
                context,
                icon:
                    hasSelection ? Icons.close_rounded : Icons.refresh_rounded,
                onTap: hasSelection ? _clearSelection : _loadBooks,
              ),
            ],
          ),
          const SizedBox(height: 16),
          HomeSearchField(
            controller: _searchController,
            hintText: '搜索书名、作者或标签',
            onChanged: _filterBooks,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool hasSelection) {
    if (_isLoading) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 220),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _buildHeroCard(context),
              if (hasSelection) ...[
                const SizedBox(height: 16),
                BookManageActionBar(
                  selectedCount: _selectedBooks.length,
                  totalCount: _books.length,
                  isAllSelected: _allVisibleSelected,
                  onToggleSelectAll: _toggleSelectAllVisible,
                  onClearSelection: _clearSelection,
                  onBatchAction: _handleBatchAction,
                ),
              ],
              const SizedBox(height: 18),
              _buildSectionLabel(
                context,
                title: _searchController.text.trim().isEmpty ? '书籍列表' : '搜索结果',
                subtitle: _searchController.text.trim().isEmpty
                    ? '长按书卡进入多选，轻点可查看详情'
                    : '当前关键字：${_searchController.text.trim()}',
              ),
              const SizedBox(height: 10),
            ]),
          ),
        ),
        if (_filteredBooks.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverToBoxAdapter(
              child: HomeSectionCard(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Icon(
                      Icons.menu_book_outlined,
                      size: 52,
                      color: HomePalette.tertiaryText(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.trim().isNotEmpty
                          ? '没有找到匹配的书籍'
                          : '暂无书籍',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _searchController.text.trim().isNotEmpty
                          ? '换个关键词再试试'
                          : '当前分组里还没有可管理的书籍',
                      style: TextStyle(
                        color: HomePalette.secondaryText(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final book = _filteredBooks[index];
                  return BookManageItem(
                    book: book,
                    isSelected: _selectedBookUrls.contains(book.bookUrl),
                    onTap: () {
                      if (hasSelection) {
                        _toggleSelection(book.bookUrl);
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookInfoPage(
                              key: ValueKey('book_info_${book.bookUrl}'),
                              bookUrl: book.bookUrl,
                            ),
                          ),
                        );
                      }
                    },
                    onLongPress: () => _toggleSelection(book.bookUrl),
                    onDeleted: () async {
                      _selectedBookUrls.remove(book.bookUrl);
                      await _loadBooks();
                    },
                  );
                },
                childCount: _filteredBooks.length,
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(height: hasSelection ? 120 : 90),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF165DFF), Color(0xFF4F7CFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF165DFF).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '批量整理书架',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '把多选、分组移动、更新策略和缓存清理集中到一个入口，减少零散操作。',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMetricCard(value: '${_books.length}', label: '书籍'),
              const SizedBox(width: 10),
              _buildMetricCard(value: '${_selectedBooks.length}', label: '已选'),
              const SizedBox(width: 10),
              _buildMetricCard(
                value: _searchController.text.trim().isEmpty ? '全部' : '筛选中',
                label: '范围',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
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

  Widget _buildSectionLabel(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: HomePalette.primaryText(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: HomePalette.tertiaryText(context),
            ),
          ),
        ],
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

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 22),
        decoration: BoxDecoration(
          color: HomePalette.card(context).withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(color: HomePalette.lineColor(context)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _BottomActionItem(
                icon: Icons.swap_horiz_rounded,
                label: '移动',
                color: HomePalette.accent,
                onTap: () => _handleBatchAction(BatchAction.moveToGroup),
              ),
            ),
            Expanded(
              child: _BottomActionItem(
                icon: Icons.folder_copy_outlined,
                label: '加组',
                color: HomePalette.accent,
                onTap: () => _handleBatchAction(BatchAction.addToGroup),
              ),
            ),
            Expanded(
              child: _BottomActionItem(
                icon: Icons.layers_clear_rounded,
                label: '缓存',
                color: HomePalette.accent,
                onTap: () => _handleBatchAction(BatchAction.clearCache),
              ),
            ),
            Expanded(
              child: _BottomActionItem(
                icon: Icons.delete_outline_rounded,
                label: '删除',
                color: const Color(0xFFF53F3F),
                onTap: () => _handleBatchAction(BatchAction.delete),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBatchAction(BatchAction action) async {
    final selectedBooks = _selectedBooks;
    if (selectedBooks.isEmpty) return;

    switch (action) {
      case BatchAction.delete:
        await _batchDelete(selectedBooks);
        break;
      case BatchAction.moveToGroup:
        await _batchMoveToGroup(selectedBooks);
        break;
      case BatchAction.addToGroup:
        await _batchAddToGroup(selectedBooks);
        break;
      case BatchAction.clearCache:
        await _batchClearCache(selectedBooks);
        break;
      case BatchAction.enableUpdate:
        await _batchUpdateCanUpdate(selectedBooks, true);
        break;
      case BatchAction.disableUpdate:
        await _batchUpdateCanUpdate(selectedBooks, false);
        break;
    }
  }

  Future<void> _batchDelete(List<Book> books) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${books.length} 本书籍吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      for (final book in books) {
        await readService(AppServices.bookService).deleteBook(book.bookUrl);
      }

      _clearSelection();
      await _loadBooks();
      _showMessage('已删除 ${books.length} 本书籍');
    } catch (e) {
      _showMessage('删除失败: $e');
    }
  }

  Future<void> _batchMoveToGroup(List<Book> books) async {
    final groups = await readService(AppServices.bookGroupService).getAllGroups();
    final selectedGroup = await _pickGroup(groups, title: '选择分组');
    if (selectedGroup == null) return;

    try {
      for (final book in books) {
        await readService(AppServices.bookService).updateBookGroup(
          book.bookUrl,
          selectedGroup.groupId,
        );
      }

      _clearSelection();
      await _loadBooks();
      _showMessage('已移动到分组');
    } catch (e) {
      _showMessage('移动失败: $e');
    }
  }

  Future<void> _batchAddToGroup(List<Book> books) async {
    final groups = await readService(AppServices.bookGroupService).getAllGroups();
    final selectedGroup = await _pickGroup(groups, title: '添加到分组');
    if (selectedGroup == null) return;

    try {
      for (final book in books) {
        await readService(AppServices.bookService).updateBookGroup(
          book.bookUrl,
          selectedGroup.groupId,
        );
      }

      _clearSelection();
      await _loadBooks();
      _showMessage('已添加到分组');
    } catch (e) {
      _showMessage('添加失败: $e');
    }
  }

  Future<BookGroup?> _pickGroup(
    List<BookGroup> groups, {
    required String title,
  }) {
    return showDialog<BookGroup>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                title: Text(group.groupName),
                onTap: () => Navigator.of(context).pop(group),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _batchClearCache(List<Book> books) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: Text('确定要清除选中 ${books.length} 本书籍的缓存吗？'),
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

    try {
      for (final book in books) {
        await readService(AppServices.cacheService).clearBookCache(book);
      }

      _clearSelection();
      _showMessage('已清除 ${books.length} 本书籍的缓存');
    } catch (e) {
      _showMessage('清除缓存失败: $e');
    }
  }

  Future<void> _batchUpdateCanUpdate(List<Book> books, bool canUpdate) async {
    try {
      for (final book in books) {
        await readService(AppServices.bookService).updateBook(
          book.copyWith(canUpdate: canUpdate),
        );
      }

      _clearSelection();
      await _loadBooks();
      _showMessage('已${canUpdate ? '启用' : '禁用'}更新');
    } catch (e) {
      _showMessage('操作失败: $e');
    }
  }
}

class _BottomActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BottomActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: HomePalette.secondaryText(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
