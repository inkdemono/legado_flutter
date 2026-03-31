import 'package:flutter/material.dart';
import '../td/td_widgets.dart';

/// 自定义开关组件
/// 现在是 TDThemedSwitch 的别名，保持向后兼容
/// 参考项目：使用统一的开关样式，橙色激活状态，灰色未激活状态
class CustomSwitch extends StatelessWidget {
  /// 开关的值
  final bool value;

  /// 值改变时的回调
  final ValueChanged<bool>? onChanged;

  /// 激活时的颜色（默认橙色）
  final Color? activeColor;

  /// 未激活时的颜色（默认灰色）
  final Color? inactiveColor;

  /// 是否禁用
  final bool isDisabled;

  const CustomSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.isDisabled = false,
    // 以下参数保留用于向后兼容，但不再使用
    double width = 40,
    double height = 20,
    double thumbSize = 20,
    Duration duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return TDThemedSwitch(
      value: value,
      onChanged: onChanged,
      isDisabled: isDisabled,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
    );
  }
}

