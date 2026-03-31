import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// TDesign 风格的卡片组件
/// 支持 EInk 模式
class TDThemedCard extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 标题
  final String? title;

  /// 副标题
  final String? subtitle;

  /// 右侧操作组件
  final Widget? trailing;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 背景色
  final Color? color;

  /// 圆角
  final BorderRadius? borderRadius;

  /// 边框
  final Border? border;

  /// 是否显示阴影
  final bool showShadow;

  /// 是否透明背景
  final bool transparent;

  /// 高度
  final double? height;

  /// 宽度
  final double? width;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 标题内边距
  final EdgeInsetsGeometry? titlePadding;

  /// 内容内边距
  final EdgeInsetsGeometry? contentPadding;

  /// 是否显示分割线
  final bool showDivider;

  /// 分割线颜色
  final Color? dividerColor;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 副标题样式
  final TextStyle? subtitleStyle;

  const TDThemedCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.margin,
    this.padding,
    this.color,
    this.borderRadius,
    this.border,
    this.showShadow = true,
    this.transparent = false,
    this.height,
    this.width,
    this.onTap,
    this.onLongPress,
    this.titlePadding,
    this.contentPadding,
    this.showDivider = false,
    this.dividerColor,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    final bgColor = transparent
        ? Colors.transparent
        : (color ?? (isEink ? Colors.white : tdTheme.colorMap['bgColorContainer']));

    final effectiveBorderRadius = borderRadius ??
        (isEink ? BorderRadius.zero : BorderRadius.circular(8));

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: effectiveBorderRadius,
        border: border ??
            (isEink || transparent
                ? null
                : null),
        boxShadow: showShadow && !isEink && !transparent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题区域
          if (title != null || trailing != null) _buildTitleBar(isEink, tdTheme),
          // 分割线
          if (showDivider && (title != null || trailing != null))
            Divider(
              height: 1,
              color: dividerColor ?? (isEink ? Colors.black12 : tdTheme.grayColor3),
            ),
          // 内容区域
          Padding(
            padding: contentPadding ?? padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );

    if (onTap != null || onLongPress != null) {
      card = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: effectiveBorderRadius,
        child: card,
      );
    }

    return card;
  }

  Widget _buildTitleBar(bool isEink, TDThemeData tdTheme) {
    return Container(
      padding: titlePadding ?? const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: titleStyle ??
                        TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isEink ? Colors.black : tdTheme.fontGyColor1,
                        ),
                  ),
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
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// TDesign 风格的简单卡片
class TDThemedSimpleCard extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 背景色
  final Color? color;

  /// 圆角
  final BorderRadius? borderRadius;

  /// 是否显示阴影
  final bool showShadow;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  const TDThemedSimpleCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.borderRadius,
    this.showShadow = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    final bgColor = color ?? (isEink ? Colors.white : tdTheme.colorMap['bgColorContainer']);
    final effectiveBorderRadius = borderRadius ??
        (isEink ? BorderRadius.zero : BorderRadius.circular(8));

    Widget card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: effectiveBorderRadius,
        border: isEink ? Border.all(color: Colors.black12, width: 1) : null,
        boxShadow: showShadow && !isEink
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      card = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: effectiveBorderRadius,
        child: card,
      );
    }

    return card;
  }
}

/// TDesign 风格的列表项卡片
class TDThemedListCard extends StatelessWidget {
  /// 标题
  final String title;

  /// 描述
  final String? description;

  /// 左侧图标
  final IconData? leadingIcon;

  /// 左侧图标颜色
  final Color? leadingIconColor;

  /// 右侧组件
  final Widget? trailing;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 背景色
  final Color? color;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 是否显示箭头
  final bool showArrow;

  const TDThemedListCard({
    super.key,
    required this.title,
    this.description,
    this.leadingIcon,
    this.leadingIconColor,
    this.trailing,
    this.margin,
    this.color,
    this.onTap,
    this.onLongPress,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    final bgColor = color ?? (isEink ? Colors.white : tdTheme.colorMap['bgColorContainer']);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: isEink ? null : BorderRadius.circular(8),
        border: isEink ? Border.all(color: Colors.black12, width: 1) : null,
        boxShadow: !isEink
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: isEink ? null : BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (leadingIcon != null)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEink
                        ? Colors.grey.shade200
                        : tdTheme.brandLightColor.withValues(alpha: 0.3),
                    borderRadius: isEink ? null : BorderRadius.circular(8),
                  ),
                  child: Icon(
                    leadingIcon,
                    size: 24,
                    color: leadingIconColor ??
                        (isEink ? Colors.black : tdTheme.brandNormalColor),
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
                        fontWeight: FontWeight.w500,
                        color: isEink ? Colors.black : tdTheme.fontGyColor1,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: isEink ? Colors.black38 : tdTheme.grayColor5,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
