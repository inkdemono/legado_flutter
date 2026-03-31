import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// TDesign 风格的操作面板组件
/// 支持 EInk 模式
class TDThemedActionSheet {
  TDThemedActionSheet._();

  /// 显示操作面板
  static Future<int?> show({
    required BuildContext context,
    String? title,
    String? description,
    required List<String> actions,
    String? cancelText,
    List<bool>? destructiveActions,
    int? selectedIndex,
  }) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 主操作面板
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isEink ? Colors.white : tdTheme.colorMap['bgColorContainer'],
                borderRadius: isEink
                    ? null
                    : BorderRadius.circular(12),
                border: isEink
                    ? Border.all(color: Colors.black12, width: 1)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题
                  if (title != null) _buildTitle(context, title, description, isEink, tdTheme),
                  // 操作项
                  ..._buildActionItems(
                    context: context,
                    actions: actions,
                    destructiveActions: destructiveActions,
                    selectedIndex: selectedIndex,
                    isEink: isEink,
                    tdTheme: tdTheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 取消按钮
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isEink ? Colors.white : tdTheme.colorMap['bgColorContainer'],
                borderRadius: isEink ? null : BorderRadius.circular(12),
                border: isEink
                    ? Border.all(color: Colors.black12, width: 1)
                    : null,
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: isEink ? BorderRadius.zero : BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  cancelText ?? '取消',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isEink ? Colors.black : tdTheme.brandNormalColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 构建标题
  static Widget _buildTitle(
    BuildContext context,
    String title,
    String? description,
    bool isEink,
    TDThemeData tdTheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isEink ? Colors.black12 : tdTheme.grayColor3,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isEink ? Colors.black38 : tdTheme.fontGyColor4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建操作项
  static List<Widget> _buildActionItems({
    required BuildContext context,
    required List<String> actions,
    List<bool>? destructiveActions,
    int? selectedIndex,
    required bool isEink,
    required TDThemeData tdTheme,
  }) {
    return List.generate(actions.length, (index) {
      final isDestructive = destructiveActions?[index] ?? false;
      final isSelected = index == selectedIndex;
      final isLast = index == actions.length - 1;

      return Column(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(index),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      actions[index],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isDestructive
                            ? (isEink ? Colors.black : tdTheme.errorNormalColor)
                            : (isSelected
                                ? (isEink ? Colors.black : tdTheme.brandNormalColor)
                                : (isEink ? Colors.black87 : tdTheme.fontGyColor1)),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check,
                        size: 18,
                        color: isEink ? Colors.black : tdTheme.brandNormalColor,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (!isLast)
            Divider(
              height: 1,
              color: isEink ? Colors.black12 : tdTheme.grayColor3,
            ),
        ],
      );
    });
  }

  /// 显示确认删除操作面板
  static Future<bool?> showDeleteConfirm({
    required BuildContext context,
    String title = '确认删除',
    String? description,
    String deleteText = '删除',
    String cancelText = '取消',
  }) {
    final result = show(
      context: context,
      title: title,
      description: description,
      actions: [deleteText],
      cancelText: cancelText,
      destructiveActions: [true],
    );

    return result.then((value) => value == 0);
  }

  /// 显示分享操作面板
  static Future<int?> showShare({
    required BuildContext context,
    String title = '分享到',
    List<String>? customActions,
  }) {
    final actions = customActions ??
        ['微信', '朋友圈', 'QQ', '微博', '复制链接'];

    return show(
      context: context,
      title: title,
      actions: actions,
      cancelText: '取消',
    );
  }
}

/// TDesign 风格的操作面板 Widget
class TDThemedActionSheetWidget extends StatelessWidget {
  /// 标题
  final String? title;

  /// 描述
  final String? description;

  /// 操作项
  final List<TDThemedActionItem> actions;

  /// 取消按钮文本
  final String? cancelText;

  /// 取消按钮点击回调
  final VoidCallback? onCancel;

  const TDThemedActionSheetWidget({
    super.key,
    this.title,
    this.description,
    required this.actions,
    this.cancelText,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 主操作面板
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isEink ? Colors.white : tdTheme.colorMap['bgColorContainer'],
              borderRadius: isEink ? null : BorderRadius.circular(12),
              border: isEink
                  ? Border.all(color: Colors.black12, width: 1)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Text(
                          title!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isEink ? Colors.black38 : tdTheme.fontGyColor4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ...actions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final action = entry.value;
                  final isLast = index == actions.length - 1;

                  return Column(
                    children: [
                      InkWell(
                        onTap: action.onTap,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              action.label,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: action.isDestructive
                                    ? (isEink ? Colors.black : tdTheme.errorNormalColor)
                                    : (isEink ? Colors.black87 : tdTheme.fontGyColor1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: isEink ? Colors.black12 : tdTheme.grayColor3,
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 取消按钮
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isEink ? Colors.white : tdTheme.colorMap['bgColorContainer'],
              borderRadius: isEink ? null : BorderRadius.circular(12),
              border: isEink
                  ? Border.all(color: Colors.black12, width: 1)
                  : null,
            ),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: isEink ? BorderRadius.zero : BorderRadius.circular(12),
                ),
              ),
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: Text(
                cancelText ?? '取消',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isEink ? Colors.black : tdTheme.brandNormalColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// 操作项数据模型
class TDThemedActionItem {
  /// 标签
  final String label;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否为危险操作（红色文字）
  final bool isDestructive;

  const TDThemedActionItem({
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });
}
