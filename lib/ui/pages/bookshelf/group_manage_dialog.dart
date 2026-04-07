import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/book_group.dart';
import '../../../providers/book_provider.dart';
import '../../widgets/base/base_bottom_sheet_consumer.dart';
import '../../widgets/common/custom_switch.dart';
import 'group_edit_dialog.dart';

/// 分组管理对话框
class GroupManageDialog extends BaseBottomSheetConsumer {
  const GroupManageDialog({super.key})
      : super(
          title: null,
          showTitleBar: false,
          padding: EdgeInsets.zero,
          heightFactor: 0.82,
        );

  @override
  ConsumerState<GroupManageDialog> createState() => _GroupManageDialogState();
}

class _GroupManageDialogState
    extends BaseBottomSheetConsumerState<GroupManageDialog> {
  @override
  Widget buildContent(BuildContext context) {
    final groupsAsync = ref.watch(bookGroupsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F1720).withValues(alpha: 0.14),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D7E2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  '分组管理',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2329),
                  ),
                ),
                const Spacer(),
                _buildAddButton(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: groupsAsync.when(
              data: (groups) {
                if (groups.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildGroupItem(group, index),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(context, error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7B5CFF), Color(0xFF9C7DFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    '完成',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showAddGroupDialog,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F0FF),
            borderRadius: BorderRadius.circular(21),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.add_rounded,
            color: Color(0xFF6B4DFF),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupItem(BookGroup group, int index) {
    final isSystemGroup = group.groupId < 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF0F4)),
      ),
      child: Row(
        children: [
          _buildGroupIcon(index),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.groupName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2329),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildGroupSubtitle(group),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF86909C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CustomSwitch(
            value: group.show,
            onChanged: isSystemGroup
                ? null
                : (value) async {
                    try {
                      await ref
                          .read(bookGroupsProvider.notifier)
                          .toggleGroupVisibility(group, value);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('操作失败: $e')),
                      );
                    }
                  },
          ),
          if (!isSystemGroup) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              tooltip: '更多操作',
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xFFB8BEC8),
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditGroupDialog(group);
                } else if (value == 'delete') {
                  _showDeleteConfirmDialog(group);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('编辑'),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('删除'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupIcon(int index) {
    const icons = [
      Icons.menu_book_rounded,
      Icons.auto_stories_rounded,
      Icons.psychology_rounded,
      Icons.local_library_rounded,
      Icons.bookmarks_rounded,
    ];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B5CFF), Color(0xFF9C7DFF)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icons[index % icons.length],
        color: Colors.white,
        size: 18,
      ),
    );
  }

  String _buildGroupSubtitle(BookGroup group) {
    final sortLabel = switch (group.bookSort) {
      -1 => '使用全局排序',
      0 => '按阅读时间',
      1 => '按更新时间',
      2 => '按书名',
      3 => '手动排序',
      4 => '综合排序',
      _ => '自定义排序',
    };

    final status = group.show ? '显示中' : '已隐藏';
    final refresh = group.enableRefresh ? '启用刷新' : '关闭刷新';
    return 'ID: ${group.groupId} · $sortLabel · $refresh · $status';
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_open_rounded,
              size: 56,
              color: Color(0xFFB8BEC8),
            ),
            const SizedBox(height: 16),
            const Text(
              '暂无分组',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2329),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '新建分组后，可以分别控制显隐、刷新和排序策略。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF86909C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 52, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '加载失败: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF4E5969)),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref
                  .read(bookGroupsProvider.notifier)
                  .reload(showLoading: true),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => const GroupEditDialog(),
    );
  }

  void _showEditGroupDialog(BookGroup group) {
    showDialog(
      context: context,
      builder: (context) => GroupEditDialog(group: group),
    );
  }

  void _showDeleteConfirmDialog(BookGroup group) {
    showDialog(
      context: context,
      builder: (alertContext) => AlertDialog(
        title: const Text('删除分组'),
        content: Text('确定要删除分组"${group.groupName}"吗？\n分组中的书籍将移动到"全部"分组。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(alertContext);
              try {
                final books =
                    await ref.read(booksByGroupProvider(group.groupId).future);
                await ref
                    .read(bookshelfBooksProvider.notifier)
                    .updateBookGroups(
                      books.map((book) => book.bookUrl).toList(),
                      BookGroup.idAll,
                    );
                await ref
                    .read(bookGroupsProvider.notifier)
                    .deleteGroup(group.groupId);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已删除分组')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('删除失败: $e')),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
