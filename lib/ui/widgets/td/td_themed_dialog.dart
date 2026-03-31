import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// TDesign 风格的对话框组件
/// 封装 TDDialog，支持 EInk 模式
class TDThemedDialog {
  TDThemedDialog._();

  /// 显示确认对话框
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    String? content,
    String confirmText = '确定',
    String cancelText = '取消',
    bool isDangerous = false,
    bool barrierDismissible = true,
  }) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    if (isEink) {
      return _showEInkConfirmDialog(
        context: context,
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous,
        barrierDismissible: barrierDismissible,
      );
    }

    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        backgroundColor: tdTheme.colorMap['bgColorContainer'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: tdTheme.fontGyColor1,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: content != null
            ? Text(
                content,
                style: TextStyle(
                  color: tdTheme.fontGyColor2,
                  fontSize: 14,
                ),
              )
            : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: tdTheme.fontGyColor3,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDangerous
                    ? tdTheme.errorNormalColor
                    : tdTheme.brandNormalColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// EInk 模式确认对话框
  static Future<bool?> _showEInkConfirmDialog({
    required BuildContext context,
    required String title,
    String? content,
    required String confirmText,
    required String cancelText,
    required bool isDangerous,
    required bool barrierDismissible,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(color: Colors.black12, width: 1),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: content != null
            ? Text(
                content,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              )
            : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              '取消',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDangerous ? Colors.black : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示自定义内容对话框
  static Future<T?> showCustom<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  /// 显示输入对话框
  static Future<String?> showInput({
    required BuildContext context,
    required String title,
    String? hintText,
    String? initialValue,
    String confirmText = '确定',
    String cancelText = '取消',
  }) {
    final controller = TextEditingController(text: initialValue);
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isEink
            ? Colors.white
            : tdTheme.colorMap['bgColorContainer'],
        shape: RoundedRectangleBorder(
          borderRadius: isEink ? BorderRadius.zero : BorderRadius.circular(12),
          side: isEink
              ? const BorderSide(color: Colors.black12, width: 1)
              : BorderSide.none,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isEink ? Colors.black : tdTheme.fontGyColor1,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.dispose();
            },
            child: Text(
              cancelText,
              style: TextStyle(
                color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text;
              Navigator.of(context).pop(value);
              controller.dispose();
            },
            child: Text(
              confirmText,
              style: TextStyle(
                color: isEink ? Colors.black : tdTheme.brandNormalColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// TDesign 风格的对话框 Widget
class TDThemedDialogWidget extends StatelessWidget {
  /// 标题
  final String? title;

  /// 内容
  final Widget? content;

  /// 操作按钮
  final List<Widget>? actions;

  /// 背景色
  final Color? backgroundColor;

  /// 内容内边距
  final EdgeInsets? contentPadding;

  /// 标题样式
  final TextStyle? titleStyle;

  const TDThemedDialogWidget({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.backgroundColor,
    this.contentPadding,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return AlertDialog(
      backgroundColor: backgroundColor ??
          (isEink ? Colors.white : tdTheme.colorMap['bgColorContainer']),
      shape: RoundedRectangleBorder(
        borderRadius: isEink ? BorderRadius.zero : BorderRadius.circular(12),
        side: isEink
            ? const BorderSide(color: Colors.black12, width: 1)
            : BorderSide.none,
      ),
      title: title != null
          ? Text(
              title!,
              style: titleStyle ??
                  TextStyle(
                    color: isEink ? Colors.black : tdTheme.fontGyColor1,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
            )
          : null,
      content: content,
      contentPadding: contentPadding ??
          const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actions: actions,
    );
  }
}
