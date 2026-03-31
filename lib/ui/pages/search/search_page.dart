import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../config/app_config.dart';
import '../../../data/models/book.dart';
import '../../../data/models/book_source.dart';
import '../../../services/book/book_service.dart';
import '../../../services/book/search_model.dart';
import '../../../services/source/book_source_service.dart';
import '../../../services/search_keyword_service.dart';
import '../../../utils/search_scope.dart';
import '../../../providers/book_provider.dart';
import '../../widgets/book/book_card.dart';
import '../../widgets/home/home_shell.dart';
import '../bookshelf/book_info/book_info_page.dart';
import 'search_scope_dialog.dart';

/// 搜索页面
class SearchPage extends ConsumerStatefulWidget {
  final String? initialKeyword;

  const SearchPage({
    super.key,
    this.initialKeyword,
  });

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Book> _searchResults = [];
  List<Book> _filteredResults = [];
  List<String> _searchHistory = [];
  bool _isSearching = false;
  bool _isLoading = false;
  String? _error;

  // 搜索任务标识（用于在后台继续搜索）
  int _searchTaskId = 0;

  // 搜索模型（独立的搜索引擎）
  SearchModel? _searchModel;

  // 搜索范围
  SearchScope? _searchScope;

  // 筛选条件
  String _filterText = '';

  // 精确搜索模式
  bool _precisionSearch = false;

