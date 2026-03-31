import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// TDesign 风格的底部导航栏项
class TDThemedNavItem {
  /// 图标
  final IconData icon;

  /// 选中图标
  final IconData? selectedIcon;

  /// 标签
  final String label;

  /// 徽标数字
  final int? badgeCount;

  /// 徽标文本
  final String? badgeText;

  /// 是否显示小红点
  final bool showDot;

  const TDThemedNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badgeCount,
    this.badgeText,
    this.showDot = false,
  });
}

/// TDesign 风格的底部导航栏组件
/// 使用 Material NavigationBar 实现，支持 EInk 模式
class TDThemedBottomNavBar extends StatelessWidget {
  /// 当前选中索引
  final int currentIndex;

  /// 选中变化回调
  final ValueChanged<int>? onChanged;

  /// 导航项列表
  final List<TDThemedNavItem> items;

  /// 背景色
  final Color? backgroundColor;

  /// 选中颜色
  final Color? selectedColor;

  /// 未选中颜色
  final Color? unselectedColor;

  /// 高度
  final double? height;

  const TDThemedBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onChanged,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    // EInk 模式使用简化的导航栏
    if (isEink) {
      return _buildEInkNavBar(context);
    }

    // 使用 Material NavigationBar，适配 TDesign 风格
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onChanged,
      backgroundColor: backgroundColor ?? tdTheme.colorMap['bgColorContainer'],
      indicatorColor: tdTheme.brandNormalColor.withValues(alpha: 0.1),
      height: height,
      destinations: items.map((item) {
        return NavigationDestination(
          icon: _buildIconWithBadge(item, false, tdTheme),
          selectedIcon: _buildIconWithBadge(item, true, tdTheme),
          label: item.label,
        );
      }).toList(),
    );
  }

  /// 构建带徽标的图标
  Widget _buildIconWithBadge(TDThemedNavItem item, bool isSelected, TDThemeData tdTheme) {
    final icon = Icon(
      isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
      color: isSelected
          ? (selectedColor ?? tdTheme.brandNormalColor)
          : (unselectedColor ?? tdTheme.fontGyColor3),
    );

    if (item.badgeCount != null && item.badgeCount! > 0) {
      return Badge(
        label: Text(
          item.badgeCount! > 99 ? '99+' : item.badgeCount.toString(),
        ),
        backgroundColor: tdTheme.errorNormalColor,
        child: icon,
      );
    }

    if (item.badgeText != null && item.badgeText!.isNotEmpty) {
      return Badge(
        label: Text(item.badgeText!),
        backgroundColor: tdTheme.errorNormalColor,
        child: icon,
      );
    }

    if (item.showDot) {
      return Badge(
        backgroundColor: tdTheme.errorNormalColor,
        smallSize: 8,
        child: icon,
      );
    }

    return icon;
  }

  /// 构建 EInk 模式导航栏
  Widget _buildEInkNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height ?? 60,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onChanged?.call(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isSelected
                                ? (item.selectedIcon ?? item.icon)
                                : item.icon,
                            color: isSelected ? Colors.black : Colors.black54,
                            size: 24,
                          ),
                          if (item.badgeCount != null && item.badgeCount! > 0)
                            Positioned(
                              right: -8,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item.badgeCount! > 99
                                      ? '99+'
                                      : item.badgeCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          if (item.showDot &&
                              (item.badgeCount == null || item.badgeCount == 0))
                            Positioned(
                              right: -2,
                              top: 0,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.black54,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
