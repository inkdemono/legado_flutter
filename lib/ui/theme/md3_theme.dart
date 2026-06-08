import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

/// Material Design 3 风格的颜色调色板
class MD3Palette {
  // 主色调 - 从种子色生成
  static Color primary(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color onPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  static Color primaryContainer(BuildContext context) {
    return Theme.of(context).colorScheme.primaryContainer;
  }

  static Color onPrimaryContainer(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimaryContainer;
  }

  // 次要色调
  static Color secondary(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color onSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.onSecondary;
  }

  static Color secondaryContainer(BuildContext context) {
    return Theme.of(context).colorScheme.secondaryContainer;
  }

  static Color onSecondaryContainer(BuildContext context) {
    return Theme.of(context).colorScheme.onSecondaryContainer;
  }

  // 强调色
  static Color tertiary(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary;
  }

  static Color onTertiary(BuildContext context) {
    return Theme.of(context).colorScheme.onTertiary;
  }

  static Color tertiaryContainer(BuildContext context) {
    return Theme.of(context).colorScheme.tertiaryContainer;
  }

  static Color onTertiaryContainer(BuildContext context) {
    return Theme.of(context).colorScheme.onTertiaryContainer;
  }

  // 背景色
  static Color background(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  static Color onBackground(BuildContext context) {
    return Theme.of(context).colorScheme.onBackground;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color onSurface(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color surfaceVariant(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceVariant;
  }

  static Color onSurfaceVariant(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  // 轮廓和边框
  static Color outline(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  static Color outlineVariant(BuildContext context) {
    return Theme.of(context).colorScheme.outlineVariant;
  }

  // 状态色
  static Color error(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  static Color onError(BuildContext context) {
    return Theme.of(context).colorScheme.onError;
  }

  static Color errorContainer(BuildContext context) {
    return Theme.of(context).colorScheme.errorContainer;
  }

  static Color onErrorContainer(BuildContext context) {
    return Theme.of(context).colorScheme.onErrorContainer;
  }

  // 阴影
  static List<BoxShadow> elevationOverlay(BuildContext context, {double elevation = 1}) {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      // 深色模式下使用叠加层
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: elevation * 0.12),
          blurRadius: 4 + elevation * 2,
          offset: Offset(0, 2 + elevation),
        ),
      ];
    } else {
      // 浅色模式下使用柔和阴影
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8 + elevation * 2,
          offset: Offset(0, 2 + elevation),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4 + elevation,
          offset: Offset(0, 1),
        ),
      ];
    }
  }
}

/// 毛玻璃效果容器 - 灵感来自 legado-with-MD3
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? tintColor;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.7,
    this.tintColor,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final defaultTintColor = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.4);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (tintColor ?? defaultTintColor).withValues(alpha: opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(24),
              border: border ??
                  Border.all(
                    color: brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
              boxShadow: MD3Palette.elevationOverlay(context, elevation: 2),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 现代化卡片 - Material Design 3 风格
class MD3Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final VoidCallback? onTap;
  final double elevation;
  final BorderRadius? borderRadius;

  const MD3Card({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.color,
    this.onTap,
    this.elevation = 1,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    final cardColor = color ?? MD3Palette.surface(context);

    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        border: Border.all(
          color: MD3Palette.outlineVariant(context).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: MD3Palette.elevationOverlay(context, elevation: elevation),
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: card,
      ),
    );
  }
}

/// 填充式按钮 - Material Design 3 风格
class MD3FilledButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;

  const MD3FilledButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: FilledButton.icon(
        onPressed: enabled && !isLoading ? onPressed : null,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : icon != null
                ? Icon(icon, size: 18)
                : null,
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}

/// 轮廓按钮 - Material Design 3 风格
class MD3OutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;

  const MD3OutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: enabled && !isLoading ? onPressed : null,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : icon != null
                ? Icon(icon, size: 18)
                : null,
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          side: BorderSide(
            color: MD3Palette.outline(context),
            width: 1,
          ),
        ),
      ),
    );
  }
}

/// 文本按钮 - Material Design 3 风格
class MD3TextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;

  const MD3TextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

/// 药丸形状标签
class MDPillChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;

  const MDPillChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = isSelected
        ? (selectedColor ?? MD3Palette.primaryContainer(context))
        : MD3Palette.surfaceVariant(context);
    final textColor = isSelected
        ? (selectedColor != null
            ? Colors.white
            : MD3Palette.onPrimaryContainer(context))
        : MD3Palette.onSurfaceVariant(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : MD3Palette.outlineVariant(context),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: textColor,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 搜索框 - Material Design 3 风格
class MD3SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool showClearButton;

  const MD3SearchField({
    super.key,
    this.controller,
    this.hintText = '搜索',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: MD3Palette.surfaceVariant(context),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        style: TextStyle(
          color: MD3Palette.onSurface(context),
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: MD3Palette.onSurfaceVariant(context).withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: MD3Palette.onSurfaceVariant(context),
            size: 22,
          ),
          suffixIcon: showClearButton &&
                  controller != null &&
                  controller!.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller!.clear();
                    onChanged?.call('');
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: MD3Palette.onSurfaceVariant(context),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

/// 顶部应用栏 - 毛玻璃效果
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final double blur;
  final Color? backgroundColor;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.blur = 20.0,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? MD3Palette.surface(context))
                .withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  if (leading != null)
                    leading!
                  else if (showBackButton && Navigator.canPop(context))
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: MD3Palette.onSurface(context),
                        size: 20,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: MD3Palette.onSurface(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (actions != null) ...actions!,
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 分段控制器 - Material Design 3 风格
class MD3SegmentedControl<T extends Enum> extends StatelessWidget {
  final T value;
  final List<T> options;
  final ValueChanged<T> onValueChanged;
  final Map<T, String> labels;
  final Map<T, IconData>? icons;

  const MD3SegmentedControl({
    super.key,
    required this.value,
    required this.options,
    required this.onValueChanged,
    required this.labels,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: MD3Palette.surfaceVariant(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final option = options[index];
          final isSelected = option == value;
          final isLast = index == options.length - 1;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onValueChanged(option),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? MD3Palette.primaryContainer(context)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icons != null && icons![option] != null) ...[
                          Icon(
                            icons![option],
                            size: 18,
                            color: isSelected
                                ? MD3Palette.onPrimaryContainer(context)
                                : MD3Palette.onSurfaceVariant(context),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          labels[option]!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? MD3Palette.onPrimaryContainer(context)
                                : MD3Palette.onSurfaceVariant(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 动态取色主题生成器
class DynamicThemeGenerator {
  /// 从种子色生成 Material 3 颜色方案
  static ThemeData generateTheme(Color seedColor, {bool isDark = false}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
