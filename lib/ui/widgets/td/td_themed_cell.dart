import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// TDesign 风格的单元格组件
/// 支持 EInk 模式
class TDThemedCell extends StatelessWidget {
  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 描述文本
  final String? description;

  /// 左侧图标
  final IconData? leftIcon;

  /// 左侧图标颜色
  final Color? leftIconColor;

  /// 右侧图标
  final IconData? rightIcon;

  /// 右侧文本
  final String? rightText;

  /// 是否显示箭头
  final bool showArrow;

  /// 是否必填（显示红色星号）
  final bool required;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 是否禁用
  final bool disabled;

  /// 自定义左侧组件
  final Widget? leftWidget;

  /// 自定义右侧组件
  final Widget? rightWidget;

  /// 内边距
  final EdgeInsets? padding;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 副标题样式
  final TextStyle? subtitleStyle;

  /// 描述样式
  final TextStyle? descriptionStyle;

  /// 右侧文本样式
  final TextStyle? rightTextStyle;

  /// 背景色
  final Color? backgroundColor;

  /// 是否显示下边框
  final bool showBottomBorder;

  const TDThemedCell({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.leftIcon,
    this.leftIconColor,
    this.rightIcon,
    this.rightText,
    this.showArrow = false,
    this.required = false,
    this.onTap,
    this.onLongPress,
    this.disabled = false,
    this.leftWidget,
    this.rightWidget,
    this.padding,
    this.titleStyle,
    this.subtitleStyle,
    this.descriptionStyle,
    this.rightTextStyle,
    this.backgroundColor,
    this.showBottomBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return InkWell(
      onTap: disabled ? null : onTap,
      onLongPress: disabled ? null : onLongPress,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor ?? (isEink ? Colors.white : tdTheme.colorMap['bgColorContainer']),
          border: showBottomBorder
              ? Border(
                  bottom: BorderSide(
                    color: isEink ? Colors.black12 : tdTheme.grayColor3,
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 左侧图标或自定义组件
            if (leftWidget != null)
              leftWidget!
            else if (leftIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  leftIcon,
                  size: 24,
                  color: leftIconColor ??
                      (isEink ? Colors.black54 : tdTheme.brandNormalColor),
                ),
              ),

            // 标题区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题行
                  Row(
                    children: [
                      if (required)
                        Text(
                          '*',
                          style: TextStyle(
                            color: isEink ? Colors.black : tdTheme.errorNormalColor,
                            fontSize: 14,
                          ),
                        ),
                      Flexible(
                        child: Text(
                          title,
                          style: titleStyle ??
                              TextStyle(
                                fontSize: 16,
                                color: disabled
                                    ? (isEink ? Colors.black38 : tdTheme.fontGyColor4)
                                    : (isEink ? Colors.black : tdTheme.fontGyColor1),
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // 副标题
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: subtitleStyle ??
                          TextStyle(
                            fontSize: 12,
                            color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                          ),
                    ),
                  ],

                  // 描述
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: descriptionStyle ??
                          TextStyle(
                            fontSize: 14,
                            color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                          ),
                    ),
                  ],
                ],
              ),
            ),

            // 右侧区域
            if (rightWidget != null)
              rightWidget!
            else if (rightText != null || rightIcon != null || showArrow)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (rightText != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        rightText!,
                        style: rightTextStyle ??
                            TextStyle(
                              fontSize: 14,
                              color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                            ),
                      ),
                    ),
                  if (rightIcon != null)
                    Icon(
                      rightIcon,
                      size: 20,
                      color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                    ),
                  if (showArrow)
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: isEink ? Colors.black38 : tdTheme.grayColor5,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// TDesign 风格的单元格组
class TDThemedCellGroup extends StatelessWidget {
  /// 标题
  final String? title;

  /// 子单元格
  final List<Widget> children;

  /// 内边距
  final EdgeInsets? padding;

  /// 背景色
  final Color? backgroundColor;

  /// 标题内边距
  final EdgeInsets? titlePadding;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 是否显示边框
  final bool showBorder;

  /// 圆角
  final BorderRadius? borderRadius;

  const TDThemedCellGroup({
    super.key,
    this.title,
    required this.children,
    this.padding,
    this.backgroundColor,
    this.titlePadding,
    this.titleStyle,
    this.showBorder = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isEink ? Colors.white : tdTheme.colorMap['bgColorContainer']),
        border: showBorder
            ? Border.all(
                color: isEink ? Colors.black12 : tdTheme.grayColor3,
                width: 0.5,
              )
            : null,
        borderRadius: borderRadius ?? (isEink ? null : BorderRadius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: titlePadding ?? const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                title!,
                style: titleStyle ??
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                    ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

/// TDesign 风格的开关单元格
class TDThemedSwitchCell extends StatelessWidget {
  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 当前值
  final bool value;

  /// 值改变回调
  final ValueChanged<bool>? onChanged;

  /// 是否禁用
  final bool disabled;

  /// 左侧图标
  final IconData? leftIcon;

  /// 左侧图标颜色
  final Color? leftIconColor;

  const TDThemedSwitchCell({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.disabled = false,
    this.leftIcon,
    this.leftIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEink ? Colors.white : tdTheme.colorMap['bgColorContainer'],
        border: Border(
          bottom: BorderSide(
            color: isEink ? Colors.black12 : tdTheme.grayColor3,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (leftIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                leftIcon,
                size: 24,
                color: leftIconColor ??
                    (isEink ? Colors.black54 : tdTheme.brandNormalColor),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: disabled
                        ? (isEink ? Colors.black38 : tdTheme.fontGyColor4)
                        : (isEink ? Colors.black : tdTheme.fontGyColor1),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TDSwitch(
            isOn: value,
            enable: !disabled,
            onChanged: onChanged != null
                ? (bool isOn) {
                    onChanged?.call(isOn);
                  }
                : null,
            trackOnColor: isEink ? Colors.black : tdTheme.brandNormalColor,
            trackOffColor: isEink ? Colors.black12 : tdTheme.grayColor4,
          ),
        ],
      ),
    );
  }
}
