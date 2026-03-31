import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// TDesign 风格的滑块组件
/// 封装 Flutter Slider，支持 EInk 模式
class TDThemedSlider extends StatelessWidget {
  /// 当前值
  final double value;

  /// 值变化回调
  final ValueChanged<double>? onChanged;

  /// 值变化开始回调
  final ValueChanged<double>? onChangeStart;

  /// 值变化结束回调
  final ValueChanged<double>? onChangeEnd;

  /// 最小值
  final double min;

  /// 最大值
  final double max;

  /// 分割数（用于离散滑块）
  final int? divisions;

  /// 是否禁用
  final bool isDisabled;

  /// 激活颜色
  final Color? activeColor;

  /// 非激活颜色
  final Color? inactiveColor;

  /// 左侧标签
  final String? leftLabel;

  /// 右侧标签
  final String? rightLabel;

  const TDThemedSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.isDisabled = false,
    this.activeColor,
    this.inactiveColor,
    this.leftLabel,
    this.rightLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    final active = activeColor ?? tdTheme.brandNormalColor;
    final inactive = inactiveColor ?? tdTheme.grayColor4;

    return Row(
      children: [
        if (leftLabel != null) ...[
          Text(leftLabel!, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              activeTrackColor: active,
              inactiveTrackColor: isEink ? Colors.black26 : inactive,
              thumbColor: isEink ? Colors.black : active,
              overlayColor: active.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: isDisabled ? null : onChanged,
              onChangeStart: onChangeStart,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ),
        if (rightLabel != null) ...[
          const SizedBox(width: 8),
          Text(rightLabel!, style: const TextStyle(fontSize: 16)),
        ],
      ],
    );
  }
}

/// TDesign 风格的范围滑块组件
class TDThemedRangeSlider extends StatelessWidget {
  /// 当前值
  final RangeValues values;

  /// 值变化回调
  final ValueChanged<RangeValues>? onChanged;

  /// 值变化结束回调
  final ValueChanged<RangeValues>? onChangeEnd;

  /// 最小值
  final double min;

  /// 最大值
  final double max;

  /// 分割数
  final int? divisions;

  /// 是否禁用
  final bool isDisabled;

  /// 激活颜色
  final Color? activeColor;

  /// 非激活颜色
  final Color? inactiveColor;

  const TDThemedRangeSlider({
    super.key,
    required this.values,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.isDisabled = false,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return RangeSlider(
      values: values,
      min: min,
      max: max,
      divisions: divisions,
      onChanged: isDisabled ? null : onChanged,
      onChangeEnd: onChangeEnd,
      activeColor: activeColor ?? (isEink ? Colors.black : tdTheme.brandNormalColor),
      inactiveColor: inactiveColor ?? (isEink ? Colors.black26 : tdTheme.grayColor4),
    );
  }
}

/// TDesign 风格的滑块列表项组件
class TDThemedSliderListTile extends StatelessWidget {
  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 当前值
  final double value;

  /// 值变化回调
  final ValueChanged<double>? onChanged;

  /// 值变化结束回调
  final ValueChanged<double>? onChangeEnd;

  /// 最小值
  final double min;

  /// 最大值
  final double max;

  /// 分割数
  final int? divisions;

  /// 是否禁用
  final bool isDisabled;

  /// 值格式化显示
  final String Function(double)? valueFormatter;

  /// 左侧图标
  final IconData? leadingIcon;

  const TDThemedSliderListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.isDisabled = false,
    this.valueFormatter,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEink
            ? Colors.white
            : tdTheme.colorMap['bgColorContainer'] ?? tdTheme.grayColor1,
        border: Border(
          bottom: BorderSide(
            color: isEink ? Colors.black12 : tdTheme.grayColor3,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leadingIcon != null) ...[
                Icon(
                  leadingIcon,
                  size: 20,
                  color: isEink ? Colors.black : tdTheme.fontGyColor1,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isEink ? Colors.black : tdTheme.fontGyColor1,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                valueFormatter?.call(value) ?? value.toStringAsFixed(1),
                style: TextStyle(
                  color: isEink ? Colors.black54 : tdTheme.fontGyColor2,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: isEink ? Colors.black38 : tdTheme.fontGyColor3,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          TDThemedSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
            isDisabled: isDisabled,
          ),
        ],
      ),
    );
  }
}
