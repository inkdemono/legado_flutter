import 'dart:convert';
import 'package:legado_flutter/providers/service_registry.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/models/replace_rule.dart';
import '../../../services/replace_rule_service.dart';
import '../../../services/network/network_service.dart';
import '../../widgets/home/home_shell.dart';
import 'replace_rule_item_widget.dart';
import 'replace_rule_edit_dialog.dart';
import 'replace_rule_import_dialog.dart';
import 'group_manage_dialog.dart';

/// 替换规则列表 Notifier
///
/// 将原 FutureProvider 升级为 AsyncNotifier，CRUD 操作直接更新内存列表，
/// 彻底消除每次增删改后的全量 DB 重查，避免列表闪烁。
/// 仅在导入、分组变更等批量操作后调用 [reload] 重新读库。
class ReplaceRuleNotifier extends AsyncNotifier<List<ReplaceRule>> {
  ReplaceRuleService get _svc => readService(AppServices.replaceRuleService);

  @override
  Future<List<ReplaceRule>> build() => _svc.getAllRules();

  /// 新增或更新规则（存在同 id 则替换，否则追加到末尾）
  Future<void> addOrUpdate(ReplaceRule rule) async {
    await _svc.addOrUpdateRule(rule);
    final current = state.requireValue;
    final idx = current.indexWhere((r) => r.id == rule.id);
    state = AsyncValue.data(
      idx >= 0
          ? [...current.sublist(0, idx), rule, ...current.sublist(idx + 1)]
          : [...current, rule],
    );
  }

  /// 切换启用状态
  Future<void> toggleEnabled(ReplaceRule rule, bool enabled) async {
    await _svc.updateRule(rule.copyWith(enabled: enabled));
    state = AsyncValue.data(
      state.requireValue
          .map((r) => r.id == rule.id ? r.copyWith(enabled: enabled) : r)
          .toList(),
    );
  }

  /// 删除单条规则
  Future<void> delete(int id) async {
    await _svc.deleteRuleById(id);
    state = AsyncValue.data(
      state.requireValue.where((r) => r.id != id).toList(),
    );
  }

  /// 批量删除
  Future<void> deleteMany(List<int> ids) async {
    await _svc.deleteRulesByIds(ids);
    final idSet = ids.toSet();
    state = AsyncValue.data(
      state.requireValue.where((r) => !idSet.contains(r.id)).toList(),
    );
  }

  /// 批量启用/禁用
  Future<void> batchSetEnabled(List<int> ids, bool enabled) async {
    await _svc.batchSetEnabledByIds(ids, enabled);
    final idSet = ids.toSet();
    state = AsyncValue.data(
      state.requireValue
          .map((r) => idSet.contains(r.id) ? r.copyWith(enabled: enabled) : r)
          .toList(),
    );
  }

  /// 将单条规则移到列表顶部（本地重排，不触发 DB 查询）
  Future<void> moveToTop(ReplaceRule rule) async {
    await _svc.moveToTop(rule);
    final current = state.requireValue;
    state = AsyncValue.data([rule, ...current.where((r) => r.id != rule.id)]);
  }

  /// 将单条规则移到列表底部
  Future<void> moveToBottom(ReplaceRule rule) async {
    await _svc.moveToBottom(rule);
    final current = state.requireValue;
    state = AsyncValue.data([...current.where((r) => r.id != rule.id), rule]);
  }

  /// 批量置顶
  Future<void> batchMoveToTop(List<int> ids) async {
    await _svc.batchMoveToTop(ids);
    final idSet = ids.toSet();
    final current = state.requireValue;
    state = AsyncValue.data([
      ...current.where((r) => idSet.contains(r.id)),
      ...current.where((r) => !idSet.contains(r.id)),
    ]);
  }

  /// 批量置底
  Future<void> batchMoveToBottom(List<int> ids) async {
    await _svc.batchMoveToBottom(ids);
    final idSet = ids.toSet();
    final current = state.requireValue;
    state = AsyncValue.data([
      ...current.where((r) => !idSet.contains(r.id)),
      ...current.where((r) => idSet.contains(r.id)),
    ]);
  }

