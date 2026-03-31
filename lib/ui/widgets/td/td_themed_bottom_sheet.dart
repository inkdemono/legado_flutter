import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// TDesign 风格的底部弹窗组件
/// 支持 EInk 模式
class TDThemedBottomSheet {
  TDThemedBottomSheet._();

  /// 显示底部弹窗
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext context) builder,
    String? title,
    double? heightFactor,
    bool showDragHandle = true,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    Color? backgroundColor,
    VoidCallback? onClose,
  }) {
    final isEink = EInkTDTheme.isEInkMode;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: heightFactor != null
            ? MediaQuery.of(context).size.height * heightFactor
            : MediaQuery.of(context).size.height * 0.9,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: isEink
            ? BorderRadius.zero
            : const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
      ),
      builder: (context) {
        return _TDThemedBottomSheetContent(
          title: title,
          showDragHandle: showDragHandle,
          isEink: isEink,
          onClose: onClose,
          child: builder(context),
        );
      },
    );
  }

  /// 显示固定高度的底部弹窗
  static Future<T?> showFixed<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double height = 300,
    bool showDragHandle = true,
    bool isDismissible = true,
    Color? backgroundColor,
  }) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor ??
          (isEink ? Colors.white : tdTheme.colorMap['bgColorContainer']),
      shape: RoundedRectangleBorder(
        borderRadius: isEink
            ? BorderRadius.zero
            : const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
      ),
      builder: (context) => Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle && !isEink) ...[
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tdTheme.grayColor5,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (title != null) ...[
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isEink ? Colors.black : tdTheme.fontGyColor1,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  /// 显示列表选择底部弹窗
  static Future<int?> showSelection<T>({
    required BuildContext context,
    String? title,
    required List<String> items,
    int? selectedIndex,
    String? cancelText,
  }) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isEink ? Colors.white : tdTheme.colorMap['bgColorContainer'],
      shape: RoundedRectangleBorder(
        borderRadius: isEink
            ? BorderRadius.zero
            : const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isEink ? Colors.black : tdTheme.fontGyColor1,
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: isEink ? Colors.black12 : tdTheme.grayColor3,
              ),
            ],
            ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isEink ? Colors.black12 : tdTheme.grayColor3,
              ),
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return ListTile(
                  title: Text(
                    items[index],
                    style: TextStyle(
                      color: isEink
                          ? (isSelected ? Colors.black : Colors.black54)
                          : (isSelected
                              ? tdTheme.brandNormalColor
                              : tdTheme.fontGyColor1),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: isEink ? Colors.black : tdTheme.brandNormalColor,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(index),
                );
              },
            ),
            if (cancelText != null) ...[
              Divider(
                height: 1,
                color: isEink ? Colors.black12 : tdTheme.grayColor3,
              ),
              ListTile(
                title: Text(
                  cancelText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 底部弹窗内容组件
class _TDThemedBottomSheetContent extends StatelessWidget {
  final String? title;
  final bool showDragHandle;
  final bool isEink;
  final Widget child;
  final VoidCallback? onClose;

  const _TDThemedBottomSheetContent({
    required this.title,
    required this.showDragHandle,
    required this.isEink,
    required this.child,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final tdTheme = TDTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isEink ? Colors.white : tdTheme.colorMap['bgColorContainer'],
        borderRadius: isEink
            ? null
            : const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
        border: isEink
            ? Border.all(color: Colors.black12, width: 1)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽手柄
          if (showDragHandle && !isEink) ...[
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: tdTheme.grayColor5,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // 标题栏
          if (title != null) ...[
            _buildTitleBar(context, tdTheme),
          ],
          // 内容区域
          Flexible(child: child),
        ],
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context, TDThemeData tdTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isEink ? Colors.black12 : tdTheme.grayColor3,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title ?? '',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isEink ? Colors.black : tdTheme.fontGyColor1,
              ),
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: Icon(
                Icons.close,
                color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
              ),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}

/// TDesign 风格的底部弹窗 Widget
class TDThemedBottomSheetWidget extends StatelessWidget {
  /// 标题
  final String? title;

  /// 子组件
  final Widget child;

  /// 是否显示拖拽手柄
  final bool showDragHandle;

  /// 内边距
  final EdgeInsets? padding;

  /// 关闭回调
  final VoidCallback? onClose;

  const TDThemedBottomSheetWidget({
    super.key,
    this.title,
    required this.child,
    this.showDragHandle = true,
    this.padding,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isEink ? Colors.white : tdTheme.colorMap['bgColorContainer'],
        borderRadius: isEink
            ? null
            : const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle && !isEink) ...[
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: tdTheme.grayColor5,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (title != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isEink ? Colors.black12 : tdTheme.grayColor3,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isEink ? Colors.black : tdTheme.fontGyColor1,
                      ),
                    ),
                  ),
                  if (onClose != null)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                      ),
                      onPressed: onClose,
                    ),
                ],
              ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
