import 'package:flutter/material.dart';

import '../../../data/models/rss_source.dart';
import '../../widgets/common/custom_switch.dart';
import '../../widgets/home/home_shell.dart';

/// RSS源项组件
class RssSourceItemWidget extends StatelessWidget {
  final RssSource source;
  final bool isSelected;
  final bool isBatchMode;
  final bool allowReorder;
  final int? reorderIndex;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onToggleEnabled;

  const RssSourceItemWidget({
    super.key,
    required this.source,
    this.isSelected = false,
    this.isBatchMode = false,
    this.allowReorder = false,
    this.reorderIndex,
    required this.onTap,
    this.onLongPress,
    this.onToggleEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = source.enabled;
    final tags = <String>[
      isEnabled ? '启用' : '未启用',
      if ((source.sourceGroup ?? '').trim().isNotEmpty)
        source.sourceGroup!.trim(),
      if (source.singleUrl) '单源',
      if ((source.sortUrl ?? '').trim().isNotEmpty) '分类',
      if (source.customOrder > 0)
        '排序 ${source.customOrder.toString().padLeft(2, '0')}',
    ];

    return HomeSectionCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      color: isSelected ? const Color(0xFFFFF7ED) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBatchMode) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildSelectionMark(),
              ),
              const SizedBox(width: 12),
            ],
            _buildFeedIcon(isEnabled),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              source.sourceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: HomePalette.primaryText(context),
                                decoration: isEnabled
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (source.sourceGroup ?? '').trim().isNotEmpty
                                  ? '分组：${source.sourceGroup}'
                                  : '未分组',
                              style: TextStyle(
                                fontSize: 12,
                                color: HomePalette.tertiaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isBatchMode)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isEnabled
                                ? const Color(0xFFECFDF3)
                                : const Color(0xFFF4F5F7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isEnabled ? '已启用' : '已停用',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isEnabled
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF86909C),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: HomePalette.mutedCard(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          size: 15,
                          color: HomePalette.tertiaryText(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            source.sourceUrl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: HomePalette.secondaryText(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFC2410C),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isBatchMode)
                  CustomSwitch(
                    value: isEnabled,
                    onChanged: onToggleEnabled,
                  ),
                if (allowReorder && reorderIndex != null) ...[
                  const SizedBox(height: 14),
                  ReorderableDragStartListener(
                    index: reorderIndex!,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: HomePalette.mutedCard(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: HomePalette.tertiaryText(context),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionMark() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFFF97316) : const Color(0xFFFFF7ED),
        border: Border.all(
          color: isSelected ? const Color(0xFFF97316) : const Color(0xFFFDBA74),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }

  Widget _buildFeedIcon(bool isEnabled) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        isEnabled ? Icons.rss_feed_rounded : Icons.rss_feed_outlined,
        color: Colors.white,
        size: 19,
      ),
    );
  }
}
