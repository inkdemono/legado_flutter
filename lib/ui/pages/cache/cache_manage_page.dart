import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/book.dart';
import '../../../services/book/book_service.dart';
import '../../../services/reader/cache_service.dart';
import '../../widgets/home/home_shell.dart';
import 'cache_book_item.dart';

/// 缓存管理页面
class CacheManagePage extends ConsumerStatefulWidget {
  const CacheManagePage({super.key});

  @override
  ConsumerState<CacheManagePage> createState() => _CacheManagePageState();
}

class _CacheManagePageState extends ConsumerState<CacheManagePage> {
  List<Book> _books = [];
  Map<String, CacheInfo> _cacheInfoMap = {};
  bool _isLoading = true;
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _loadBooks();
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
          ? await BookService.instance.getBooksByGroup(_selectedGroupId!)
          : await BookService.instance.getBookshelfBooks();

      final filteredBooks = books.where((book) => !book.isLocal).toList();

      final cacheInfoMap = <String, CacheInfo>{};
      for (final book in filteredBooks) {
        final chapters = await BookService.instance.getChapterList(book);
        final cachedFiles =
            await CacheService.instance.getCachedChapterFiles(book);
        final cachedCount =
            await CacheService.instance.getCachedChapterCount(book, chapters);

        cacheInfoMap[book.bookUrl] = CacheInfo(
          totalChapters: chapters.length,
          cachedChapters: cachedCount,
          cachedFiles: cachedFiles,
        );
      }

      if (!mounted) return;
      setState(() {
        _books = filteredBooks;
        _cacheInfoMap = cacheInfoMap;
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

  Future<void> _clearAllCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除所有缓存吗？此操作不可恢复。'),
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
      _isLoading = true;
    });

    try {
      await CacheService.instance.clearAllCache();
      await _loadBooks();
      _showMessage('已清除所有缓存');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showMessage('清除缓存失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalChapters = 0;
    int cachedChapters = 0;
    int totalFiles = 0;

    for (final info in _cacheInfoMap.values) {
      totalChapters += info.totalChapters;
      cachedChapters += info.cachedChapters;
      totalFiles += info.cachedFiles.length;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF34D399), Color(0xFF14B8A6)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadBooks,
                  child: _buildBody(
                    context,
                    totalChapters: totalChapters,
                    cachedChapters: cachedChapters,
                    totalFiles: totalFiles,
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
      child: Row(
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
                  '缓存管理',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '查看缓存覆盖率并快速清理已下载章节',
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
            icon: Icons.refresh_rounded,
            onTap: _loadBooks,
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: '更多操作',
            offset: const Offset(0, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
            onSelected: (value) {
              if (value == 'clear_all') {
                _clearAllCache();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('清除所有缓存'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required int totalChapters,
    required int cachedChapters,
    required int totalFiles,
  }) {
    if (_isLoading) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 220),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    final progress = totalChapters > 0 ? cachedChapters / totalChapters : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _buildHeroCard(
          context,
          totalBooks: _books.length,
          totalChapters: totalChapters,
          cachedChapters: cachedChapters,
          totalFiles: totalFiles,
          progress: progress,
        ),
        const SizedBox(height: 18),
        _buildSectionHeader(
          context,
          title: '书籍缓存',
          subtitle: _books.isEmpty ? '当前没有可管理的在线书籍' : '长按或点右上角菜单可导出、缓存或清理单本书籍',
        ),
        const SizedBox(height: 10),
        if (_books.isEmpty)
          HomeSectionCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.folder_off_rounded,
                  size: 52,
                  color: HomePalette.tertiaryText(context),
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无可缓存书籍',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '本地书籍不会出现在这里，在线书籍开始阅读后即可缓存章节',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: HomePalette.secondaryText(context)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        else
          ..._books.map((book) => CacheBookItem(
                book: book,
                cacheInfo: _cacheInfoMap[book.bookUrl],
                onCacheCleared: _loadBooks,
              )),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required int totalBooks,
    required int totalChapters,
    required int cachedChapters,
    required int totalFiles,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF34D399), Color(0xFF14B8A6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '缓存覆盖率',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMetricCard(value: '$totalBooks', label: '书籍'),
              const SizedBox(width: 10),
              _buildMetricCard(
                value: '$cachedChapters/$totalChapters',
                label: '章节',
              ),
              const SizedBox(width: 10),
              _buildMetricCard(value: '$totalFiles', label: '文件'),
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
          color: Colors.white.withValues(alpha: 0.18),
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

  Widget _buildSectionHeader(
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
}

/// 缓存信息
class CacheInfo {
  final int totalChapters;
  final int cachedChapters;
  final Set<String> cachedFiles;

  CacheInfo({
    required this.totalChapters,
    required this.cachedChapters,
    required this.cachedFiles,
  });

  double get progress {
    if (totalChapters == 0) return 0.0;
    return cachedChapters / totalChapters;
  }
}
