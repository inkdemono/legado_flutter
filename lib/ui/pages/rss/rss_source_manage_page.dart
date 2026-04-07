import 'package:flutter/material.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/rss_source.dart';
import '../../../services/rss_service.dart';
import '../../widgets/home/home_shell.dart';
import 'rss_group_manage_dialog.dart';
import 'rss_source_edit_page.dart';
import 'rss_source_import_dialog.dart';
import 'rss_source_item_widget.dart';

/// RSS源列表Provider
final rssSourceListProvider = FutureProvider<List<RssSource>>((ref) async {
  final service = readService(AppServices.rssService);
  return await service.getAllRssSources();
});

/// RSS源管理页面
class RssSourceManagePage extends ConsumerStatefulWidget {
  const RssSourceManagePage({super.key});

  @override
  ConsumerState<RssSourceManagePage> createState() =>
      _RssSourceManagePageState();
}

class _RssSourceManagePageState extends ConsumerState<RssSourceManagePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isBatchMode = false;
  final Set<String> _selectedUrls = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rssSourcesAsync = ref.watch(rssSourceListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFFFB923C), Color(0xFFEA580C)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: rssSourcesAsync.when(
                  data: (sources) => _buildBody(context, sources),
                  loading: () => ListView(
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 220),
                      Center(child: CircularProgressIndicator()),
                    ],
                  ),
                  error: (error, stack) => ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      _buildHeroCard(context, const []),
                      const SizedBox(height: 18),
                      HomeSectionCard(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Icon(
                              Icons.error_outline_rounded,
                              size: 52,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '加载失败',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: HomePalette.primaryText(context),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$error',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: HomePalette.secondaryText(context),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () =>
                                  ref.invalidate(rssSourceListProvider),
                              child: const Text('重试'),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
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
            icon: _isBatchMode
                ? Icons.close_rounded
                : Icons.arrow_back_ios_new_rounded,
            onTap: () {
              if (_isBatchMode) {
                setState(() {
                  _isBatchMode = false;
                  _selectedUrls.clear();
                });
                return;
              }
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RSS源管理',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isBatchMode ? '批量启用、禁用或删除 RSS 源' : '搜索、分组、启用和排序 RSS 源',
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
            icon: Icons.add_rounded,
            onTap: _openCreatePage,
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            context,
            icon: Icons.file_upload_outlined,
            onTap: _showImportDialog,
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: '更多操作',
            offset: const Offset(0, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            color: HomePalette.card(context),
            onSelected: (value) {
              if (value == 'group') {
                _showGroupManageSheet();
              } else if (value == 'batch') {
                setState(() {
                  _isBatchMode = true;
                });
              }
            },
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
                value: 'group',
                child: Row(
                  children: [
                    Icon(Icons.folder_open_rounded),
                    SizedBox(width: 8),
                    Text('分组管理'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'batch',
                child: Row(
                  children: [
                    Icon(Icons.select_all_rounded),
                    SizedBox(width: 8),
                    Text('批量操作'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<RssSource> sources) {
    final filteredSources = _filterSources(sources, _searchQuery);
    final hasSearch = _searchQuery.trim().isNotEmpty;
    final canReorder = !_isBatchMode && !hasSearch;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _buildHeroCard(context, sources),
        const SizedBox(height: 18),
        HomeSearchField(
          controller: _searchController,
          hintText: '搜索 RSS 源',
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildFilterSummary(context,
            sources: sources, filteredSources: filteredSources),
        if (_isBatchMode) ...[
          const SizedBox(height: 12),
          _buildBatchBar(context),
        ],
        const SizedBox(height: 18),
        _buildSectionHeader(
          context,
          title: 'RSS 源列表',
          subtitle: filteredSources.isEmpty
              ? (_searchQuery.isEmpty ? '当前还没有添加 RSS 源' : '没有匹配当前搜索的 RSS 源')
              : canReorder
                  ? '长按进入批量模式，拖拽手柄可调整顺序'
                  : '搜索或批量状态下已禁用拖拽排序，避免重排过滤后的子集',
        ),
        const SizedBox(height: 10),
        if (filteredSources.isEmpty)
          HomeSectionCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.rss_feed_rounded,
                  size: 52,
                  color: HomePalette.tertiaryText(context),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? '暂无 RSS 源' : '未找到匹配的 RSS 源',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _searchQuery.isEmpty
                      ? '你可以新建 RSS 源，或者从外部文本快速导入现有配置'
                      : '换个关键词再试，或者清空搜索查看全部 RSS 源',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: HomePalette.secondaryText(context)),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed:
                      _searchQuery.isEmpty ? _openCreatePage : _clearSearch,
                  icon: Icon(
                    _searchQuery.isEmpty
                        ? Icons.add_rounded
                        : Icons.close_rounded,
                  ),
                  label: Text(_searchQuery.isEmpty ? '添加 RSS 源' : '清空搜索'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        else if (_isBatchMode)
          ...List.generate(filteredSources.length, (index) {
            final source = filteredSources[index];
            final isSelected = _selectedUrls.contains(source.sourceUrl);
            return RssSourceItemWidget(
              source: source,
              isSelected: isSelected,
              isBatchMode: true,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedUrls.remove(source.sourceUrl);
                  } else {
                    _selectedUrls.add(source.sourceUrl);
                  }
                });
              },
              onToggleEnabled: null,
            );
          })
        else
          ReorderableListView.builder(
            buildDefaultDragHandles: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredSources.length,
            onReorder: canReorder
                ? (oldIndex, newIndex) {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    _handleReorder(filteredSources, oldIndex, newIndex);
                  }
                : (_, __) {},
            itemBuilder: (context, index) {
              final source = filteredSources[index];
              return RssSourceItemWidget(
                key: ValueKey(source.sourceUrl),
                source: source,
                allowReorder: canReorder,
                reorderIndex: index,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RssSourceEditPage(source: source),
                    ),
                  );
                  ref.invalidate(rssSourceListProvider);
                },
                onLongPress: () {
                  setState(() {
                    _isBatchMode = true;
                    _selectedUrls.add(source.sourceUrl);
                  });
                },
                onToggleEnabled: (enabled) async {
                  await readService(AppServices.rssService).updateRssSourceEnabled(
                    source.sourceUrl,
                    enabled,
                  );
                  ref.invalidate(rssSourceListProvider);
                },
              );
            },
          ),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, List<RssSource> sources) {
    final enabledCount = sources.where((source) => source.enabled).length;
    final groupedCount = sources
        .where((source) => (source.sourceGroup ?? '').trim().isNotEmpty)
        .length;
    final singleCount = sources.where((source) => source.singleUrl).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RSS 源概览',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '统一管理订阅入口',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '把搜索、批量模式、启用状态和排序集中在同一页里，方便快速整理长期订阅。',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMetricCard(value: '${sources.length}', label: '全部源'),
              const SizedBox(width: 10),
              _buildMetricCard(value: '$enabledCount', label: '启用'),
              const SizedBox(width: 10),
              _buildMetricCard(
                  value: '$groupedCount/$singleCount', label: '分组/单源'),
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
              style: const TextStyle(
                fontSize: 15,
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

  Widget _buildFilterSummary(
    BuildContext context, {
    required List<RssSource> sources,
    required List<RssSource> filteredSources,
  }) {
    final enabledCount =
        filteredSources.where((source) => source.enabled).length;
    final groupedCount = filteredSources
        .where((source) => (source.sourceGroup ?? '').trim().isNotEmpty)
        .length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(
          context,
          icon: Icons.dataset_linked_rounded,
          label: '显示 ${filteredSources.length}/${sources.length}',
        ),
        _buildFilterChip(
          context,
          icon: Icons.check_circle_outline_rounded,
          label: '启用 $enabledCount',
        ),
        _buildFilterChip(
          context,
          icon: Icons.folder_outlined,
          label: '分组 $groupedCount',
        ),
        if (_searchQuery.trim().isNotEmpty)
          _buildFilterChip(
            context,
            icon: Icons.search_off_rounded,
            label: '搜索中禁用排序',
            accent: const Color(0xFFEA580C),
          ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? accent,
  }) {
    final tone = accent ?? const Color(0xFFFB923C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: HomePalette.card(context).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HomePalette.lineColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: tone),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: HomePalette.secondaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '已选择 ${_selectedUrls.length} 项',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9A3412),
            ),
          ),
          _buildBatchAction(
              '启用', _selectedUrls.isEmpty ? null : _enableSelected),
          _buildBatchAction(
              '禁用', _selectedUrls.isEmpty ? null : _disableSelected),
          _buildBatchAction(
            '删除',
            _selectedUrls.isEmpty ? null : _deleteSelected,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBatchAction(
    String label,
    VoidCallback? onTap, {
    bool isDanger = false,
  }) {
    final color = isDanger ? const Color(0xFFE34D59) : const Color(0xFFC2410C);
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: onTap == null ? color.withValues(alpha: 0.36) : color,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
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

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  List<RssSource> _filterSources(List<RssSource> sources, String query) {
    if (query.isEmpty) return sources;

    final lowerQuery = query.toLowerCase();
    return sources.where((source) {
      return source.sourceName.toLowerCase().contains(lowerQuery) ||
          source.sourceUrl.toLowerCase().contains(lowerQuery) ||
          (source.sourceGroup?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<void> _openCreatePage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RssSourceEditPage(),
      ),
    );
    ref.invalidate(rssSourceListProvider);
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => const RssSourceImportDialog(),
    ).then((_) {
      ref.invalidate(rssSourceListProvider);
    });
  }

  void _showGroupManageSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const RssGroupManageDialog(),
    );
  }

  Future<void> _enableSelected() async {
    for (final url in _selectedUrls) {
      await readService(AppServices.rssService).updateRssSourceEnabled(url, true);
    }
    setState(() {
      _selectedUrls.clear();
      _isBatchMode = false;
    });
    ref.invalidate(rssSourceListProvider);
  }

  Future<void> _disableSelected() async {
    for (final url in _selectedUrls) {
      await readService(AppServices.rssService).updateRssSourceEnabled(url, false);
    }
    setState(() {
      _selectedUrls.clear();
      _isBatchMode = false;
    });
    ref.invalidate(rssSourceListProvider);
  }

  Future<void> _handleReorder(
    List<RssSource> sources,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex == newIndex || _searchQuery.trim().isNotEmpty) return;

    final reorderedSources = List<RssSource>.from(sources);
    final source = reorderedSources.removeAt(oldIndex);
    reorderedSources.insert(newIndex, source);

    try {
      for (int i = 0; i < reorderedSources.length; i++) {
        final updatedSource = reorderedSources[i].copyWith(customOrder: i);
        await readService(AppServices.rssService).addOrUpdateRssSource(updatedSource);
      }
      ref.invalidate(rssSourceListProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('排序失败: $e')),
      );
    }
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${_selectedUrls.length} 个 RSS 源吗？'),
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

    for (final url in _selectedUrls) {
      await readService(AppServices.rssService).deleteRssSource(url);
    }
    setState(() {
      _selectedUrls.clear();
      _isBatchMode = false;
    });
    ref.invalidate(rssSourceListProvider);
  }
}
