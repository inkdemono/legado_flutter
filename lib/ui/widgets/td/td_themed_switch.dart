import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// TDesign 风格的开关组件
/// 封装 TDSwitch，支持 EInk 模式
class TDThemedSwitch extends StatelessWidget {
  /// 当前值
  final bool value;

  /// 值变化回调
  final ValueChanged<bool>? onChanged;

  /// 是否禁用
  final bool isDisabled;

  /// 激活颜色
  final Color? activeColor;

  /// 非激活颜色
  final Color? inactiveColor;

  const TDThemedSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.isDisabled = false,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;

    // EInk 模式使用简化的开关样式
    if (isEink) {
      return _buildEInkSwitch();
    }

    return TDSwitch(
      isOn: value,
      enable: !isDisabled,
      trackOnColor: activeColor,
      trackOffColor: inactiveColor,
      onChanged: (bool newValue) {
        onChanged?.call(newValue);
      },
    );
  }

  /// 构建 EInk 模式开关
  Widget _buildEInkSwitch() {
    return GestureDetector(
      onTap: isDisabled ? null : () => onChanged?.call(!value),
      child: Container(
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: value ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.zero,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: value ? Colors.white : Colors.black,
              border: Border.all(
                color: value ? Colors.white : Colors.black,
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// TDesign 风格的开关列表项组件
class TDThemedSwitchListTile extends StatelessWidget {
  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 当前值
  final bool value;

  /// 值变化回调
  final ValueChanged<bool>? onChanged;

  /// 是否禁用
  final bool isDisabled;

  /// 激活颜色
  final Color? activeColor;

  /// 左侧图标
  final IconData? leadingIcon;

  const TDThemedSwitchListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.isDisabled = false,
    this.activeColor,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    if (isEink) {
      return _buildEInkListTile();
    }

    return InkWell(
      onTap: isDisabled ? null : () => onChanged?.call(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: tdTheme.colorMap['bgColorContainer'] ?? tdTheme.grayColor1,
          border: Border(
            bottom: BorderSide(color: tdTheme.grayColor3, width: 1),
          ),
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: 24,
                color: tdTheme.fontGyColor1,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: tdTheme.fontGyColor1,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: tdTheme.fontGyColor3,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            TDThemedSwitch(
              value: value,
              onChanged: onChanged,
              isDisabled: isDisabled,
              activeColor: activeColor,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建 EInk 模式列表项
  Widget _buildEInkListTile() {
    return InkWell(
      onTap: isDisabled ? null : () => onChanged?.call(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 24, color: Colors.black),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            TDThemedSwitch(
              value: value,
              onChanged: onChanged,
              isDisabled: isDisabled,
              activeColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
