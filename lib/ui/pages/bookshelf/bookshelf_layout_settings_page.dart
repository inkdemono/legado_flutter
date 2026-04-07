import 'package:flutter/material.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/bookshelf_layout_provider.dart';
import '../../../providers/bookshelf_settings_provider.dart';
import '../../../services/book/book_service.dart';
import '../../widgets/home/home_shell.dart';

/// 书架布局设置页面
class BookshelfLayoutSettingsPage extends ConsumerStatefulWidget {
  const BookshelfLayoutSettingsPage({super.key});

  @override
  ConsumerState<BookshelfLayoutSettingsPage> createState() =>
      _BookshelfLayoutSettingsPageState();
}

class _BookshelfLayoutSettingsPageState
    extends ConsumerState<BookshelfLayoutSettingsPage> {
  late BookshelfSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = ref.read(bookshelfSettingsProvider);
  }

  void _updateSettings(BookshelfSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
  }

  void _onConfirm() {
    final notifier = ref.read(bookshelfSettingsProvider.notifier);

    if (_settings.layoutType != ref.read(bookshelfLayoutProvider)) {
      notifier.updateLayoutType(_settings.layoutType);
    }
    notifier.updateGroupingStyle(_settings.groupingStyle);
    notifier.updateSortType(_settings.sortType);
    notifier.updateShowUnreadMark(_settings.showUnreadMark);
    notifier.updateShowLastUpdateTime(_settings.showLastUpdateTime);
    notifier.updateShowPendingUpdateCount(_settings.showPendingUpdateCount);
    notifier.updateShowQuickScrollBar(_settings.showQuickScrollBar);
    notifier.updateSelectedTag(_settings.selectedTag);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: _buildBottomBar(context),
      body: HomePageBackground(
        glowColors: const [Color(0xFF7B5CFF), Color(0xFF9C7DFF)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    _buildHeroCard(context),
                    const SizedBox(height: 18),
                    _buildSectionLabel(
                      context,
                      title: '分组样式',
                      subtitle: '决定书架在不同维度下的浏览方式',
                    ),
                    const SizedBox(height: 10),
                    _buildValueCard(
                      context,
                      title: '分组方式',
                      description: '在不打断阅读流的前提下快速切换分类维度',
                      value: _getGroupingStyleText(_settings.groupingStyle),
                      onTap: _showGroupingStyleDialog,
                    ),
                    const SizedBox(height: 18),
                    _buildSectionLabel(
                      context,
                      title: '显示选项',
                      subtitle: '控制书架卡片上的补充信息和滚动能力',
                    ),
                    const SizedBox(height: 10),
                    HomeSectionCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Column(
                          children: [
                            _buildSwitchRow(
                              context,
                              title: '显示未读标志',
                              description: '突出最近未打开的书籍',
                              value: _settings.showUnreadMark,
                              onChanged: (value) => _updateSettings(
                                _settings.copyWith(showUnreadMark: value),
                              ),
                            ),
                            _buildDivider(context),
                            _buildSwitchRow(
                              context,
                              title: '显示上次更新时间',
                              description: '适合追更书籍较多的场景',
                              value: _settings.showLastUpdateTime,
                              onChanged: (value) => _updateSettings(
                                _settings.copyWith(showLastUpdateTime: value),
                              ),
                            ),
                            _buildDivider(context),
                            _buildSwitchRow(
                              context,
                              title: '显示等待更新数量',
                              description: '在封面角标上提示待更新章节数',
                              value: _settings.showPendingUpdateCount,
                              onChanged: (value) => _updateSettings(
                                _settings.copyWith(
                                  showPendingUpdateCount: value,
                                ),
                              ),
                            ),
                            _buildDivider(context),
                            _buildSwitchRow(
                              context,
                              title: '显示快速滚动条',
                              description: '适合书架藏书量大的用户',
                              value: _settings.showQuickScrollBar,
                              onChanged: (value) => _updateSettings(
                                _settings.copyWith(showQuickScrollBar: value),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSectionLabel(
                      context,
                      title: '标签筛选',
                      subtitle: '在按标签浏览时保留一个常用筛选入口',
                    ),
                    const SizedBox(height: 10),
                    _buildValueCard(
                      context,
                      title: '当前标签',
                      description: '可选全部或书架中已存在的自定义标签',
                      value: _settings.selectedTag ?? '全部',
                      onTap: _showTagSelectorDialog,
                    ),
                    const SizedBox(height: 18),
                    _buildSectionLabel(
                      context,
                      title: '布局预设',
                      subtitle: '更改书架的卡片密度和浏览节奏',
                    ),
                    const SizedBox(height: 10),
                    _buildLayoutGrid(context),
                    const SizedBox(height: 18),
                    _buildSectionLabel(
                      context,
                      title: '排序',
                      subtitle: '当前排序方式会直接影响书架首页的展示顺序',
                    ),
                    const SizedBox(height: 10),
                    _buildValueCard(
                      context,
                      title: '当前排序',
                      description: _getSortDescription(_settings.sortType),
                      value: _getSortTypeText(_settings.sortType),
                      onTap: _showSortTypeDialog,
                    ),
                    const SizedBox(height: 110),
                  ],
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
            icon: Icons.close_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '书架布局',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '集中管理分组、显示项、布局和排序',
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
            icon: Icons.check_rounded,
            onTap: _onConfirm,
            highlighted: true,
          ),
        ],
      ),
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
          colors: [Color(0xFF7B5CFF), Color(0xFF9C7DFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B5CFF).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '书架浏览策略',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '把分组、布局密度和排序集中到一页，减少多入口跳转带来的操作成本。',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMetricCard(
                value: _getGroupingStyleText(_settings.groupingStyle),
                label: '分组',
              ),
              const SizedBox(width: 10),
              _buildMetricCard(
                value: _getLayoutText(_settings.layoutType),
                label: '布局',
              ),
              const SizedBox(width: 10),
              _buildMetricCard(
                value: _getSortTypeText(_settings.sortType),
                label: '排序',
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
                fontSize: 13,
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

  Widget _buildValueCard(
    BuildContext context, {
    required String title,
    required String description,
    required String value,
    required VoidCallback onTap,
  }) {
    return HomeSectionCard(
      margin: EdgeInsets.zero,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EFFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7B5CFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    BuildContext context, {
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: HomePalette.tertiaryText(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            activeTrackColor: const Color(0xFF7B5CFF).withValues(alpha: 0.36),
            activeThumbColor: const Color(0xFF7B5CFF),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 16, right: 16),
      color: HomePalette.lineColor(context),
    );
  }

  Widget _buildLayoutGrid(BuildContext context) {
    final items = [
      _LayoutOption(
        type: BookshelfLayoutType.list,
        label: '列表布局',
        crossAxisCount: 1,
      ),
      _LayoutOption(
        type: BookshelfLayoutType.grid2,
        label: '2 列网格',
        crossAxisCount: 2,
      ),
      _LayoutOption(
        type: BookshelfLayoutType.grid3,
        label: '3 列网格',
        crossAxisCount: 3,
      ),
      _LayoutOption(
        type: BookshelfLayoutType.grid4,
        label: '4 列网格',
        crossAxisCount: 4,
      ),
      _LayoutOption(
        type: BookshelfLayoutType.grid5,
        label: '5 列网格',
        crossAxisCount: 5,
      ),
      _LayoutOption(
        type: BookshelfLayoutType.grid6,
        label: '6 列网格',
        crossAxisCount: 6,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.02,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = item.type == _settings.layoutType;
        return _LayoutPreviewCard(
          label: item.label,
          crossAxisCount: item.crossAxisCount,
          selected: selected,
          onTap: () =>
              _updateSettings(_settings.copyWith(layoutType: item.type)),
        );
      },
    );
  }

  Future<void> _showTagSelectorDialog() async {
    final allBooks = await readService(AppServices.bookService).getBookshelfBooks();
    final tags = <String>{};
    for (final book in allBooks) {
      if (book.customTag != null && book.customTag!.isNotEmpty) {
        tags.add(book.customTag!);
      }
    }
    final tagList = tags.toList()..sort();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择标签'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOptionTile<String?>(
                  title: '全部',
                  selected: _settings.selectedTag == null,
                  onTap: () {
                    _updateSettings(_settings.copyWith(selectedTag: null));
                    Navigator.pop(context);
                  },
                ),
                ...tagList.map((tag) {
                  return _buildOptionTile<String?>(
                    title: tag,
                    selected: _settings.selectedTag == tag,
                    onTap: () {
                      _updateSettings(_settings.copyWith(selectedTag: tag));
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGroupingStyleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择分组样式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: GroupingStyle.values.map((style) {
            return _buildOptionTile<GroupingStyle>(
              title: _getGroupingStyleText(style),
              selected: _settings.groupingStyle == style,
              onTap: () {
                _updateSettings(_settings.copyWith(groupingStyle: style));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSortTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择排序方式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SortType.values.map((sortType) {
            return _buildOptionTile<SortType>(
              title: _getSortTypeText(sortType),
              selected: _settings.sortType == sortType,
              onTap: () {
                _updateSettings(_settings.copyWith(sortType: sortType));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        decoration: BoxDecoration(
          color: HomePalette.card(context).withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(color: HomePalette.lineColor(context)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _BottomButton(
                label: '取消',
                primary: false,
                onTap: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 13,
              child: _BottomButton(
                label: '应用设置',
                primary: true,
                onTap: _onConfirm,
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
    bool highlighted = false,
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
            color: highlighted
                ? const Color(0xFF7B5CFF).withValues(alpha: 0.12)
                : HomePalette.card(context).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlighted
                  ? const Color(0xFF7B5CFF).withValues(alpha: 0.18)
                  : HomePalette.lineColor(context),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: highlighted
                ? const Color(0xFF7B5CFF)
                : HomePalette.primaryText(context),
          ),
        ),
      ),
    );
  }

  String _getGroupingStyleText(GroupingStyle style) {
    switch (style) {
      case GroupingStyle.none:
        return '不分组';
      case GroupingStyle.byTag:
        return '按标签';
      case GroupingStyle.byAuthor:
        return '按作者';
    }
  }

  String _getLayoutText(BookshelfLayoutType layout) {
    switch (layout) {
      case BookshelfLayoutType.list:
        return '列表';
      case BookshelfLayoutType.grid2:
        return '2 列';
      case BookshelfLayoutType.grid3:
        return '3 列';
      case BookshelfLayoutType.grid4:
        return '4 列';
      case BookshelfLayoutType.grid5:
        return '5 列';
      case BookshelfLayoutType.grid6:
        return '6 列';
    }
  }

  String _getSortTypeText(SortType sortType) {
    switch (sortType) {
      case SortType.byReadTime:
        return '最近阅读';
      case SortType.byUpdateTime:
        return '最近更新';
      case SortType.byBookName:
        return '书名';
      case SortType.manual:
        return '手动排序';
      case SortType.comprehensive:
        return '综合排序';
    }
  }

  String _getSortDescription(SortType sortType) {
    switch (sortType) {
      case SortType.byReadTime:
        return '按最近阅读优先，更贴近阅读行为';
      case SortType.byUpdateTime:
        return '优先展示最近有更新的书籍';
      case SortType.byBookName:
        return '适合按字母或名称快速查找';
      case SortType.manual:
        return '完全尊重你的拖拽排序结果';
      case SortType.comprehensive:
        return '综合阅读、更新和书籍状态排序';
    }
  }

  Widget _buildOptionTile<T>({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: Color(0xFF7B5CFF))
          : null,
      onTap: onTap,
    );
  }
}

class _LayoutOption {
  final BookshelfLayoutType type;
  final String label;
  final int crossAxisCount;

  const _LayoutOption({
    required this.type,
    required this.label,
    required this.crossAxisCount,
  });
}

class _LayoutPreviewCard extends StatelessWidget {
  final String label;
  final int crossAxisCount;
  final bool selected;
  final VoidCallback onTap;

  const _LayoutPreviewCard({
    required this.label,
    required this.crossAxisCount,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isList = crossAxisCount == 1;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF5F2FF) : const Color(0xFFFBFBFD),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7B5CFF).withValues(alpha: 0.38)
                  : const Color(0xFFE5E6EB),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF7B5CFF).withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: HomePalette.primaryText(context),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (isList) {
                      return Column(
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding:
                                EdgeInsets.only(bottom: index == 2 ? 0 : 6),
                            child: Container(
                              height: 28,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF8476FF),
                                    Color(0xFF5C46FF)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final effectiveCount =
                        crossAxisCount > 4 ? 4 : crossAxisCount;
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: effectiveCount == 2 ? 2 : 3,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        childAspectRatio: effectiveCount == 2 ? 1.4 : 0.85,
                      ),
                      itemCount: effectiveCount == 2 ? 4 : 6,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF8476FF), Color(0xFF5C46FF)],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _BottomButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: primary
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7B5CFF), Color(0xFF9C7DFF)],
                  )
                : null,
            color: primary ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: primary ? Colors.transparent : const Color(0xFFE5E6EB),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: primary ? Colors.white : HomePalette.primaryText(context),
            ),
          ),
        ),
      ),
    );
  }
}
