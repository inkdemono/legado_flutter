import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// TDesign 按钮类型
enum TDThemedButtonType {
  /// 填充按钮（默认）
  filled,
  /// 描边按钮
  outline,
  /// 文本按钮
  text,
  /// 渐变按钮
  gradient,
}

/// TDesign 按钮尺寸
enum TDThemedButtonSize {
  /// 大尺寸
  large,
  /// 中尺寸
  medium,
  /// 小尺寸
  small,
}

/// TDesign 风格的统一按钮组件
/// 封装 TDButton，支持多种样式和 EInk 模式
class TDThemedButton extends StatelessWidget {
  /// 按钮文本
  final String label;

  /// 点击回调
  final VoidCallback? onTap;

  /// 按钮类型
  final TDThemedButtonType type;

  /// 按钮尺寸
  final TDThemedButtonSize size;

  /// 图标
  final IconData? icon;

  /// 是否加载中
  final bool isLoading;

  /// 是否禁用
  final bool isDisabled;

  /// 是否选中状态
  final bool isSelected;

  /// 自定义背景色
  final Color? backgroundColor;

  /// 自定义文字颜色
  final Color? textColor;

  /// 自定义边框颜色
  final Color? borderColor;

  /// 是否全宽
  final bool isFullWidth;

  /// 内边距
  final EdgeInsets? padding;

  /// 外边距
  final EdgeInsets? margin;

  /// 渐变颜色（仅当 type = gradient 时有效）
  final List<Color>? gradientColors;

  const TDThemedButton({
    super.key,
    required this.label,
    this.onTap,
    this.type = TDThemedButtonType.filled,
    this.size = TDThemedButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isSelected = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.isFullWidth = false,
    this.padding,
    this.margin,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;

    // EInk 模式使用简化的按钮样式
    if (isEink) {
      return _buildEInkButton(context);
    }

    // 渐变按钮使用自定义实现
    if (type == TDThemedButtonType.gradient) {
      return _buildGradientButton(context);
    }

    // 使用 TDButton
    return Container(
      margin: margin,
      width: isFullWidth ? double.infinity : null,
      child: TDButton(
        text: label,
        icon: icon,
        theme: _getButtonTheme(),
        type: _getButtonType(),
        size: _getButtonSize(),
        onTap: isDisabled || isLoading ? null : onTap,
        disabled: isDisabled,
        isBlock: isFullWidth,
      ),
    );
  }

  /// 构建 EInk 模式按钮
  Widget _buildEInkButton(BuildContext context) {
    return Container(
      margin: margin,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled || isLoading ? null : onTap,
          borderRadius: BorderRadius.zero,
          child: Container(
            padding: padding ?? _getDefaultPadding(),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isDisabled ? Colors.black26 : Colors.black54,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (icon != null) ...[
                  Icon(icon, size: _getIconSize(), color: Colors.black),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isDisabled ? Colors.black26 : Colors.black,
                    fontSize: _getFontSize(),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建渐变按钮
  Widget _buildGradientButton(BuildContext context) {
    final tdTheme = TDTheme.of(context);
    final colors = gradientColors ??
        [
          tdTheme.brandNormalColor,
          tdTheme.brandHoverColor,
        ];

    return Container(
      margin: margin,
      height: _getHeight(),
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled || isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Padding(
              padding: padding ?? _getDefaultPadding(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else if (icon != null) ...[
                    Icon(icon, size: _getIconSize(), color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: _getFontSize(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 获取按钮主题
  TDButtonTheme _getButtonTheme() {
    if (isSelected) {
      return TDButtonTheme.primary;
    }
    switch (type) {
      case TDThemedButtonType.filled:
        return TDButtonTheme.primary;
      case TDThemedButtonType.outline:
        return TDButtonTheme.defaultTheme;
      case TDThemedButtonType.text:
        return TDButtonTheme.defaultTheme;
      case TDThemedButtonType.gradient:
        return TDButtonTheme.primary;
    }
  }

  /// 获取按钮类型
  TDButtonType _getButtonType() {
    switch (type) {
      case TDThemedButtonType.filled:
      case TDThemedButtonType.gradient:
        return TDButtonType.fill;
      case TDThemedButtonType.outline:
        return TDButtonType.outline;
      case TDThemedButtonType.text:
        return TDButtonType.text;
    }
  }

  /// 获取按钮尺寸
  TDButtonSize _getButtonSize() {
    switch (size) {
      case TDThemedButtonSize.large:
        return TDButtonSize.large;
      case TDThemedButtonSize.medium:
        return TDButtonSize.medium;
      case TDThemedButtonSize.small:
        return TDButtonSize.small;
    }
  }

  /// 获取字体大小
  double _getFontSize() {
    switch (size) {
      case TDThemedButtonSize.large:
        return 16;
      case TDThemedButtonSize.medium:
        return 14;
      case TDThemedButtonSize.small:
        return 12;
    }
  }

  /// 获取图标大小
  double _getIconSize() {
    switch (size) {
      case TDThemedButtonSize.large:
        return 24;
      case TDThemedButtonSize.medium:
        return 20;
      case TDThemedButtonSize.small:
        return 16;
    }
  }

  /// 获取高度
  double _getHeight() {
    switch (size) {
      case TDThemedButtonSize.large:
        return 48;
      case TDThemedButtonSize.medium:
        return 40;
      case TDThemedButtonSize.small:
        return 32;
    }
  }

  /// 获取默认内边距
  EdgeInsets _getDefaultPadding() {
    switch (size) {
      case TDThemedButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case TDThemedButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case TDThemedButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    }
  }
}

/// TDesign 风格的图标按钮组件
class TDThemedIconButton extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 标签（可选）
  final String? label;

  /// 点击回调
  final VoidCallback? onTap;

  /// 图标颜色
  final Color? iconColor;

  /// 图标大小
  final double? iconSize;

  /// 内边距
  final EdgeInsets? padding;

  /// 按钮尺寸
  final TDThemedButtonSize size;

  /// 是否禁用
  final bool isDisabled;

  const TDThemedIconButton({
    super.key,
    required this.icon,
    this.label,
    this.onTap,
    this.iconColor,
    this.iconSize,
    this.padding,
    this.size = TDThemedButtonSize.medium,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(isEink ? 0 : 8),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: iconColor ??
                  (isEink ? Colors.black : tdTheme.fontGyColor1),
              size: iconSize ?? _getIconSize(),
            ),
            if (label != null) ...[
              const SizedBox(height: 4),
              Text(
                label!,
                style: TextStyle(
                  color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _getIconSize() {
    switch (size) {
      case TDThemedButtonSize.large:
        return 24;
      case TDThemedButtonSize.medium:
        return 20;
      case TDThemedButtonSize.small:
        return 16;
    }
  }
}

/// TDesign 风格的文本按钮组件
class TDThemedTextButton extends StatelessWidget {
  /// 按钮文本
  final String label;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 文字颜色
  final Color? textColor;

  /// 是否为主要按钮
  final bool isPrimary;

  /// 是否禁用
  final bool isDisabled;

  const TDThemedTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.textColor,
    this.isPrimary = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // isEink 和 tdTheme 用于未来扩展
    // final isEink = EInkTDTheme.isEInkMode;
    // final tdTheme = TDTheme.of(context);

    return TDButton(
      text: label,
      theme: TDButtonTheme.defaultTheme,
      type: TDButtonType.text,
      onTap: isDisabled ? null : onPressed,
      disabled: isDisabled,
    );
  }
}
