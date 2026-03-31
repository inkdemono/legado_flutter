import 'package:flutter/material.dart';
import '../../../data/models/txt_toc_rule.dart';
import '../../widgets/common/custom_switch.dart';
import '../../widgets/home/home_shell.dart';

/// TXT目录规则项组件
class TxtTocRuleItemWidget extends StatelessWidget {
  static const List<List<Color>> _iconGradients = [
    [Color(0xFF34D399), Color(0xFF14B8A6)],
    [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
    [Color(0xFFFB7185), Color(0xFFFF7AA5)],
    [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
  ];

  final TxtTocRule rule;
  final int index;
  final bool isBatchMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool> onToggleEnabled;
  final VoidCallback? onDelete;

  const TxtTocRuleItemWidget({
    super.key,
    required this.rule,
    required this.index,
    required this.isBatchMode,
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
                  else
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
                    ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: colors),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.description_rounded,
                      color:
                          Colors.white.withValues(alpha: rule.enable ? 1 : 0.9),
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
                            if (!rule.enable) ...[
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
                            rule.rule,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              fontFamily: 'monospace',
                              color: HomePalette.tertiaryText(context),
                            ),
                          ),
                        ),
                        if (rule.example != null &&
                            rule.example!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '示例: ${rule.example}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: HomePalette.secondaryText(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isBatchMode) ...[
                    const SizedBox(width: 12),
                    CustomSwitch(
                      value: rule.enable,
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
