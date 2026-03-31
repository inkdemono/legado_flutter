import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../config/app_config.dart';

/// 电子墨水屏 (EInk) TDesign 主题配置
/// EInk 屏幕需要特殊处理：无圆角、无阴影、高对比度
class EInkTDTheme {
  /// 是否启用电子墨水屏模式
  static bool get isEInkMode =>
      AppConfig.getBool('eink_mode', defaultValue: false);

  /// 获取 EInk 主题数据
  static TDThemeData getEInkTheme() {
    final themeJson = {
      'eink': {
        'color': {
          'brandNormalColor': '#000000',
          'brandHoverColor': '#333333',
          'brandClickColor': '#000000',
          'bgColorPage': '#FFFFFF',
          'bgColorContainer': '#FFFFFF',
          'bgColorSecondaryContainer': '#F5F5F5',
          'fontGyColor1': '#E6000000',
          'fontGyColor2': '#99000000',
          'fontGyColor3': '#66000000',
          'fontGyColor4': '#42000000',
          'errorNormalColor': '#000000',
          'warningNormalColor': '#333333',
          'successNormalColor': '#000000',
          'grayColor3': '#E7E7E7',
        },
        'font': {
          'fontBodyLarge': {'size': 16, 'lineHeight': 24},
          'fontBodyMedium': {'size': 14, 'lineHeight': 22},
          'fontBodySmall': {'size': 12, 'lineHeight': 20},
        },
        'radius': {
          'default': 0,
          'round': 0,
        },
      }
    };

    return TDThemeData.fromJson('eink', jsonEncode(themeJson)) ??
        TDThemeData.defaultData();
  }

  /// 从 TDThemeData 生成 EInk 适用的 Flutter ThemeData
  static ThemeData toEInkFlutterTheme(TDThemeData tdTheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        secondary: Colors.black54,
        surface: Colors.white,
        error: Colors.black,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
      ),
      dividerColor: Colors.black26,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      extensions: [tdTheme],
    );
  }

  /// 根据当前模式获取背景色
  static Color getBackgroundColor(BuildContext context) {
    if (isEInkMode) {
      return Colors.white;
    }
    return TDTheme.of(context).colorMap['bgColorPage'] ?? const Color(0xFFF3F3F3);
  }

  /// 根据当前模式获取前景色
  static Color getForegroundColor(BuildContext context) {
    if (isEInkMode) {
      return Colors.black;
    }
    return TDTheme.of(context).fontGyColor1;
  }

  /// 根据当前模式获取卡片装饰
  static BoxDecoration getCardDecoration(BuildContext context) {
    if (isEInkMode) {
      return BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12, width: 1),
      );
    }
    final bgColorContainer = TDTheme.of(context).colorMap['bgColorContainer'] ?? const Color(0xFFFFFFFF);
    return BoxDecoration(
      color: bgColorContainer,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// 根据当前模式获取按钮样式
  static ButtonStyle getButtonStyle(BuildContext context) {
    if (isEInkMode) {
      return ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        foregroundColor: WidgetStateProperty.all(Colors.black),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: const BorderSide(color: Colors.black54),
          ),
        ),
        splashFactory: NoSplash.splashFactory,
      );
    }
    return ButtonStyle(
      backgroundColor:
          WidgetStateProperty.all(TDTheme.of(context).brandNormalColor),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// 包装组件以应用 EInk 样式
  static Widget wrapWithEInkStyle(Widget child) {
    if (!isEInkMode) return child;
    return Theme(
      data: ThemeData(
        shadowColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: child,
    );
  }

  /// 获取 EInk 模式下的圆角
  static double getBorderRadius() {
    return isEInkMode ? 0 : 8;
  }

  /// 获取 EInk 模式下的阴影
  static List<BoxShadow> getBoxShadows() {
    return isEInkMode
        ? []
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ];
  }
}
