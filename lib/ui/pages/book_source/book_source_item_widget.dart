import 'package:flutter/material.dart';
import '../../../data/models/book_source.dart';
import '../../widgets/home/home_shell.dart';

/// 书源列表项组件
class BookSourceItemWidget extends StatelessWidget {
  final int index;
  final BookSource bookSource;
  final bool isBatchMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Function(bool) onToggleEnabled;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const BookSourceItemWidget({
    super.key,
    required this.index,
    required this.bookSource,
    required this.isBatchMode,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
    required this.onToggleEnabled,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(bookSource.bookSourceUrl);
    final host = (uri != null && uri.host.isNotEmpty)
        ? uri.host
        : bookSource.bookSourceUrl;
    final metaLabel = _getMetaLabel();
    final cardBorderColor = isSelected
        ? HomePalette.accent.withValues(alpha: 0.22)
        : HomePalette.lineColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Ink(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? HomePalette.accentSoft
                  : HomePalette.card(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cardBorderColor),
            ),
            child: Row(
              children: [
                _buildLeadingControl(context),
                const SizedBox(width: 10),
                _buildSourceIcon(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookSource.bookSourceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: HomePalette.primaryText(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildMetaBadge(context, metaLabel),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                host,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: HomePalette.tertiaryText(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (!isBatchMode)
                  _buildToggleSwitch(
                    value: bookSource.enabled,
                    onChanged: onToggleEnabled,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingControl(BuildContext context) {
    if (isBatchMode) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: _buildBatchIndicator(context),
      );
    }

    return SizedBox(
      width: 18,
      height: 54,
      child: Center(
        child: Wrap(
          direction: Axis.vertical,
          spacing: 3,
          children: List.generate(
            6,
            (index) => Container(
              width: 2,
              height: 2,
              decoration: BoxDecoration(
                color: HomePalette.tertiaryText(context).withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBatchIndicator(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? HomePalette.accent : Colors.transparent,
        border: Border.all(
          color:
              isSelected ? HomePalette.accent : HomePalette.lineColor(context),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }

  Widget _buildSourceIcon(BuildContext context) {
    final colors = _iconGradientColors();

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          _getTypeIcon(),
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildMetaBadge(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: HomePalette.background(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: HomePalette.tertiaryText(context),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        width: 40,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? HomePalette.accent : const Color(0xFFD9DCE3),
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _iconGradientColors() {
    final gradients = [
      const [Color(0xFF4F6CFF), Color(0xFF7455F5)],
      const [Color(0xFFFF7A8C), Color(0xFFF55D8E)],
      const [Color(0xFF45C2FF), Color(0xFF1999E8)],
      const [Color(0xFF42D392), Color(0xFF14B86A)],
      const [Color(0xFFE78BFF), Color(0xFF56C6FF)],
      const [Color(0xFF5D7CFF), Color(0xFF6F55F6)],
    ];
    return gradients[index % gradients.length];
  }

  String _getMetaLabel() {
    final comment = (bookSource.bookSourceComment ?? '').trim();
    final name = bookSource.bookSourceName;
    final groups = bookSource.bookSourceGroup ?? '';
    final joined = '$comment $name $groups';

    if (joined.contains('正版')) {
      return '正版';
    }
    if (joined.contains('有声') || joined.contains('听书')) {
      return '有声';
    }
    if (joined.contains('漫画')) {
      return '漫画';
    }
    if (joined.contains('图片')) {
      return '图片';
    }
    if (joined.contains('文件')) {
      return '文件';
    }

    switch (bookSource.bookSourceType) {
      case 1:
        return '有声';
      case 2:
        return '图片';
      case 3:
        return '文件';
      case 0:
      default:
        return '小说';
    }
  }

  IconData _getTypeIcon() {
    switch (bookSource.bookSourceType) {
      case 1:
        return Icons.headphones_rounded;
      case 2:
        return Icons.image_rounded;
      case 3:
        return Icons.description_rounded;
      case 0:
      default:
        return Icons.menu_book_rounded;
    }
  }
}
