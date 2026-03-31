/// Flexbox 子元素样式
/// 参考项目：FlexChildStyle.kt
class FlexChildStyle {
  /// 弹性增长比例
  /// 0=不增长, 1=平分剩余空间
  final double flexGrow;

  /// 弹性收缩比例
  final double flexShrink;

  /// 自身对齐方式
  /// auto: 自动, flex_start: 起始对齐, flex_end: 结束对齐, center: 居中, baseline: 基线, stretch: 拉伸
  final String alignSelf;

  /// 初始大小百分比
  /// -1: 不设置, 0.5: 占父容器的50%
  final double flexBasisPercent;

  /// 是否在此元素前强制换行
  final bool wrapBefore;

  const FlexChildStyle({
    this.flexGrow = 0,
    this.flexShrink = 1,
    this.alignSelf = 'auto',
    this.flexBasisPercent = -1,
    this.wrapBefore = false,
  });

  factory FlexChildStyle.fromJson(Map<String, dynamic> json) {
    return FlexChildStyle(
      flexGrow: (json['layout_flexGrow'] as num?)?.toDouble() ?? 0,
      flexShrink: (json['layout_flexShrink'] as num?)?.toDouble() ?? 1,
      alignSelf: json['layout_alignSelf'] as String? ?? 'auto',
      flexBasisPercent: (json['layout_flexBasisPercent'] as num?)?.toDouble() ?? -1,
      wrapBefore: json['layout_wrapBefore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layout_flexGrow': flexGrow,
      'layout_flexShrink': flexShrink,
      'layout_alignSelf': alignSelf,
      'layout_flexBasisPercent': flexBasisPercent,
      'layout_wrapBefore': wrapBefore,
    };
  }

  /// 默认样式
  static const FlexChildStyle defaultStyle = FlexChildStyle();

  /// 是否占整行（flexBasisPercent >= 1 或 wrapBefore 为 true）
  bool get isFullWidth {
    if (wrapBefore) return true;
    if (flexBasisPercent >= 1) return true;
    return false;
  }

  /// 获取弹性基准百分比（用于 Flutter 的 Expanded 组件）
  /// 返回 null 表示不使用 Expanded
  double? get flexBasisFraction {
    if (flexBasisPercent < 0) return null;
    if (flexBasisPercent > 1) return 1.0;
    return flexBasisPercent;
  }
}