  /// 拖拽重排（乐观更新，失败时回滚）
  Future<void> reorder(List<ReplaceRule> rules) async {
    state = AsyncValue.data(rules);
    try {
      await _svc.updateOrder(rules);
    } catch (e) {
      ref.invalidateSelf();
      rethrow;
    }
  }

  /// 全量重新加载（仅在导入、分组变更等批量操作后调用）
  Future<void> reload({bool showLoading = false}) async {
    if (showLoading || !state.hasValue) {
      state = const AsyncValue.loading();
    }
    state = await AsyncValue.guard(_svc.getAllRules);
  }
}

final replaceRuleNotifierProvider =
    AsyncNotifierProvider<ReplaceRuleNotifier, List<ReplaceRule>>(
        ReplaceRuleNotifier.new);

/// 替换规则管理页面
class ReplaceRuleManagePage extends ConsumerStatefulWidget {
  const ReplaceRuleManagePage({super.key});

  @override
  ConsumerState<ReplaceRuleManagePage> createState() =>
      _ReplaceRuleManagePageState();
}

class _ReplaceRuleManagePageState extends ConsumerState<ReplaceRuleManagePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedGroup; // 选中的分组，null表示全部，'__no_group__'表示无分组
  bool _isBatchMode = false;
  final Set<int> _selectedIds = {};
  List<String> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    final groups =
        await readService(AppServices.replaceRuleService).getAllGroups();
    setState(() {
      _groups = groups;
    });
  }

  void _showGroupManageDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GroupManageDialog(
        onGroupChanged: () {
          _loadGroups();
          ref.read(replaceRuleNotifierProvider.notifier).reload();
        },
      ),
    );
  }

  Widget _buildGroupChip(String label, String? groupValue) {
    final isSelected = _selectedGroup == groupValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
        backgroundColor: HomePalette.card(context),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
              : HomePalette.lineColor(context),
        ),
        labelStyle: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : HomePalette.secondaryText(context),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedGroup = selected ? groupValue : null;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(replaceRuleNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: HomePalette.background(context),
      appBar: AppBar(
        backgroundColor: HomePalette.card(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(
          bottom: BorderSide(color: HomePalette.lineColor(context)),
        ),
        title: const Text('替换规则'),
        actions: [
          if (_isBatchMode)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                setState(() {
                  _isBatchMode = false;
                  _selectedIds.clear();
                });
              },
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu_rounded),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'add',
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('新建规则'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'import_local',
                  child: Row(
                    children: [
                      Icon(Icons.file_upload_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('导入本地'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'import_online',
                  child: Row(
                    children: [
                      Icon(Icons.link_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('网络导入'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'import_default',
                  child: Row(
                    children: [
                      Icon(Icons.restore_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('导入默认规则'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.file_download_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('导出规则'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'batch',
                  child: Row(
                    children: [
                      Icon(Icons.checklist_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('批量操作'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'group_manage',
                  child: Row(
                    children: [
                      Icon(Icons.folder_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('分组管理'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'add':
                    _addRule();
                    break;
                  case 'import_local':
                    _importFromLocal();
                    break;
                  case 'import_online':
                    _importFromOnline();
                    break;
                  case 'import_default':
                    _importDefaultRules();
                    break;
                  case 'export':
                    _exportRules();
                    break;
                  case 'batch':
                    setState(() {
                      _isBatchMode = true;
                    });
                    break;
                  case 'group_manage':
                    _showGroupManageDialog();
                    break;
                }
              },
            ),
        ],
      ),
      floatingActionButton: _isBatchMode
          ? null
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.32),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _addRule,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.add_rounded, size: 30),
              ),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                HomeSearchField(
                  controller: _searchController,
                  hintText: '搜索规则名称',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildGroupChip('全部', null),
                      _buildGroupChip('无分组', '__no_group__'),
                      ..._groups.map((group) => _buildGroupChip(group, group)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isBatchMode && _selectedIds.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '已选择 ${_selectedIds.length} 项',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: HomePalette.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                        ),
                        label: const Text('启用'),
                        onPressed: () => _batchEnable(true),
                      ),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.do_not_disturb_on_outlined,
                          size: 18,
                        ),
                        label: const Text('禁用'),
                        onPressed: () => _batchEnable(false),
                      ),
                      TextButton.icon(
                        icon:
                            const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text('删除'),
                        onPressed: _batchDelete,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.vertical_align_top_rounded,
                          size: 18,
                        ),
                        label: const Text('置顶'),
                        onPressed: () => _batchMoveToTop(),
                      ),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.vertical_align_bottom_rounded,
                          size: 18,
                        ),
                        label: const Text('置底'),
                        onPressed: () => _batchMoveToBottom(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: rulesAsync.when(
              data: (rules) {
                final filteredRules = rules.where((rule) {
                  final matchesQuery = _searchQuery.isEmpty ||
                      rule.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      rule.pattern
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      rule.replacement
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      (rule.group
                              ?.toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ??
                          false);

                  final matchesGroup = _selectedGroup == null ||
                      (_selectedGroup == '__no_group__'
                          ? (rule.group == null || rule.group!.isEmpty)
                          : rule.group == _selectedGroup);

                  return matchesQuery && matchesGroup;
                }).toList();
                final canReorder =
                    _searchQuery.isEmpty && _selectedGroup == null;

                if (filteredRules.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(replaceRuleNotifierProvider.notifier)
                        .reload();
                  },
                  child: _isBatchMode
                      ? ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredRules.length,
                          itemBuilder: (context, index) {
                            final rule = filteredRules[index];
                            final isSelected = _selectedIds.contains(rule.id);
                            return ReplaceRuleItemWidget(
                              key: ValueKey(rule.id),
                              rule: rule,
                              index: index,
                              isBatchMode: true,
                              showDragHandle: false,
                              isSelected: isSelected,
                              onTap: () =>
                                  _toggleSelection(rule.id, isSelected),
                              onLongPress: null,
                              onToggleEnabled: (enabled) {
                                _toggleEnabled(rule, enabled);
                              },
                              onDelete: null,
                              onMoveToTop: null,
                              onMoveToBottom: null,
                            );
                          },
                        )
                      : canReorder
                          ? ReorderableListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                              buildDefaultDragHandles: false,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filteredRules.length,
                              proxyDecorator: (child, index, animation) {
                                return Material(
                                    color: Colors.transparent, child: child);
                              },
                              onReorder: (oldIndex, newIndex) {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                _handleReorder(
                                    filteredRules, oldIndex, newIndex);
                              },
                              itemBuilder: (context, index) {
                                final rule = filteredRules[index];
                                final isSelected =
                                    _selectedIds.contains(rule.id);

                                return ReplaceRuleItemWidget(
                                  key: ValueKey(rule.id),
                                  rule: rule,
                                  index: index,
                                  isBatchMode: false,
                                  showDragHandle: true,
                                  isSelected: isSelected,
                                  onTap: () => _editRule(rule),
                                  onLongPress: () {
                                    setState(() {
                                      _isBatchMode = true;
                                      _selectedIds.add(rule.id);
                                    });
                                  },
                                  onToggleEnabled: (enabled) {
                                    _toggleEnabled(rule, enabled);
                                  },
                                  onDelete: () => _deleteRule(rule),
                                  onMoveToTop: () => _moveToTop(rule),
                                  onMoveToBottom: () => _moveToBottom(rule),
                                );
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filteredRules.length,
                              itemBuilder: (context, index) {
                                final rule = filteredRules[index];
                                final isSelected =
                                    _selectedIds.contains(rule.id);

                                return ReplaceRuleItemWidget(
                                  key: ValueKey(rule.id),
                                  rule: rule,
                                  index: index,
                                  isBatchMode: false,
                                  showDragHandle: false,
                                  isSelected: isSelected,
                                  onTap: () => _editRule(rule),
                                  onLongPress: () {
                                    setState(() {
                                      _isBatchMode = true;
                                      _selectedIds.add(rule.id);
                                    });
                                  },
                                  onToggleEnabled: (enabled) {
                                    _toggleEnabled(rule, enabled);
                                  },
                                  onDelete: () => _deleteRule(rule),
                                  onMoveToTop: () => _moveToTop(rule),
                                  onMoveToBottom: () => _moveToBottom(rule),
                                );
                              },
                            ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 52,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '加载失败: $error',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: HomePalette.secondaryText(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () {
                          ref
                              .read(replaceRuleNotifierProvider.notifier)
                              .reload(showLoading: true);
                        },
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isSearching = _searchQuery.isNotEmpty || _selectedGroup != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: HomePalette.card(context),
                shape: BoxShape.circle,
                border: Border.all(color: HomePalette.lineColor(context)),
              ),
              alignment: Alignment.center,
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.find_replace_outlined,
                size: 42,
                color: HomePalette.tertiaryText(context),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isSearching ? '未找到匹配的规则' : '暂无替换规则',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: HomePalette.primaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching ? '调整关键词或分组筛选试试' : '点击右下角按钮添加新规则',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: HomePalette.tertiaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelection(int ruleId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedIds.remove(ruleId);
      } else {
        _selectedIds.add(ruleId);
      }
    });
  }

  // 添加规则
  void _addRule() {
    showDialog(
      context: context,
      builder: (context) => ReplaceRuleEditDialog(
        onSave: (rule) async {
          await ref
              .read(replaceRuleNotifierProvider.notifier)
              .addOrUpdate(rule);
        },
      ),
    );
  }

  // 编辑规则
  void _editRule(ReplaceRule rule) {
    showDialog(
      context: context,
      builder: (context) => ReplaceRuleEditDialog(
        rule: rule,
        onSave: (updatedRule) async {
          await ref
              .read(replaceRuleNotifierProvider.notifier)
              .addOrUpdate(updatedRule);
        },
      ),
    );
  }

  // 置顶规则
  Future<void> _moveToTop(ReplaceRule rule) async {
    try {
      await ref.read(replaceRuleNotifierProvider.notifier).moveToTop(rule);
      _showMessage('已置顶');
    } catch (e) {
      _showMessage('操作失败: $e');
    }
  }

  // 置底规则
  Future<void> _moveToBottom(ReplaceRule rule) async {
    try {
      await ref.read(replaceRuleNotifierProvider.notifier).moveToBottom(rule);
      _showMessage('已置底');
    } catch (e) {
      _showMessage('操作失败: $e');
    }
  }

  // 切换启用状态（本地状态直接更新，零 DB 查询）
  void _toggleEnabled(ReplaceRule rule, bool enabled) async {
    try {
      await ref
          .read(replaceRuleNotifierProvider.notifier)
          .toggleEnabled(rule, enabled);
    } catch (e) {
      _showMessage('操作失败: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 删除规则
  void _deleteRule(ReplaceRule rule) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除规则'),
        content: Text('确定要删除规则"${rule.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(replaceRuleNotifierProvider.notifier)
                    .delete(rule.id);
                _showMessage('已删除');
              } catch (e) {
                _showMessage('删除失败: $e');
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 批量置顶
  Future<void> _batchMoveToTop() async {
    if (_selectedIds.isEmpty) return;

    try {
      final count = _selectedIds.length;
      await ref
          .read(replaceRuleNotifierProvider.notifier)
          .batchMoveToTop(_selectedIds.toList());
      setState(() {
        _selectedIds.clear();
        _isBatchMode = false;
      });
      _showMessage('已置顶 $count 项');
    } catch (e) {
      _showMessage('操作失败: $e');
    }
  }

  // 批量置底
  Future<void> _batchMoveToBottom() async {
    if (_selectedIds.isEmpty) return;

    try {
      final count = _selectedIds.length;
      await ref
          .read(replaceRuleNotifierProvider.notifier)
          .batchMoveToBottom(_selectedIds.toList());
      setState(() {
        _selectedIds.clear();
        _isBatchMode = false;
      });
      _showMessage('已置底 $count 项');
    } catch (e) {
      _showMessage('操作失败: $e');
    }
  }

  // 批量启用/禁用
  Future<void> _batchEnable(bool enabled) async {
    if (_selectedIds.isEmpty) return;

    try {
      final count = _selectedIds.length;
      await ref
          .read(replaceRuleNotifierProvider.notifier)
          .batchSetEnabled(_selectedIds.toList(), enabled);
      setState(() {
        _selectedIds.clear();
        _isBatchMode = false;
      });
      _showMessage('已${enabled ? '启用' : '禁用'} $count 项');
    } catch (e) {
      _showMessage('操作失败: $e');
    }
  }

  // 批量删除
  void _batchDelete() {
    if (_selectedIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('批量删除'),
        content: Text('确定要删除选中的 ${_selectedIds.length} 项规则吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final count = _selectedIds.length;
                await ref
                    .read(replaceRuleNotifierProvider.notifier)
                    .deleteMany(_selectedIds.toList());
                setState(() {
                  _selectedIds.clear();
                  _isBatchMode = false;
                });
                _showMessage('已删除 $count 项');
              } catch (e) {
                _showMessage('删除失败: $e');
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 处理排序
  void _handleReorder(
      List<ReplaceRule> rules, int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    final reorderedRules = List<ReplaceRule>.from(rules);
    final rule = reorderedRules.removeAt(oldIndex);
    reorderedRules.insert(newIndex, rule);

    try {
      await ref
          .read(replaceRuleNotifierProvider.notifier)
          .reorder(reorderedRules);
    } catch (e) {
      _showMessage('排序失败: $e');
    }
  }

  // 从本地导入
  Future<void> _importFromLocal() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'json'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = File(result.files.first.path!);
      final content = await file.readAsString();
      _showImportDialog(content);
    } catch (e) {
      _showMessage('导入失败: $e');
    }
  }

  // 从网络导入
  void _importFromOnline() {
    final controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('网络导入'),
          content: isLoading
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在获取规则...'),
                  ],
                )
              : TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: '请输入规则URL或JSON内容',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  autofocus: true,
                ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final navigator = Navigator.of(dialogContext);
                      final content = controller.text.trim();
                      if (content.isEmpty) {
                        _showMessage('请输入URL或JSON内容');
                        return;
                      }

                      // 如果是URL，尝试从网络获取
                      final uri = Uri.tryParse(content);
                      if (uri != null && uri.hasScheme) {
                        setDialogState(() {
                          isLoading = true;
                        });

                        try {
                          final response =
                              await readService(AppServices.networkService).get(
                            content,
                            retryCount: 1,
                          );
                          final fetchedContent =
                              await NetworkService.getResponseText(response);

                          if (!mounted) return;
                          navigator.pop();
                          _showImportDialog(fetchedContent);
                        } catch (e) {
                          if (!mounted) return;
                          setDialogState(() {
                            isLoading = false;
                          });
                          _showMessage('获取失败: $e');
                        }
                      } else {
                        navigator.pop();
                        _showImportDialog(content);
                      }
                    },
              child: const Text('导入'),
            ),
          ],
        ),
      ),
    );
  }

  // 导入默认规则
  Future<void> _importDefaultRules() async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('导入默认规则'),
        content: const Text('导入默认替换规则。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await readService(AppServices.replaceRuleService)
                    .importDefaultRules();
                await ref.read(replaceRuleNotifierProvider.notifier).reload();
                _showMessage('导入成功');
              } catch (e) {
                _showMessage('导入失败: $e');
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 导出规则
  Future<void> _exportRules() async {
    try {
      final rules =
          await readService(AppServices.replaceRuleService).getAllRules();

      if (rules.isEmpty) {
        _showMessage('没有可导出的规则');
        return;
      }

      final jsonString = jsonEncode(rules.map((r) => r.toJson()).toList());

      final result = await FilePicker.platform.saveFile(
        dialogTitle: '导出规则',
        fileName: 'replaceRule-${DateTime.now().millisecondsSinceEpoch}.json',
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

  // 显示导入对话框
  void _showImportDialog(String content) {
    showDialog(
      context: context,
      builder: (context) => ReplaceRuleImportDialog(
        content: content,
        onImportComplete: () {
          ref.read(replaceRuleNotifierProvider.notifier).reload();
        },
      ),
    );
  }
}
