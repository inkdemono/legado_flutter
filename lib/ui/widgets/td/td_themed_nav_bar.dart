import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// TDesign 风格的导航栏组件
/// 封装 AppBar，支持 EInk 模式和 TDesign 主题
class TDThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 标题文本
  final String? title;

  /// 标题 Widget
  final Widget? titleWidget;

  /// 前导 Widget
  final Widget? leading;

  /// 操作按钮
  final List<Widget>? actions;

  /// 是否自动实现前导按钮
  final bool automaticallyImplyLeading;

  /// 是否居中标题
  final bool centerTitle;

  /// 背景色
  final Color? backgroundColor;

  /// 前景色
  final Color? foregroundColor;

  /// 底部 Widget
  final PreferredSizeWidget? bottom;

  /// 高度
  final double? height;

  /// 返回按钮点击回调
  final VoidCallback? onBack;

  /// 是否显示返回按钮
  final bool showBack;

  /// 标题样式
  final TextStyle? titleTextStyle;

  /// 阴影
  final double? elevation;

  const TDThemedAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.height,
    this.onBack,
    this.showBack = true,
    this.titleTextStyle,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // EInk 模式使用简化的 AppBar
    if (isEink) {
      return _buildEInkAppBar(context);
    }

    // 深色模式使用容器背景色，浅色模式使用主色
    final effectiveBgColor = backgroundColor ??
        (isDark
            ? tdTheme.colorMap['bgColorContainer'] ?? const Color(0xFF1E1E1E)
            : tdTheme.brandNormalColor);

    // 深色模式使用浅色前景，浅色模式使用白色前景
    final effectiveFgColor = foregroundColor ??
        (isDark ? tdTheme.fontGyColor1 : Colors.white);

    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading && showBack,
      centerTitle: centerTitle,
      backgroundColor: effectiveBgColor,
      foregroundColor: effectiveFgColor,
      titleTextStyle: titleTextStyle ??
          TextStyle(
            color: effectiveFgColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
      toolbarHeight: height,
      elevation: elevation ?? 0,
      bottom: bottom,
      iconTheme: IconThemeData(color: effectiveFgColor),
    );
  }

  /// 构建 EInk 模式 AppBar
  Widget _buildEInkAppBar(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading && showBack,
      centerTitle: centerTitle,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      titleTextStyle: titleTextStyle ??
          const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
      toolbarHeight: height,
      elevation: 0,
      bottom: bottom,
      shape: const Border(
        bottom: BorderSide(color: Colors.black12, width: 1),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        (height ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
      );
}

/// TDesign 风格的搜索栏组件
class TDThemedSearchBar extends StatelessWidget {
  /// 占位文本
  final String? placeholder;

  /// 值变化回调
  final ValueChanged<String>? onChanged;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否自动聚焦
  final bool autofocus;

  /// 控制器
  final TextEditingController? controller;

  /// 是否显示清除按钮
  final bool showClear;

  /// 背景色
  final Color? backgroundColor;

  /// 前景色
  final Color? textColor;

  /// 提示文字颜色
  final Color? hintColor;

  const TDThemedSearchBar({
    super.key,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.autofocus = false,
    this.controller,
    this.showClear = true,
    this.backgroundColor,
    this.textColor,
    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 深色模式使用更深的背景色
    final effectiveBgColor = backgroundColor ??
        (isEink
            ? Colors.grey[200]
            : isDark
                ? tdTheme.colorMap['grayColor4'] ?? const Color(0xFF2A2A2A)
                : tdTheme.grayColor2);

    // 深色模式使用浅色文字
    final effectiveTextColor = textColor ??
        (isEink
            ? Colors.black
            : tdTheme.fontGyColor1);

    final effectiveHintColor = hintColor ??
        (isEink
            ? Colors.black54
            : tdTheme.fontGyColor3);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        style: TextStyle(color: effectiveTextColor),
        decoration: InputDecoration(
          hintText: placeholder ?? '搜索',
          hintStyle: TextStyle(color: effectiveHintColor),
          prefixIcon: Icon(
            Icons.search,
            color: effectiveHintColor,
          ),
          suffixIcon: showClear && controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: effectiveHintColor,
                  ),
                  onPressed: () {
                    controller?.clear();
                    onChanged?.call('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}
