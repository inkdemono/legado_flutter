import 'package:flutter/material.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/book_source.dart';
import '../../../data/models/explore_kind.dart';
import '../../../services/source/book_source_service.dart';
import '../../../services/explore_service.dart';
import '../../../providers/scroll_control_provider.dart';
import '../book_source/book_source_edit_page.dart';
import '../book_source/book_source_manage_page.dart';
import '../book_source/source_login_page.dart';
import 'explore_show_page.dart';
import '../search/search_page.dart';
import '../../widgets/home/home_shell.dart';

/// 发现页面
class ExplorePage extends ConsumerStatefulWidget {
  final bool embedded;

  const ExplorePage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<BookSource> _bookSources = [];
  List<String> _groups = [];
  bool _isLoading = true;
  String? _searchKeyword;
  String? _selectedGroup;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 滚动到顶部（压缩发现列表）
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
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 加载分组
      final groups = await readService(AppServices.bookSourceService).getExploreGroups();

      // 加载书源
      List<BookSource> sources;
      if (_searchKeyword != null && _searchKeyword!.isNotEmpty) {
        // 优先处理搜索
        sources = await readService(AppServices.bookSourceService)
            .searchExploreBookSources(_searchKeyword!);
      } else if (_selectedGroup != null && _selectedGroup!.isNotEmpty) {
        // 按分组筛选
        sources = await readService(AppServices.bookSourceService)
            .getExploreBookSourcesByGroup(_selectedGroup!);
      } else {
        // 全部分组
        sources =
            await readService(AppServices.bookSourceService).getEnabledExploreBookSources();
      }

