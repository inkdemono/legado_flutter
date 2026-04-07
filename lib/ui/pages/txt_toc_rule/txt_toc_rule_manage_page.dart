import 'dart:convert';
import 'package:legado_flutter/providers/service_registry.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/models/txt_toc_rule.dart';
import '../../../services/txt_toc_rule_service.dart';
import '../../../services/network/network_service.dart';
import '../../widgets/home/home_shell.dart';
import 'txt_toc_rule_item_widget.dart';
import 'txt_toc_rule_edit_dialog.dart';
import 'txt_toc_rule_feedback.dart';
import 'txt_toc_rule_import_dialog.dart';

class TxtTocRuleNotifier extends AsyncNotifier<List<TxtTocRule>> {
  TxtTocRuleService get _svc => readService(AppServices.txtTocRuleService);

  @override
  Future<List<TxtTocRule>> build() => _svc.getAllRules();

  Future<void> reload({bool showLoading = false}) async {
    if (showLoading || !state.hasValue) {
      state = const AsyncValue.loading();
    }
    state = await AsyncValue.guard(_svc.getAllRules);
  }

  Future<void> addOrUpdate(TxtTocRule rule) async {
    final current = state.requireValue;
    final existingIndex = current.indexWhere((item) => item.id == rule.id);
    if (existingIndex >= 0) {
      await _svc.updateRule(rule);
      state = AsyncValue.data(
        current.map((item) => item.id == rule.id ? rule : item).toList(),
      );
      return;
    }

    await _svc.addRule(rule);
    state = AsyncValue.data([...current, rule]);
  }

  Future<void> toggleEnabled(TxtTocRule rule, bool enabled) async {
    await _svc.updateRule(rule.copyWith(enable: enabled));
    state = AsyncValue.data(
      state.requireValue
          .map((item) =>
              item.id == rule.id ? item.copyWith(enable: enabled) : item)
          .toList(),
    );
  }

  Future<void> delete(int id) async {
    await _svc.deleteRule(id);
    state = AsyncValue.data(
      state.requireValue.where((item) => item.id != id).toList(),
    );
  }

  Future<void> deleteMany(List<int> ids) async {
    await _svc.deleteRules(ids);
    final idSet = ids.toSet();
    state = AsyncValue.data(
      state.requireValue.where((item) => !idSet.contains(item.id)).toList(),
    );
  }

  Future<void> batchSetEnabled(List<int> ids, bool enabled) async {
    await _svc.batchSetEnabled(ids, enabled);
    final idSet = ids.toSet();
    state = AsyncValue.data(
      state.requireValue
          .map((item) =>
              idSet.contains(item.id) ? item.copyWith(enable: enabled) : item)
          .toList(),
    );
  }

  Future<void> reorder(List<TxtTocRule> rules) async {
    state = AsyncValue.data(rules);
    try {
      await _svc.updateOrder(rules);
    } catch (e) {
      ref.invalidateSelf();
      rethrow;
    }
  }
}

final txtTocRuleNotifierProvider =
    AsyncNotifierProvider<TxtTocRuleNotifier, List<TxtTocRule>>(
  TxtTocRuleNotifier.new,
);

/// TXT目录规则管理页面
class TxtTocRuleManagePage extends ConsumerStatefulWidget {
  const TxtTocRuleManagePage({super.key});

  @override
  ConsumerState<TxtTocRuleManagePage> createState() =>
      _TxtTocRuleManagePageState();
}

