import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// TDesign 风格的加载状态组件
/// 支持 EInk 模式
class TDThemedLoading extends StatelessWidget {
  /// 加载提示文本
  final String? text;

  /// 加载指示器大小
  final double size;

  /// 颜色
  final Color? color;

  /// 是否显示背景
  final bool showBackground;

  /// 背景色
  final Color? backgroundColor;

  /// 内边距
  final EdgeInsets? padding;

  /// 是否水平排列
  final bool horizontal;

  /// 自定义加载指示器
  final Widget? customIndicator;

  const TDThemedLoading({
    super.key,
    this.text,
    this.size = 40,
    this.color,
    this.showBackground = true,
    this.backgroundColor,
    this.padding,
    this.horizontal = false,
    this.customIndicator,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    final indicatorColor = color ?? (isEink ? Colors.black : tdTheme.brandNormalColor);

    Widget indicator = customIndicator ??
        SizedBox(
          width: size,
          height: size,
          child: isEink
              ? _buildEInkIndicator(indicatorColor)
              : TDLoading(
                  size: TDLoadingSize.medium,
                  icon: TDLoadingIcon.circle,
                  iconColor: indicatorColor,
                ),
        );

    if (text != null) {
      if (horizontal) {
        return Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: showBackground
              ? BoxDecoration(
                  color: backgroundColor ??
                      (isEink ? Colors.white : tdTheme.colorMap['bgColorContainer']),
                  borderRadius: isEink ? null : BorderRadius.circular(8),
                  border: isEink ? Border.all(color: Colors.black12) : null,
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              indicator,
              const SizedBox(width: 12),
              Text(
                text!,
                style: TextStyle(
                  fontSize: 14,
                  color: isEink ? Colors.black87 : tdTheme.fontGyColor2,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: padding ?? const EdgeInsets.all(24),
        decoration: showBackground
            ? BoxDecoration(
                color: backgroundColor ??
                    (isEink ? Colors.white : tdTheme.colorMap['bgColorContainer']),
                borderRadius: isEink ? null : BorderRadius.circular(8),
                border: isEink ? Border.all(color: Colors.black12) : null,
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            const SizedBox(height: 12),
            Text(
              text!,
              style: TextStyle(
                fontSize: 14,
                color: isEink ? Colors.black87 : tdTheme.fontGyColor2,
              ),
            ),
          ],
        ),
      );
    }

    return indicator;
  }

  /// EInk 模式下的加载指示器（使用旋转方块）
  Widget _buildEInkIndicator(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: _EInkLoadingPainter(
            progress: value,
            color: color,
          ),
        );
      },
    );
  }
}

/// EInk 加载指示器绘制器
class _EInkLoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _EInkLoadingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(
      rect,
      0,
      progress * 2 * 3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _EInkLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// TDesign 风格的加载覆盖层
class TDThemedLoadingOverlay extends StatelessWidget {
  /// 是否显示
  final bool isLoading;

  /// 加载提示文本
  final String? text;

  /// 子组件
  final Widget child;

  /// 背景色
  final Color? barrierColor;

  /// 加载指示器大小
  final double indicatorSize;

  const TDThemedLoadingOverlay({
    super.key,
    required this.isLoading,
    this.text,
    required this.child,
    this.barrierColor,
    this.indicatorSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: barrierColor ?? Colors.black26,
              child: Center(
                child: TDThemedLoading(
                  text: text,
                  size: indicatorSize,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// TDesign 风格的刷新指示器
class TDThemedRefreshIndicator extends StatelessWidget {
  /// 下拉刷新回调
  final Future<void> Function() onRefresh;

  /// 子组件
  final Widget child;

  /// 颜色
  final Color? color;

  /// 背景色
  final Color? backgroundColor;

  const TDThemedRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? (isEink ? Colors.black : tdTheme.brandNormalColor),
      backgroundColor: backgroundColor ??
          (isEink ? Colors.white : tdTheme.colorMap['bgColorContainer']),
      child: child,
    );
  }
}

/// TDesign 风格的骨架屏
class TDThemedSkeleton extends StatelessWidget {
  /// 行数
  final int rows;

  /// 行高
  final double rowHeight;

  /// 行间距
  final double rowSpacing;

  /// 是否显示头像
  final bool showAvatar;

  /// 头像大小
  final double avatarSize;

  /// 是否显示标题
  final bool showTitle;

  /// 标题宽度比例
  final double titleWidthRatio;

  /// 动画效果
  final bool animation;

  const TDThemedSkeleton({
    super.key,
    this.rows = 3,
    this.rowHeight = 16,
    this.rowSpacing = 12,
    this.showAvatar = false,
    this.avatarSize = 48,
    this.showTitle = true,
    this.titleWidthRatio = 0.4,
    this.animation = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    final baseColor = isEink ? Colors.grey.shade300 : tdTheme.grayColor3;

    Widget buildShimmerBox(double width, double height) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: isEink ? null : BorderRadius.circular(4),
        ),
      );
    }

    Widget shimmerBox = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAvatar || showTitle)
                Row(
                  children: [
                    if (showAvatar)
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: baseColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (showTitle)
                      Expanded(
                        child: buildShimmerBox(double.infinity * titleWidthRatio, rowHeight),
                      ),
                  ],
                ),
              if (showAvatar || showTitle) SizedBox(height: rowSpacing),
              ...List.generate(rows, (index) {
                final isLast = index == rows - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : rowSpacing),
                  child: buildShimmerBox(
                    isLast ? double.infinity * 0.6 : double.infinity,
                    rowHeight,
                  ),
                );
              }),
            ],
          );

    return shimmerBox;
  }
}