  // 搜索历史排序方式（0=时间，1=使用次数）
  int _historySortMode = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSearchModel();
    _precisionSearch = AppConfig.getPrecisionSearch();
    _historySortMode = AppConfig.getSearchHistorySortMode();
    _loadSearchScope();
    if (widget.initialKeyword != null) {
      _searchController.text = widget.initialKeyword!;
      _performSearch(widget.initialKeyword!);
    } else {
      _loadSearchHistory();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchModel?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// 初始化搜索模型
  void _initSearchModel() {
    _searchModel = SearchModel(
      onSearchStart: () {
        // 搜索开始
        scheduleMicrotask(() {
          try {
            if (mounted) {
              setState(() {
                _isSearching = true;
                _isLoading = true;
                _error = null;
                _searchResults = [];
                _filteredResults = [];
              });
            }
          } catch (_) {}
        });
      },
      onSearchSuccess: (books) {
        // 实时更新结果（参考项目的做法）
        scheduleMicrotask(() {
          try {
            if (mounted) {
              setState(() {
                _searchResults = books;
                _applyFilter();
                _isLoading = false; // 有结果后不再显示loading
              });
            }
          } catch (_) {}
        });
      },
      onSearchFinish: (isEmpty) {
        // 搜索完成
        scheduleMicrotask(() {
          try {
            if (mounted) {
              setState(() {
                _isSearching = false;
                _isLoading = false;
              });
            }
          } catch (_) {}
        });
      },
      onSearchCancel: (error) {
        // 搜索取消或出错
        scheduleMicrotask(() {
          try {
            if (mounted) {
              setState(() {
                _isSearching = false;
                _isLoading = false;
                if (error != null) {
                  _error = error.toString();
                }
              });
            }
          } catch (_) {}
        });
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 监听应用生命周期状态变化
    // 不管窗口状态如何变化（inactive/paused/resumed），都不影响搜索任务
    // 搜索任务会在后台继续执行
  }

  Future<void> _loadSearchScope() async {
    _searchScope = await SearchScope.load();
  }

  Future<void> _loadSearchHistory() async {
    List<String> history;
    if (_historySortMode == 1) {
      // 按使用次数排序
      final keywords =
          await SearchKeywordService.instance.getKeywordsByUsage(limit: 20);
      history = keywords.map((k) => k.word).toList();
    } else {
      // 按时间排序（默认）
      history = await SearchKeywordService.instance.getSearchHistory();
    }

    if (mounted) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

  Future<void> _performSearch(String keyword) async {
    final normalizedKeyword = keyword.trim();
    if (normalizedKeyword.isEmpty) {
      _stopSearch();
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
          _filteredResults = [];
          _error = null;
        });
      }
      return;
    }

    // 增加搜索任务ID
    final searchId = ++_searchTaskId;

    // 保存搜索历史
    await SearchKeywordService.instance.saveSearchKeyword(normalizedKeyword);
    if (mounted) {
      await _loadSearchHistory();
    }

    try {
      // 获取要搜索的书源
      List<BookSource>? sources;
      if (_searchScope != null) {
        sources = await _searchScope!.getBookSources();
        if (sources.isEmpty) {
          sources = null;
        }
      }

      sources ??= await BookSourceService.instance.getEnabledBookSources();

      // 使用SearchModel进行后台搜索（完全独立于UI生命周期）
      await _searchModel?.search(
        searchId: searchId,
        keyword: normalizedKeyword,
        sources: sources,
        precisionSearch: _precisionSearch,
      );
    } catch (e) {
      try {
        if (mounted) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
            _isSearching = false;
          });
        }
      } catch (_) {}
    }
  }

  /// 手动停止搜索
  void _stopSearch() {
    _searchTaskId++; // 增加任务ID，使当前搜索任务失效
    _searchModel?.cancelSearch();

    if (mounted) {
      setState(() {
        _isSearching = false;
        _isLoading = false;
      });
    }
  }

  void _showSearchScopeDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SearchScopeDialog(
        onScopeSelected: (sources, groups) {
          Navigator.of(context).pop({
            'sources': sources,
            'groups': groups,
          });
        },
      ),
    );

    if (result != null && mounted) {
      final sources = result['sources'] as List<BookSource>?;
      final groups = result['groups'] as List<String>?;

      // 更新SearchScope
      if (sources != null && sources.isNotEmpty) {
        if (sources.length == 1) {
          _searchScope = SearchScope.fromSource(sources.first);
        } else {
          // 多个书源，使用第一个作为代表（或创建新的范围管理）
          _searchScope = SearchScope.fromSource(sources.first);
        }
      } else if (groups != null && groups.isNotEmpty) {
        _searchScope = SearchScope.fromGroups(groups);
      } else {
        _searchScope = SearchScope(); // 全部书源
      }

      _searchScope?.update(_searchScope!.toString());

      setState(() {});

      // 如果有搜索关键词，重新搜索
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch(_searchController.text.trim());
      }
    }
  }

  void _showBookInfo(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookInfoPage(
          key: ValueKey('book_info_${book.bookUrl}'),
          bookUrl: book.bookUrl,
          bookName: book.name,
          author: book.author,
          sourceUrl: book.origin,
          coverUrl: book.displayCover,
          intro: book.displayIntro,
          initialInfoHtml: book.infoHtml,
          initialVariable: book.variable,
        ),
      ),
    );
  }

  /// 显示书籍快速操作菜单
  void _showBookQuickActions(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('查看详情'),
              onTap: () {
                Navigator.pop(context);
                _showBookInfo(book);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('加入书架'),
              onTap: () async {
                Navigator.pop(context);
                await _addBookToShelf(book);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享'),
              onTap: () {
                Navigator.pop(context);
                _shareBook(book);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 添加书籍到书架
  Future<void> _addBookToShelf(Book book) async {
    try {
      // 如果书籍不是本地书籍，需要先获取章节列表
      if (!book.isLocal) {
        try {
          final chapters = await BookService.instance.getChapterList(book);
          if (chapters.isNotEmpty) {
            await BookService.instance.saveChapters(chapters);
          }
        } catch (e) {
          // 章节列表获取失败不影响添加书籍
        }
      }

      // 保存书籍
      await BookService.instance.createBook(book);

      // 刷新书架 Provider
      ref.invalidate(refreshBookshelfProvider);
      ref.invalidate(bookshelfBooksProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已添加到书架')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    }
  }

  /// 分享书籍
  void _shareBook(Book book) {
    final shareText =
        '《${book.name}》\n作者：${book.author}\n来源：${book.originName}\n链接：${book.bookUrl}';
    SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: book.name,
      ),
    );
  }

  void _applyFilter() {
    if (_filterText.isEmpty) {
      _filteredResults = _searchResults;
    } else {
      final query = _filterText.toLowerCase();
      _filteredResults = _searchResults.where((book) {
        return book.name.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query) ||
            book.originName.toLowerCase().contains(query);
      }).toList();
    }

    // 如果启用精确搜索模式，进一步过滤结果
    if (_precisionSearch && _searchController.text.trim().isNotEmpty) {
      final keyword = _searchController.text.trim().toLowerCase();
      _filteredResults = _filteredResults.where((book) {
        return book.name.toLowerCase() == keyword ||
            book.author.toLowerCase() == keyword ||
            (book.name.toLowerCase().contains(keyword) &&
                book.author.toLowerCase().contains(keyword));
      }).toList();
    }
  }

  void _showFilterDialog() {
    final controller = TextEditingController(text: _filterText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选搜索结果'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入书名、作者或来源',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clear();
            },
            child: const Text('清空'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _filterText = controller.text.trim();
                _applyFilter();
              });
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _getScopeText() {
    if (_searchScope != null) {
      return _searchScope!.display;
    }
    return '全部书源';
  }

  void _clearSearch() {
    _stopSearch();
    _searchController.clear();
    _searchFocusNode.requestFocus();
    setState(() {
      _error = null;
      _filterText = '';
      _searchResults = [];
      _filteredResults = [];
    });
    _loadSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF22C55E), Color(0xFF14B8A6)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _isSearching || _searchResults.isNotEmpty
                    ? _buildSearchResults()
                    : _buildSearchHistory(),
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
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '全局搜索',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isSearching ? '搜索中，结果会持续追加' : '跨书源找书，支持范围与精确搜索',
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.tertiaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildMoreMenu(context),
            ],
          ),
          const SizedBox(height: 16),
          HomeSectionCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            color: HomePalette.card(context).withValues(alpha: 0.96),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF14B8A6).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.manage_search_rounded,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        autofocus: widget.initialKeyword == null,
                        textInputAction: TextInputAction.search,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: HomePalette.primaryText(context),
                        ),
                        decoration: InputDecoration(
                          hintText: '输入书名、作者或关键词',
                          hintStyle: TextStyle(
                            color: HomePalette.tertiaryText(context),
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (value) {
                          _searchFocusNode.unfocus();
                          _performSearch(value);
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: _clearSearch,
                        icon: Icon(
                          Icons.close_rounded,
                          color: HomePalette.tertiaryText(context),
                        ),
                        tooltip: '清空',
                      ),
                    FilledButton(
                      onPressed: () {
                        _searchFocusNode.unfocus();
                        _performSearch(_searchController.text.trim());
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: HomePalette.accentStrong,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(58, 42),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Icon(Icons.search_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildActionChip(
                      context,
                      icon: Icons.filter_alt_outlined,
                      label: _getScopeText(),
                      onTap: _showSearchScopeDialog,
                    ),
                    _buildActionChip(
                      context,
                      icon: Icons.gps_fixed_rounded,
                      label: '精确搜索',
                      active: _precisionSearch,
                      onTap: () {
                        setState(() {
                          _precisionSearch = !_precisionSearch;
                          _applyFilter();
                        });
                        AppConfig.setPrecisionSearch(_precisionSearch);
                      },
                    ),
                    if (_searchResults.isNotEmpty)
                      _buildActionChip(
                        context,
                        icon: Icons.tune_rounded,
                        label:
                            _filterText.isEmpty ? '筛选结果' : '筛选: $_filterText',
                        active: _filterText.isNotEmpty,
                        onTap: _showFilterDialog,
                      ),
                    if (_isSearching)
                      _buildActionChip(
                        context,
                        icon: Icons.stop_circle_outlined,
                        label: '停止搜索',
                        active: true,
                        activeColor: const Color(0xFFE34D59),
                        onTap: _stopSearch,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
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
          child: Icon(
            icon,
            size: 18,
            color: HomePalette.primaryText(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '更多选项',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: HomePalette.card(context),
      icon: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: HomePalette.card(context).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HomePalette.lineColor(context)),
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          color: HomePalette.primaryText(context),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'precision_search',
          child: Row(
            children: [
              Icon(
                _precisionSearch
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Text('精确搜索'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'history_sort_time',
          child: Row(
            children: [
              Icon(
                _historySortMode == 0
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Text('历史按时间排序'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'history_sort_usage',
          child: Row(
            children: [
              Icon(
                _historySortMode == 1
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Text('历史按热度排序'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'precision_search') {
          setState(() {
            _precisionSearch = !_precisionSearch;
            _applyFilter();
          });
          AppConfig.setPrecisionSearch(_precisionSearch);
        } else if (value == 'history_sort_time') {
          setState(() {
            _historySortMode = 0;
          });
          AppConfig.setSearchHistorySortMode(0);
          _loadSearchHistory();
        } else if (value == 'history_sort_usage') {
          setState(() {
            _historySortMode = 1;
          });
          AppConfig.setSearchHistorySortMode(1);
          _loadSearchHistory();
        }
      },
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
    Color? activeColor,
  }) {
    final accent = activeColor ?? HomePalette.accentStrong;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? accent.withValues(alpha: 0.12)
                : HomePalette.mutedCard(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active
                  ? accent.withValues(alpha: 0.22)
                  : HomePalette.lineColor(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? accent : HomePalette.secondaryText(context),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? accent : HomePalette.secondaryText(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _buildGuideCard(),
          const SizedBox(height: 16),
          _buildStateCard(
            icon: Icons.search_off_rounded,
            title: '还没有搜索历史',
            message: '输入关键词后即可跨书源搜索，后续会在这里保留你的最近记录。',
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _buildGuideCard(),
        const SizedBox(height: 16),
        HomeSectionCard(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeSectionTitle(
                title: '最近搜索',
                subtitle: _historySortMode == 0 ? '按时间排序' : '按热度排序',
                trailing: TextButton(
                  onPressed: _clearHistory,
                  child: const Text('清空'),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _searchHistory
                    .take(12)
                    .map(
                      (keyword) => InkWell(
                        onTap: () {
                          _searchController.text = keyword;
                          _performSearch(keyword);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: HomePalette.mutedCard(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: HomePalette.lineColor(context),
                            ),
                          ),
                          child: Text(
                            keyword,
                            style: TextStyle(
                              color: HomePalette.secondaryText(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        HomeSectionCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(_searchHistory.length, (index) {
              final keyword = _searchHistory[index];
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: HomePalette.accentSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        size: 18,
                        color: HomePalette.accentStrong,
                      ),
                    ),
                    title: Text(
                      keyword,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    subtitle: Text(
                      '点击再次搜索',
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.tertiaryText(context),
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () async {
                        await SearchKeywordService.instance
                            .deleteSearchHistory(keyword);
                        await _loadSearchHistory();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: HomePalette.tertiaryText(context),
                      ),
                      tooltip: '删除',
                    ),
                    onTap: () {
                      _searchController.text = keyword;
                      _performSearch(keyword);
                    },
                  ),
                  if (index != _searchHistory.length - 1)
                    Divider(
                      height: 1,
                      indent: 68,
                      endIndent: 16,
                      color: HomePalette.lineColor(context),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCard() {
    return HomeSectionCard(
      margin: EdgeInsets.zero,
      color: HomePalette.mutedCard(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '搜索建议',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '优先输入书名或作者；如书源较多，先缩小搜索范围会更快。',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: HomePalette.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF22C55E), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.travel_explore_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              '书名精确匹配优先',
              '支持分组范围搜索',
              '结果会边搜边显示',
            ]
                .map(
                  (text) => _SearchTipChip(label: text),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading && _searchResults.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _buildStateCard(
            icon: Icons.radar_rounded,
            title: '正在搜索',
            message: '已向当前范围内的书源发起请求，结果会实时追加到列表中。',
            action: FilledButton.icon(
              onPressed: _stopSearch,
              icon: const Icon(Icons.stop_rounded),
              label: const Text('停止'),
            ),
          ),
        ],
      );
    }

    if (_error != null && _searchResults.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _buildStateCard(
            icon: Icons.error_outline_rounded,
            title: '搜索失败',
            message: _error!,
            action: FilledButton.icon(
              onPressed: () => _performSearch(_searchController.text.trim()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重试'),
            ),
          ),
        ],
      );
    }

    if (_searchResults.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _buildStateCard(
            icon: Icons.search_off_rounded,
            title: '未找到相关书籍',
            message: '关键词“${_searchController.text}”暂无匹配结果，可以尝试缩短关键词或切换书源范围。',
          ),
        ],
      );
    }

    final widgets = <Widget>[
      if (_isSearching)
        HomeSectionCard(
          margin: EdgeInsets.zero,
          color: HomePalette.mutedCard(context),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: HomePalette.accentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '正在持续搜索中，已找到 ${_searchResults.length} 条结果。',
                  style: TextStyle(
                    fontSize: 13,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
              ),
              TextButton(
                onPressed: _stopSearch,
                child: const Text('停止'),
              ),
            ],
          ),
        ),
      if (_isSearching) const SizedBox(height: 16),
      HomeSectionCard(
        margin: EdgeInsets.zero,
        color: HomePalette.mutedCard(context),
        child: Column(
          children: [
            Row(
              children: [
                _buildMetricCard(
                  '${_filteredResults.length}',
                  '当前结果',
                  const Color(0xFF1677FF),
                ),
                const SizedBox(width: 10),
                _buildMetricCard(
                  '${_searchResults.length}',
                  '总命中',
                  const Color(0xFF22C55E),
                ),
                const SizedBox(width: 10),
                _buildMetricCard(
                  _getScopeText(),
                  '搜索范围',
                  const Color(0xFFF59E0B),
                  compact: true,
                ),
              ],
            ),
            if (_filterText.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: HomePalette.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: HomePalette.lineColor(context)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt_rounded,
                      size: 18,
                      color: HomePalette.accentStrong,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '筛选条件：$_filterText (${_filteredResults.length}/${_searchResults.length})',
                        style: TextStyle(
                          fontSize: 13,
                          color: HomePalette.secondaryText(context),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _filterText = '';
                          _applyFilter();
                        });
                      },
                      child: const Text('清除'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
    ];

    if (_filteredResults.isEmpty) {
      widgets.add(
        _buildStateCard(
          icon: Icons.filter_alt_off_rounded,
          title: '筛选后无结果',
          message: '当前筛选条件过于严格，清除筛选后可以查看全部搜索结果。',
          action: TextButton(
            onPressed: () {
              setState(() {
                _filterText = '';
                _applyFilter();
              });
            },
            child: const Text('清除筛选'),
          ),
        ),
      );
    } else {
      widgets.addAll(
        _filteredResults.map(
          (book) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: BookCard(
              book: book,
              isSearchResult: true,
              highlightKeyword: _searchController.text.trim().isNotEmpty
                  ? _searchController.text.trim()
                  : null,
              onTap: () => _showBookInfo(book),
              onLongPress: () => _showBookQuickActions(context, book),
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: widgets,
    );
  }

  Widget _buildMetricCard(
    String value,
    String label,
    Color color, {
    bool compact = false,
  }) {
    return Expanded(
      child: Container(
        height: compact ? 88 : 94,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: HomePalette.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HomePalette.lineColor(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 13 : 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: HomePalette.tertiaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateCard({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return HomeSectionCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: HomePalette.accentSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                icon,
                size: 32,
                color: HomePalette.accentStrong,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: HomePalette.primaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: HomePalette.secondaryText(context),
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 18),
              action,
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空历史'),
        content: const Text('确定要清空所有搜索历史吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SearchKeywordService.instance.clearSearchHistory();
      await _loadSearchHistory();
    }
  }
}

class _SearchTipChip extends StatelessWidget {
  final String label;

  const _SearchTipChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: HomePalette.card(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HomePalette.lineColor(context)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: HomePalette.secondaryText(context),
        ),
      ),
    );
  }
}
