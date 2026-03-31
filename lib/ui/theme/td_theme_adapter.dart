import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// TDesign 主题适配器
/// 用于将现有主题配置转换为 TDesign 主题，并生成 Flutter ThemeData
class TDesignThemeAdapter {
  /// 将现有主题配置转换为 TDThemeData
  static TDThemeData fromAppTheme({
    required Color primary,
    required Color accent,
    required Color background,
    required Color bottomBackground,
    bool isDark = false,
  }) {
    // 深色模式使用白色/浅色字体，浅色模式使用黑色/深色字体
    final fontColor1 = isDark ? const Color(0xFFFFFFFF) : const Color(0xE6000000);
    final fontColor2 = isDark ? const Color(0xB3FFFFFF) : const Color(0x99000000);
    final fontColor3 = isDark ? const Color(0x80FFFFFF) : const Color(0x66000000);
    final fontColor4 = isDark ? const Color(0x4DFFFFFF) : const Color(0x42000000);

    // 深色模式调整主色调（稍微提亮以增加对比度）
    final effectivePrimary = isDark ? _lightenColor(primary, 0.15) : primary;

    final themeJson = {
      'custom': {
        'color': {
          'brandNormalColor': _colorToHex(effectivePrimary),
          'brandHoverColor': _colorToHex(_lightenColor(effectivePrimary, 0.1)),
          'brandClickColor': _colorToHex(_darkenColor(effectivePrimary, 0.1)),
          'brandLightColor': _colorToHex(isDark
              ? effectivePrimary.withValues(alpha: 0.2)
              : _lightenColor(effectivePrimary, 0.3)),
          'bgColorPage': _colorToHex(background),
          'bgColorContainer': _colorToHex(bottomBackground),
          'fontGyColor1': _colorToHex(fontColor1),
          'fontGyColor2': _colorToHex(fontColor2),
          'fontGyColor3': _colorToHex(fontColor3),
          'fontGyColor4': _colorToHex(fontColor4),
          // 深色模式图标颜色
          'iconColor1': _colorToHex(isDark ? const Color(0xFFFFFFFF) : const Color(0xE6000000)),
          'iconColor2': _colorToHex(isDark ? const Color(0xB3FFFFFF) : const Color(0x99000000)),
          // 分割线颜色
          'grayColor3': _colorToHex(isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE7E7E7)),
          'grayColor4': _colorToHex(isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F3F3)),
          // 成功/警告/错误颜色（深色模式提亮）
          'successNormalColor': _colorToHex(isDark
              ? const Color(0xFF2BA47D)
              : const Color(0xFF00A870)),
          'successLightColor': _colorToHex(isDark
              ? const Color(0xFF1A3D32)
              : const Color(0xFFE3F9E9)),
          'warningNormalColor': _colorToHex(isDark
              ? const Color(0xFFE37318)
              : const Color(0xFFED7B2F)),
          'warningLightColor': _colorToHex(isDark
              ? const Color(0xFF3D2A1A)
              : const Color(0xFFFFF1E9)),
          'errorNormalColor': _colorToHex(isDark
              ? const Color(0xFFE37373)
              : const Color(0xFFD54941)),
          'errorLightColor': _colorToHex(isDark
              ? const Color(0xFF3D1A1A)
              : const Color(0xFFFFF0ED)),
          // 白色（用于对话框背景等）
          'whiteColor1': _colorToHex(isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF)),
        },
        'font': {
          'fontBodyLarge': {'size': 16, 'lineHeight': 24},
          'fontBodyMedium': {'size': 14, 'lineHeight': 22},
          'fontBodySmall': {'size': 12, 'lineHeight': 20},
        },
      }
    };

    return TDThemeData.fromJson('custom', jsonEncode(themeJson)) ??
        TDThemeData.defaultData();
  }

  /// 从 TDThemeData 生成 Flutter ThemeData
  static ThemeData toFlutterTheme(
    TDThemeData tdTheme, {
    required bool isDark,
  }) {
    final brightness = isDark ? Brightness.dark : Brightness.light;

    // 使用 colorMap 安全获取颜色，提供默认值
    final bgColorPage = tdTheme.colorMap['bgColorPage'] ??
        (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF3F3F3));
    final bgColorContainer = tdTheme.colorMap['bgColorContainer'] ??
        (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF));
    final fontGyColor1 = tdTheme.colorMap['fontGyColor1'] ??
        (isDark ? const Color(0xFFFFFFFF) : const Color(0xE6000000));
    final fontGyColor3 = tdTheme.colorMap['fontGyColor3'] ??
        (isDark ? const Color(0x80FFFFFF) : const Color(0x66000000));

    // 深色模式使用更亮的主色调
    final primaryColor = tdTheme.brandNormalColor;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        primary: primaryColor,
        secondary: tdTheme.brandClickColor,
        surface: bgColorPage,
        error: tdTheme.errorNormalColor,
        onPrimary: isDark ? Colors.black : Colors.white,
        onSecondary: isDark ? Colors.black : Colors.white,
        onSurface: fontGyColor1,
        onError: Colors.white,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: bgColorPage,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? bgColorContainer : primaryColor,
        foregroundColor: isDark ? fontGyColor1 : Colors.white,
        iconTheme: IconThemeData(
          color: isDark ? fontGyColor1 : Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 2,
        color: bgColorContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bgColorContainer,
        selectedItemColor: primaryColor,
        unselectedItemColor: fontGyColor3,
      ),
      dividerColor: tdTheme.colorMap['grayColor3'] ??
          (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE7E7E7)),
      iconTheme: IconThemeData(
        color: fontGyColor1,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: fontGyColor1),
        bodyMedium: TextStyle(color: fontGyColor1),
        bodySmall: TextStyle(color: fontGyColor3),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: fontGyColor3),
        hintStyle: TextStyle(color: fontGyColor3),
      ),
      extensions: [tdTheme],
    );
  }

  /// 创建浅色主题
  static TDThemeData createLightTheme({
    Color? primary,
    Color? accent,
    Color? background,
    Color? bottomBackground,
  }) {
    return fromAppTheme(
      primary: primary ?? const Color(0xFF0052D9),
      accent: accent ?? const Color(0xFF0052D9),
      background: background ?? const Color(0xFFF5F5F5),
      bottomBackground: bottomBackground ?? const Color(0xFFFFFFFF),
      isDark: false,
    );
  }

  /// 创建深色主题
  static TDThemeData createDarkTheme({
    Color? primary,
    Color? accent,
    Color? background,
    Color? bottomBackground,
  }) {
    return fromAppTheme(
      primary: primary ?? const Color(0xFF4A90D9),  // 深色模式使用更亮的主色
      accent: accent ?? const Color(0xFF4A90D9),
      background: background ?? const Color(0xFF121212),
      bottomBackground: bottomBackground ?? const Color(0xFF1E1E1E),
      isDark: true,
    );
  }

  /// 颜色转换为十六进制字符串
  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  /// 颜色变亮
  static Color _lightenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// 颜色变暗
  static Color _darkenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