      setState(() {
        _groups = groups;
        _bookSources = sources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchKeyword = value.isEmpty ? null : value;
    });
    _loadData();
  }

  void _onGroupSelected(String? group) {
    setState(() {
      _selectedGroup = group;
      _searchKeyword = null;
      _searchController.clear();
      _expandedIndex = null; // 切换分组时折叠所有展开的项
    });
    _loadData();
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndex == index) {
        // 折叠
        _expandedIndex = null;
      } else {
        // 展开
        _expandedIndex = index;
      }
    });
  }

  void _openExplore(BookSource source, String title, String exploreUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExploreShowPage(
          bookSource: source,
          exploreName: title,
          exploreUrl: exploreUrl,
        ),
      ),
    );
  }

  void _editSource(BookSource source) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => BookSourceEditPage(bookSource: source),
          ),
        )
        .then((_) => _loadData());
  }

  Future<void> _topSource(BookSource source) async {
    try {
      final minOrder = await readService(AppServices.bookSourceService).getMinOrder();
      await readService(AppServices.bookSourceService).updateBookSource(
        source.copyWith(customOrder: minOrder - 1),
      );
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('置顶失败: $e')),
        );
      }
    }
  }

  void _openSourceManagePage() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const BookSourceManagePage(),
          ),
        )
        .then((_) => _loadData());
  }

  Future<void> _deleteSource(BookSource source) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除书源'),
        content: Text('确定要删除书源 "${source.bookSourceName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await readService(AppServices.bookSourceService).deleteBookSource(source.bookSourceUrl);
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }

  Future<void> _refreshExploreKinds(int index) async {
    final source = _bookSources[index];
    await readService(AppServices.exploreService).clearExploreKindsCache(source);
    // 如果当前项是展开的，重新展开以刷新数据
    if (_expandedIndex == index) {
      setState(() {
        _expandedIndex = null;
      });
      // 延迟一下再展开，确保 FutureBuilder 重新构建
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _expandedIndex = index;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 监听滚动控制Provider
    ref.listen(exploreScrollControlProvider, (previous, next) {
      if (next > 0 && mounted) {
        _scrollToTop();
      }
    });

    final content = Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, widget.embedded ? 8 : 4, 16, 10),
          child: Column(
            children: [
              if (widget.embedded)
                _buildEmbeddedSearchField()
              else
                Row(
                  children: [
                    Expanded(
                      child: HomeSearchField(
                        controller: _searchController,
                        hintText: '搜索书源或分类',
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      context,
                      icon: Icons.search_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SearchPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              SizedBox(
                height: 34,
                child: ListView(
                  key: const PageStorageKey<String>('explore_group_list'),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildGroupChip(
                      context,
                      label: '全部分组',
                      selected: _selectedGroup == null,
                      onTap: () => _onGroupSelected(null),
                    ),
                    ..._groups.map(
                      (group) => _buildGroupChip(
                        context,
                        label: group,
                        selected: _selectedGroup == group,
                        onTap: () => _onGroupSelected(group),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildSourceList()),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedGroup == null ? '发现' : '发现 · $_selectedGroup'),
      ),
      body: content,
    );
  }

  Widget _buildEmbeddedSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: HomePalette.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HomePalette.lineColor(context)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textAlignVertical: const TextAlignVertical(y: -0.15),
        style: TextStyle(
          color: HomePalette.primaryText(context),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.0,
        ),
        decoration: InputDecoration(
          hintText: '搜索书源',
          isDense: true,
          hintStyle: TextStyle(
            color: HomePalette.tertiaryText(context),
            height: 1.0,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: HomePalette.tertiaryText(context),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: HomePalette.tertiaryText(context),
                  ),
                )
              : IconButton(
                  onPressed: _openSourceManagePage,
                  icon: Icon(
                    Icons.segment_rounded,
                    color: HomePalette.tertiaryText(context),
                  ),
                ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 44, minHeight: 44),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 44, minHeight: 44),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        ),
      ),
    );
  }

  Widget _buildSourceList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookSources.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.explore_off_rounded,
                size: 64,
                color: HomePalette.tertiaryText(context),
              ),
              const SizedBox(height: 16),
              Text(
                _searchKeyword != null || _selectedGroup != null
                    ? '没有找到符合条件的书源'
                    : '暂无启用发现的书源',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HomePalette.secondaryText(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey<String>('explore_source_list'),
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _bookSources.length,
      itemBuilder: (context, index) {
        final source = _bookSources[index];
        final isExpanded = _expandedIndex == index;

        return HomeSectionCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => _toggleExpand(index),
                onLongPress: () => _showSourceMenu(context, source, index),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _cardGradient(index),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              source.bookSourceName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: HomePalette.primaryText(context),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              source.bookSourceGroup?.isNotEmpty == true
                                  ? source.bookSourceGroup!
                                  : '未分组来源',
                              style: TextStyle(
                                fontSize: 12,
                                color: HomePalette.tertiaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.chevron_right_rounded,
                        color: HomePalette.tertiaryText(context),
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                FutureBuilder<List<ExploreKind>>(
                  key: ValueKey('${source.bookSourceUrl}_$_expandedIndex'),
                  future: readService(AppServices.exploreService).getExploreKinds(source),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          '加载失败: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final kinds = snapshot.data ?? [];
                    if (kinds.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          '暂无发现分类',
                          style: TextStyle(
                            color: HomePalette.tertiaryText(context),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: _buildKindChips(kinds, source),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: HomePalette.card(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomePalette.lineColor(context)),
          ),
          child: Icon(icon, color: HomePalette.primaryText(context)),
        ),
      ),
    );
  }

  Widget _buildGroupChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? HomePalette.accent : HomePalette.card(context),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? HomePalette.accent
                  : HomePalette.lineColor(context),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color:
                  selected ? Colors.white : HomePalette.secondaryText(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _cardGradient(int index) {
    const gradients = [
      [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
      [Color(0xFFFB7185), Color(0xFFFF7AA5)],
      [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
      [Color(0xFF34D399), Color(0xFF14B8A6)],
    ];
    return gradients[index % gradients.length];
  }

  /// 构建分类标签（支持 FlexChildStyle 样式）
  Widget _buildKindChips(List<ExploreKind> kinds, BookSource source) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final List<Widget> sections = [];
    final List<ExploreKind> clickableKinds = [];

    for (final kind in kinds) {
      final title = kind.title;
      final url = kind.url;
      final style = kind.getStyle();

      if (title.startsWith('ERROR:')) {
        sections.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSectionLabel(
              title,
              backgroundColor: colorScheme.errorContainer,
              textColor: colorScheme.onErrorContainer,
              textStyle: textTheme.bodyMedium,
            ),
          ),
        );
      } else if (url == null || url.isEmpty) {
        if (clickableKinds.isNotEmpty) {
          sections.add(_buildCategoryGrid(
              source, List<ExploreKind>.from(clickableKinds)));
          clickableKinds.clear();
        }
        sections.add(
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 10),
            child: _buildCategoryButton(
              source,
              title,
              '',
              isSectionTitle: true,
            ),
          ),
        );
      } else {
        if (style.isFullWidth && clickableKinds.isNotEmpty) {
          sections.add(_buildCategoryGrid(
              source, List<ExploreKind>.from(clickableKinds)));
          clickableKinds.clear();
        }
        clickableKinds.add(kind);
      }
    }

    if (clickableKinds.isNotEmpty) {
      sections.add(
          _buildCategoryGrid(source, List<ExploreKind>.from(clickableKinds)));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.65)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '分类导航',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${kinds.length} 项',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...sections,
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BookSource source, List<ExploreKind> kinds) {
    const crossAxisCount = 4;
    const spacing = 10.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalSpacing = spacing * (crossAxisCount - 1);
          final itemWidth =
              (constraints.maxWidth - totalSpacing) / crossAxisCount;

          final rows = <Widget>[];
          for (int i = 0; i < kinds.length; i += crossAxisCount) {
            final rowKinds = kinds.skip(i).take(crossAxisCount).toList();
            rows.add(
              Padding(
                padding: EdgeInsets.only(
                  bottom: i + crossAxisCount < kinds.length ? spacing : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(rowKinds.length, (index) {
                    final kind = rowKinds[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == rowKinds.length - 1 ? 0 : spacing,
                      ),
                      child: SizedBox(
                        width: itemWidth,
                        child: _buildCategoryButton(
                          source,
                          kind.title,
                          kind.url!,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          }
          return Column(children: rows);
        },
      ),
    );
  }

  Widget _buildSectionLabel(
    String title, {
    required Color backgroundColor,
    required Color textColor,
    TextStyle? textStyle,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: textColor.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: textStyle?.copyWith(color: textColor) ??
            TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _buildCategoryButton(
    BookSource source,
    String title,
    String url, {
    bool isSectionTitle = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color:
          isSectionTitle ? colorScheme.primaryContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSectionTitle
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surfaceBright,
                    colorScheme.surfaceContainerHigh,
                  ],
                ),
          boxShadow: isSectionTitle
              ? null
              : [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isSectionTitle ? null : () => _openExplore(source, title, url),
          child: Container(
            constraints: BoxConstraints(
              minHeight: isSectionTitle ? 40 : 34,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isSectionTitle ? 10 : 8,
              vertical: isSectionTitle ? 10 : 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSectionTitle
                    ? colorScheme.primary.withValues(alpha: 0.18)
                    : colorScheme.outlineVariant.withValues(alpha: 0.8),
              ),
            ),
            child: Center(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: isSectionTitle
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                  fontWeight:
                      isSectionTitle ? FontWeight.w800 : FontWeight.w700,
                  height: isSectionTitle ? 1.2 : 1.1,
                  letterSpacing: 0.1,
                  fontSize: isSectionTitle ? null : 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSourceMenu(BuildContext context, BookSource source, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                _editSource(source);
              },
            ),
            ListTile(
              leading: const Icon(Icons.vertical_align_top),
              title: const Text('置顶'),
              onTap: () {
                Navigator.pop(context);
                _topSource(source);
              },
            ),
            if (source.loginUrl != null && source.loginUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('登录'),
                onTap: () {
                  Navigator.pop(context);
                  _showLoginPage(source);
                },
              ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('刷新分类'),
              onTap: () {
                Navigator.pop(context);
                _refreshExploreKinds(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('删除'),
              onTap: () {
                Navigator.pop(context);
                _deleteSource(source);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示登录页面
  void _showLoginPage(BookSource source) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SourceLoginPage(
          sourceUrl: source.bookSourceUrl,
        ),
      ),
    );
  }
}
