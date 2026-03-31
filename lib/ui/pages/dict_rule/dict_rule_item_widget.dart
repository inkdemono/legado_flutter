import 'package:flutter/material.dart';
import '../../../data/models/dict_rule.dart';
import '../../widgets/common/custom_switch.dart';
import '../../widgets/home/home_shell.dart';

/// 字典规则项组件
class DictRuleItemWidget extends StatelessWidget {
  static const List<List<Color>> _iconGradients = [
    [Color(0xFF34D399), Color(0xFF14B8A6)],
    [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
    [Color(0xFFFB7185), Color(0xFFFF7AA5)],
    [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
  ];

  final DictRule rule;
  final int index;
  final bool isBatchMode;
  final bool showDragHandle;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool> onToggleEnabled;
  final VoidCallback? onDelete;

  const DictRuleItemWidget({
    super.key,
    required this.rule,
    required this.index,
    required this.isBatchMode,
    this.showDragHandle = true,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
    required this.onToggleEnabled,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _iconGradients[index % _iconGradients.length];
    final radius = BorderRadius.circular(18);
    final borderColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.28)
        : HomePalette.lineColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Ink(
            decoration: BoxDecoration(
              color: HomePalette.card(context),
              borderRadius: radius,
              border: Border.all(color: borderColor),
              boxShadow: HomePalette.cardShadow(context),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, 14, isBatchMode ? 14 : 12, 14),
              child: Row(
                children: [
                  if (isBatchMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => onTap(),
                      ),
                    )
                  else if (showDragHandle)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_indicator_rounded,
                          color: HomePalette.tertiaryText(context),
                          size: 20,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 30),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: colors),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                rule.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: HomePalette.primaryText(context),
                                ),
                              ),
                            ),
                            if (!rule.enabled) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: HomePalette.mutedCard(context),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: HomePalette.lineColor(context),
                                  ),
                                ),
                                child: Text(
                                  '已禁用',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: HomePalette.tertiaryText(context),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: HomePalette.mutedCard(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'URL规则: ${rule.urlRule}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              fontFamily: 'monospace',
                              color: HomePalette.secondaryText(context),
                            ),
                          ),
                        ),
                        if (rule.showRule.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '显示规则: ${rule.showRule}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: HomePalette.secondaryText(context),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isBatchMode) ...[
                    const SizedBox(width: 12),
                    CustomSwitch(
                      value: rule.enabled,
                      onChanged: onToggleEnabled,
                    ),
                    if (onDelete != null)
                      PopupMenuButton<String>(
                        tooltip: '更多操作',
                        padding: const EdgeInsets.only(left: 4),
                        iconSize: 20,
                        onSelected: (value) {
                          if (value == 'delete') {
                            onDelete?.call();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('删除规则'),
                          ),
                        ],
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          color: HomePalette.tertiaryText(context),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
