import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// TDesign 风格的 Toast 工具类
/// 封装 TDToast，提供统一的提示消息接口
class TDThemedToast {
  TDThemedToast._();

  /// 显示普通文本提示
  static void show(BuildContext context, String message) {
    TDToast.showText(message, context: context);
  }

  /// 显示成功提示
  static void showSuccess(BuildContext context, String message) {
    TDToast.showSuccess(message, context: context);
  }

  /// 显示错误提示
  static void showError(BuildContext context, String message) {
    TDToast.showFail(message, context: context);
  }

  /// 显示警告提示
  static void showWarning(BuildContext context, String message) {
    TDToast.showWarning(message, context: context);
  }

  /// 显示加载中提示
  static void showLoading(BuildContext context, {String? message}) {
    TDToast.showLoading(context: context, text: message ?? '加载中...');
  }

  /// 隐藏加载中提示
  static void hideLoading() {
    TDToast.dismissLoading();
  }

  /// 显示自定义图标提示
  static void showCustom({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration? duration,
  }) {
    TDToast.showIconText(
      message,
      context: context,
      icon: icon,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}

/// TDesign 风格的 Loading 指示器组件
class TDThemedLoadingIndicator extends StatelessWidget {
  /// 加载文本
  final String? text;

  /// 是否显示
  final bool isVisible;

  /// 颜色
  final Color? color;

  /// 指示器大小
  final double size;

  /// 线宽
  final double lineWidth;

  const TDThemedLoadingIndicator({
    super.key,
    this.text,
    this.isVisible = true,
    this.color,
    this.size = 24,
    this.lineWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TDCircleIndicator(
          color: color ?? TDTheme.of(context).whiteColor1,
          size: size,
          lineWidth: lineWidth,
        ),
        if (text != null) ...[
          const SizedBox(height: 8),
          Text(
            text!,
            style: TextStyle(
              color: color ?? TDTheme.of(context).whiteColor1,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
