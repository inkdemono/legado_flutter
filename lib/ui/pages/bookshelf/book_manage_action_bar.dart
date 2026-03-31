import 'package:flutter/material.dart';

import '../../widgets/home/home_shell.dart';
import 'book_manage_batch_actions.dart';

/// 书籍管理操作栏
class BookManageActionBar extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final bool isAllSelected;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onClearSelection;
  final ValueChanged<BatchAction> onBatchAction;

  const BookManageActionBar({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    required this.isAllSelected,
    required this.onToggleSelectAll,
    required this.onClearSelection,
    required this.onBatchAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEDF3FF), Color(0xFFF7FAFF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '已选择 $selectedCount / $totalCount 本',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '批量移动、清理缓存、删除或调整更新策略',
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onToggleSelectAll,
                child: Text(isAllSelected ? '取消全选' : '全选当前'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionChip(
                  label: '移动分组',
                  icon: Icons.swap_horiz_rounded,
                  onTap: () => onBatchAction(BatchAction.moveToGroup),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionChip(
                  label: '清理缓存',
                  icon: Icons.layers_clear_rounded,
                  onTap: () => onBatchAction(BatchAction.clearCache),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionChip(
                  label: '删除',
                  icon: Icons.delete_outline_rounded,
                  danger: true,
                  onTap: () => onBatchAction(BatchAction.delete),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<BatchAction>(
                onSelected: onBatchAction,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                color: HomePalette.card(context),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: BatchAction.addToGroup,
                    child: Row(
                      children: [
                        Icon(Icons.folder_copy_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('添加到分组'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: BatchAction.enableUpdate,
                    child: Row(
                      children: [
                        Icon(Icons.update_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('启用更新'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: BatchAction.disableUpdate,
                    child: Row(
                      children: [
                        Icon(Icons.update_disabled_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('禁用更新'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDDE6F6)),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.more_horiz_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool danger;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground =
        danger ? const Color(0xFFF53F3F) : HomePalette.secondaryText(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDE6F6)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