/// TDesign 风格的进度指示器
class TDThemedProgress extends StatelessWidget {
  /// 当前进度 (0-100)
  final double progress;

  /// 进度条类型
  final TDThemedProgressType type;

  /// 颜色
  final Color? color;

  /// 背景色
  final Color? backgroundColor;

  /// 高度（仅线性进度条）
  final double? height;

  /// 大小（仅圆形进度条）
  final double? size;

  /// 线宽（仅圆形进度条）
  final double? strokeWidth;

  /// 是否显示百分比
  final bool showPercentage;

  /// 标签
  final String? label;

  const TDThemedProgress({
    super.key,
    required this.progress,
    this.type = TDThemedProgressType.linear,
    this.color,
    this.backgroundColor,
    this.height,
    this.size,
    this.strokeWidth,
    this.showPercentage = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    final progressColor = color ?? (isEink ? Colors.black : tdTheme.brandNormalColor);
    final bgColor = backgroundColor ?? (isEink ? Colors.grey.shade300 : tdTheme.grayColor3);

    switch (type) {
      case TDThemedProgressType.linear:
        return _buildLinearProgress(isEink, tdTheme, progressColor, bgColor);
      case TDThemedProgressType.circular:
        return _buildCircularProgress(isEink, progressColor, bgColor);
    }
  }

  Widget _buildLinearProgress(
    bool isEink,
    TDThemeData tdTheme,
    Color progressColor,
    Color bgColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              color: isEink ? Colors.black87 : tdTheme.fontGyColor2,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: Container(
                height: height ?? 8,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: isEink ? null : BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (progress.clamp(0, 100)) / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: isEink ? null : BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            if (showPercentage) ...[
              const SizedBox(width: 8),
              Text(
                '${progress.round()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCircularProgress(
    bool isEink,
    Color progressColor,
    Color bgColor,
  ) {
    final effectiveSize = size ?? 40;
    final effectiveStrokeWidth = strokeWidth ?? 4;

    return SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: effectiveSize,
            height: effectiveSize,
            child: CircularProgressIndicator(
              value: progress / 100,
              strokeWidth: effectiveStrokeWidth,
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation(progressColor),
              strokeCap: isEink ? StrokeCap.butt : StrokeCap.round,
            ),
          ),
          if (showPercentage)
            Text(
              '${progress.round()}%',
              style: TextStyle(
                fontSize: effectiveSize / 4,
                fontWeight: FontWeight.w500,
                color: isEink ? Colors.black : progressColor,
              ),
            ),
        ],
      ),
    );
  }
}

/// 进度条类型
enum TDThemedProgressType {
  /// 线性进度条
  linear,

  /// 圆形进度条
  circular,
}