class _TxtTocRuleManagePageState extends ConsumerState<TxtTocRuleManagePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isBatchMode = false;
  final Set<int> _selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(txtTocRuleNotifierProvider);
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
        title: const Text('TXT目录规则'),
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
            child: HomeSearchField(
              controller: _searchController,
              hintText: '搜索规则名称',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
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
              child: Row(
                children: [
                  Text(
                    '已选择 ${_selectedIds.length} 项',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: HomePalette.primaryText(context),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 18),
                    label: const Text('启用'),
                    onPressed: () => _batchEnable(true),
                  ),
                  TextButton.icon(
                    icon:
                        const Icon(Icons.do_not_disturb_on_outlined, size: 18),
                    label: const Text('禁用'),
                    onPressed: () => _batchEnable(false),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('删除'),
                    onPressed: _batchDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: rulesAsync.when(
              data: (rules) {
                final filteredRules = _searchQuery.isEmpty
                    ? rules
                    : rules.where((rule) {
                        final query = _searchQuery.toLowerCase();
                        return rule.name.toLowerCase().contains(query) ||
                            rule.rule.toLowerCase().contains(query) ||
                            (rule.example?.toLowerCase().contains(query) ??
                                false);
                      }).toList();

                if (filteredRules.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(txtTocRuleNotifierProvider.notifier)
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
                            return TxtTocRuleItemWidget(
                              key: ValueKey(rule.id),
                              rule: rule,
                              index: index,
                              isBatchMode: true,
                              isSelected: isSelected,
                              onTap: () =>
                                  _toggleSelection(rule.id, isSelected),
                              onLongPress: null,
                              onToggleEnabled: (enabled) {
                                _toggleEnabled(rule, enabled);
                              },
                              onDelete: null,
                            );
                          },
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                          buildDefaultDragHandles: false,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredRules.length,
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              color: Colors.transparent,
                              child: child,
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            _handleReorder(filteredRules, oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final rule = filteredRules[index];
                            final isSelected = _selectedIds.contains(rule.id);

                            return TxtTocRuleItemWidget(
                              key: ValueKey(rule.id),
                              rule: rule,
                              index: index,
                              isBatchMode: false,
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
                              .read(txtTocRuleNotifierProvider.notifier)
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
    final isSearching = _searchQuery.isNotEmpty;

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
                    : Icons.description_outlined,
                size: 42,
                color: HomePalette.tertiaryText(context),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isSearching ? '未找到匹配的规则' : '暂无TXT目录规则',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: HomePalette.primaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching ? '换个关键词试试' : '点击右下角按钮添加新规则',
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

  void _addRule() {
    showDialog(
      context: context,
      builder: (context) => TxtTocRuleEditDialog(
        onSave: (rule) async {
          await ref.read(txtTocRuleNotifierProvider.notifier).addOrUpdate(rule);
        },
      ),
    );
  }

  void _editRule(TxtTocRule rule) {
    showDialog(
      context: context,
      builder: (context) => TxtTocRuleEditDialog(
        rule: rule,
        onSave: (updatedRule) async {
          await ref
              .read(txtTocRuleNotifierProvider.notifier)
              .addOrUpdate(updatedRule);
        },
      ),
    );
  }

  void _toggleEnabled(TxtTocRule rule, bool enabled) async {
    try {
      await ref
          .read(txtTocRuleNotifierProvider.notifier)
          .toggleEnabled(rule, enabled);
    } catch (e) {
      _showMessage('操作失败: $e');
    }
  }

  void _showMessage(String message,
      {TxtTocRuleFeedbackType type = TxtTocRuleFeedbackType.info}) {
    if (!mounted) return;
    TxtTocRuleFeedback.show(context, message, type: type);
  }

  InputDecoration _dialogInputDecoration({
    required BuildContext context,
    required String hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: HomePalette.tertiaryText(context),
        fontSize: 14,
      ),
      filled: true,
      fillColor: HomePalette.mutedCard(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: HomePalette.lineColor(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: HomePalette.lineColor(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _buildDialogHeaderAction({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Ink(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: HomePalette.mutedCard(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HomePalette.lineColor(context)),
              ),
              child: Icon(
                icon,
                size: 20,
                color: HomePalette.primaryText(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogShell({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget content,
    required Widget footer,
    VoidCallback? onClose,
    double maxWidth = 560,
    double maxHeightFactor = 0.76,
  }) {
    final media = MediaQuery.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: media.size.height * maxHeightFactor,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: HomePalette.card(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: HomePalette.lineColor(context)),
            boxShadow: HomePalette.cardShadow(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1677FF).withValues(alpha: 0.12),
                      const Color(0xFF14B8A6).withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1677FF), Color(0xFF14B8A6)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: HomePalette.primaryText(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: HomePalette.secondaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildDialogHeaderAction(
                      context: context,
                      icon: Icons.close_rounded,
                      tooltip: '关闭',
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: HomePalette.lineColor(context)),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: content,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: BoxDecoration(
                  color: HomePalette.card(context),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                  border: Border(
                    top: BorderSide(color: HomePalette.lineColor(context)),
                  ),
                ),
                child: footer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteRule(TxtTocRule rule) {
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> submit() async {
            final navigator = Navigator.of(dialogContext);
            setDialogState(() {
              isDeleting = true;
            });

            try {
              await ref
                  .read(txtTocRuleNotifierProvider.notifier)
                  .delete(rule.id);
              if (!mounted) return;
              navigator.pop();
              _showMessage('已删除', type: TxtTocRuleFeedbackType.success);
            } catch (e) {
              setDialogState(() {
                isDeleting = false;
              });
              _showMessage('删除失败: $e', type: TxtTocRuleFeedbackType.error);
            }
          }

          return _buildDialogShell(
            context: context,
            icon: Icons.delete_outline_rounded,
            title: '删除规则',
            subtitle: '确认后将从当前规则列表中移除这条记录',
            onClose: isDeleting ? null : () => Navigator.pop(dialogContext),
            maxHeightFactor: 0.56,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .error
                          .withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '删除后不可恢复，请确认这条规则不再需要。',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: HomePalette.secondaryText(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '规则名称',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: HomePalette.mutedCard(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: HomePalette.lineColor(context)),
                  ),
                  child: Text(
                    rule.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: HomePalette.primaryText(context),
                    ),
                  ),
                ),
              ],
            ),
            footer: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        isDeleting ? null : () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HomePalette.secondaryText(context),
                      side: BorderSide(color: HomePalette.lineColor(context)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isDeleting ? null : submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('确认删除'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _batchEnable(bool enabled) async {
    if (_selectedIds.isEmpty) return;
    final selectedCount = _selectedIds.length;

    try {
      await ref
          .read(txtTocRuleNotifierProvider.notifier)
          .batchSetEnabled(_selectedIds.toList(), enabled);
      setState(() {
        _selectedIds.clear();
        _isBatchMode = false;
      });
      _showMessage('已${enabled ? '启用' : '禁用'} $selectedCount 项',
          type: TxtTocRuleFeedbackType.success);
    } catch (e) {
      _showMessage('操作失败: $e', type: TxtTocRuleFeedbackType.error);
    }
  }

  void _batchDelete() {
    if (_selectedIds.isEmpty) return;
    bool isDeleting = false;
    final selectedCount = _selectedIds.length;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> submit() async {
            final navigator = Navigator.of(dialogContext);
            setDialogState(() {
              isDeleting = true;
            });

            try {
              await ref
                  .read(txtTocRuleNotifierProvider.notifier)
                  .deleteMany(_selectedIds.toList());
              setState(() {
                _selectedIds.clear();
                _isBatchMode = false;
              });
              if (!mounted) return;
              navigator.pop();
              _showMessage('已删除', type: TxtTocRuleFeedbackType.success);
            } catch (e) {
              setDialogState(() {
                isDeleting = false;
              });
              _showMessage('删除失败: $e', type: TxtTocRuleFeedbackType.error);
            }
          }

          return _buildDialogShell(
            context: context,
            icon: Icons.delete_sweep_rounded,
            title: '批量删除',
            subtitle: '确认后将删除当前选中的全部规则',
            onClose: isDeleting ? null : () => Navigator.pop(dialogContext),
            maxHeightFactor: 0.58,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .error
                          .withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '批量删除后不可恢复，请确认这些规则不再需要。',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: HomePalette.secondaryText(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '本次将删除',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: HomePalette.mutedCard(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: HomePalette.lineColor(context)),
                  ),
                  child: Text(
                    '$selectedCount 项规则',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: HomePalette.primaryText(context),
                    ),
                  ),
                ),
              ],
            ),
            footer: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        isDeleting ? null : () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HomePalette.secondaryText(context),
                      side: BorderSide(color: HomePalette.lineColor(context)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isDeleting ? null : submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('确认删除'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleReorder(
      List<TxtTocRule> rules, int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    final reorderedRules = List<TxtTocRule>.from(rules);
    final rule = reorderedRules.removeAt(oldIndex);
    reorderedRules.insert(newIndex, rule);

    try {
      await ref
          .read(txtTocRuleNotifierProvider.notifier)
          .reorder(reorderedRules);
    } catch (e) {
      _showMessage('排序失败: $e', type: TxtTocRuleFeedbackType.error);
    }
  }

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
      _showMessage('导入失败: $e', type: TxtTocRuleFeedbackType.error);
    }
  }

  void _importFromOnline() {
    final controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> submit() async {
            final navigator = Navigator.of(dialogContext);
            final content = controller.text.trim();
            if (content.isEmpty) {
              _showMessage('请输入URL或JSON内容',
                  type: TxtTocRuleFeedbackType.warning);
              return;
            }

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
                _showMessage('获取失败: $e', type: TxtTocRuleFeedbackType.error);
              }
            } else {
              navigator.pop();
              _showImportDialog(content);
            }
          }

          return _buildDialogShell(
            context: context,
            icon: Icons.cloud_download_rounded,
            title: '网络导入',
            subtitle: '支持输入规则链接，或直接粘贴 JSON 内容后导入',
            onClose: isLoading ? null : () => Navigator.pop(dialogContext),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '规则地址或内容',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  decoration: _dialogInputDecoration(
                    context: context,
                    hintText: '请输入规则 URL 或粘贴 JSON',
                  ),
                  maxLines: 6,
                  minLines: 5,
                  autofocus: true,
                  enabled: !isLoading,
                  style: TextStyle(
                    color: HomePalette.primaryText(context),
                    fontSize: 13,
                    height: 1.4,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isLoading
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08)
                        : HomePalette.mutedCard(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isLoading
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.14)
                          : HomePalette.lineColor(context),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLoading)
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      else
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: HomePalette.tertiaryText(context),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isLoading
                              ? '正在获取远程规则，请稍候'
                              : '如果输入的是链接，系统会先拉取内容；如果输入的是 JSON，会直接进入规则预览。',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: HomePalette.secondaryText(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            footer: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        isLoading ? null : () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HomePalette.secondaryText(context),
                      side: BorderSide(color: HomePalette.lineColor(context)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isLoading ? null : submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('继续导入'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _importDefaultRules() async {
    bool isImporting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> submit() async {
            final navigator = Navigator.of(dialogContext);
            setDialogState(() {
              isImporting = true;
            });

            try {
              await readService(AppServices.txtTocRuleService)
                  .importDefaultRules();
              await ref.read(txtTocRuleNotifierProvider.notifier).reload();
              if (!mounted) return;
              navigator.pop();
              _showMessage('导入成功', type: TxtTocRuleFeedbackType.success);
            } catch (e) {
              if (!mounted) return;
              setDialogState(() {
                isImporting = false;
              });
              _showMessage('导入失败: $e', type: TxtTocRuleFeedbackType.error);
            }
          }

          return _buildDialogShell(
            context: context,
            icon: Icons.restore_rounded,
            title: '导入默认规则',
            subtitle: '恢复应用自带的 TXT 目录规则集合',
            onClose: isImporting ? null : () => Navigator.pop(dialogContext),
            maxHeightFactor: 0.58,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '导入默认规则不会删除你的自定义规则，但如果你修改过内置规则，这些修改会被恢复为默认内容。',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: HomePalette.secondaryText(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '建议在导入前确认：',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. 你希望恢复内置规则原始内容。\n2. 已修改的默认规则将被覆盖。\n3. 自定义新增的规则会保留。',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
              ],
            ),
            footer: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        isImporting ? null : () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HomePalette.secondaryText(context),
                      side: BorderSide(color: HomePalette.lineColor(context)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isImporting ? null : submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isImporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('确认导入'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportRules() async {
    try {
      final rules =
          await readService(AppServices.txtTocRuleService).getAllRules();

      if (rules.isEmpty) {
        _showMessage('没有可导出的规则', type: TxtTocRuleFeedbackType.warning);
        return;
      }

      final jsonString = jsonEncode(rules.map((r) => r.toJson()).toList());

      final result = await FilePicker.platform.saveFile(
        dialogTitle: '导出规则',
        fileName: 'txtTocRule-${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(jsonString);
        _showMessage('导出成功', type: TxtTocRuleFeedbackType.success);
      }
    } catch (e) {
      _showMessage('导出失败: $e', type: TxtTocRuleFeedbackType.error);
    }
  }

  void _showImportDialog(String content) {
    showDialog(
      context: context,
      builder: (context) => TxtTocRuleImportDialog(
        content: content,
        onImportComplete: () {
          ref.read(txtTocRuleNotifierProvider.notifier).reload();
        },
      ),
    );
  }
}
