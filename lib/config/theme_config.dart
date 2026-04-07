import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'app_config.dart';
import '../ui/theme/td_theme_adapter.dart';
import '../ui/theme/eink_td_theme.dart';

/// 主题模式 Provider
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final mode = AppConfig.getString('theme_mode', defaultValue: 'system');
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setMode(ThemeMode mode) {
    AppConfig.setString('theme_mode', mode.name);
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// 设置主题模式
void setThemeMode(WidgetRef ref, ThemeMode mode) {
  ref.read(themeModeProvider.notifier).setMode(mode);
}

/// 是否启用 EInk 模式 Provider
class EinkModeNotifier extends Notifier<bool> {
  @override
  bool build() => AppConfig.getBool('eink_mode', defaultValue: false);

  void setEnabled(bool enabled) {
    AppConfig.setBool('eink_mode', enabled);
    state = enabled;
  }
}

final einkModeProvider = NotifierProvider<EinkModeNotifier, bool>(
  EinkModeNotifier.new,
);

final themeRevisionProvider = NotifierProvider<ThemeRevisionNotifier, int>(
  ThemeRevisionNotifier.new,
);

class ThemeRevisionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

/// 设置 EInk 模式
void setEinkMode(WidgetRef ref, bool enabled) {
  ref.read(einkModeProvider.notifier).setEnabled(enabled);
}

/// TDesign 主题 Provider
final tdThemeProvider = Provider<TDThemeData>((ref) {
  ref.watch(themeRevisionProvider);
  final isEink = ref.watch(einkModeProvider);

  // EInk 模式使用专用主题
  if (isEink) {
    return EInkTDTheme.getEInkTheme();
  }

  // 从配置读取自定义颜色
  final primary = Color(AppConfig.getInt('c_primary', defaultValue: 0xFF0052D9));
  final accent = Color(AppConfig.getInt('c_accent', defaultValue: 0xFF0052D9));
  final background = Color(AppConfig.getInt('c_background', defaultValue: 0xFFF5F5F5));
  final bottomBackground = Color(AppConfig.getInt('c_b_background', defaultValue: 0xFFFFFFFF));

  // 创建浅色主题
  return TDesignThemeAdapter.createLightTheme(
    primary: primary,
    accent: accent,
    background: background,
    bottomBackground: bottomBackground,
  );
});

/// TDesign 深色主题 Provider
final tdDarkThemeProvider = Provider<TDThemeData>((ref) {
  ref.watch(themeRevisionProvider);
  final isEink = ref.watch(einkModeProvider);

  // EInk 模式使用专用主题
  if (isEink) {
    return EInkTDTheme.getEInkTheme();
  }

  // 从配置读取自定义颜色（深色模式使用更亮的默认值）
  final primary = Color(AppConfig.getInt('c_n_primary', defaultValue: 0xFF4A90D9));
  final accent = Color(AppConfig.getInt('c_n_accent', defaultValue: 0xFF4A90D9));
  final background = Color(AppConfig.getInt('c_n_background', defaultValue: 0xFF121212));
  final bottomBackground = Color(AppConfig.getInt('c_n_b_background', defaultValue: 0xFF1E1E1E));

  // 创建深色主题
  return TDesignThemeAdapter.createDarkTheme(
    primary: primary,
    accent: accent,
    background: background,
    bottomBackground: bottomBackground,
  );
});

/// 应用主题 Provider
final appThemeProvider = Provider<AppTheme>((ref) {
  ref.watch(themeRevisionProvider);
  final tdTheme = ref.watch(tdThemeProvider);
  final tdDarkTheme = ref.watch(tdDarkThemeProvider);
  final isEink = ref.watch(einkModeProvider);
  return AppTheme(tdTheme: tdTheme, tdDarkTheme: tdDarkTheme, isEink: isEink);
});

class AppTheme {
  final TDThemeData tdTheme;
  final TDThemeData tdDarkTheme;
  final bool isEink;

  AppTheme({
    required this.tdTheme,
    required this.tdDarkTheme,
    this.isEink = false,
  });

  ThemeData get lightTheme {
    // EInk 模式使用专用主题
    if (isEink) {
      return EInkTDTheme.toEInkFlutterTheme(EInkTDTheme.getEInkTheme());
    }

    // 使用 TDesign 主题适配器生成 ThemeData
    return TDesignThemeAdapter.toFlutterTheme(tdTheme, isDark: false);
  }

  ThemeData get darkTheme {
    // EInk 模式使用专用主题
    if (isEink) {
      return EInkTDTheme.toEInkFlutterTheme(EInkTDTheme.getEInkTheme());
    }

    // 使用 TDesign 主题适配器生成 ThemeData
    return TDesignThemeAdapter.toFlutterTheme(tdDarkTheme, isDark: true);
  }

  /// 获取当前 TDesign 主题
  TDThemeData get currentTDTheme => tdTheme;

  /// 获取深色 TDesign 主题
  TDThemeData get darkTDTheme => tdDarkTheme;

  static Future<void> init() async {
    // 初始化主题配置
  }
}
