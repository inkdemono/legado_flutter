import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../theme/eink_td_theme.dart';

/// TDesign 风格的空状态组件
/// 支持 EInk 模式
class TDThemedEmpty extends StatelessWidget {
  /// 描述文本
  final String? description;

  /// 自定义图标
  final IconData? icon;

  /// 自定义图标大小
  final double? iconSize;

  /// 自定义图标颜色
  final Color? iconColor;

  /// 自定义图片
  final String? imageUrl;

  /// 自定义图片
  final Widget? image;

  /// 操作按钮
  final Widget? action;

  /// 类型
  final TDThemedEmptyType type;

  const TDThemedEmpty({
    super.key,
    this.description,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.imageUrl,
    this.image,
    this.action,
    this.type = TDThemedEmptyType.general,
  });

  /// 创建"无数据"空状态
  const TDThemedEmpty.noData({
    super.key,
    this.description = '暂无数据',
    this.action,
  })  : icon = Icons.inbox_outlined,
        iconSize = 64,
        iconColor = null,
        imageUrl = null,
        image = null,
        type = TDThemedEmptyType.noData;

  /// 创建"无搜索结果"空状态
  const TDThemedEmpty.noSearchResult({
    super.key,
    this.description = '未找到相关内容',
    this.action,
  })  : icon = Icons.search_off_outlined,
        iconSize = 64,
        iconColor = null,
        imageUrl = null,
        image = null,
        type = TDThemedEmptyType.noSearchResult;

  /// 创建"无网络"空状态
  const TDThemedEmpty.noNetwork({
    super.key,
    this.description = '网络连接失败，请检查网络',
    this.action,
  })  : icon = Icons.wifi_off_outlined,
        iconSize = 64,
        iconColor = null,
        imageUrl = null,
        image = null,
        type = TDThemedEmptyType.noNetwork;

  /// 创建"加载失败"空状态
  const TDThemedEmpty.loadFailed({
    super.key,
    this.description = '加载失败，请重试',
    this.action,
  })  : icon = Icons.error_outline,
        iconSize = 64,
        iconColor = null,
        imageUrl = null,
        image = null,
        type = TDThemedEmptyType.loadFailed;

  /// 创建"空书架"空状态
  const TDThemedEmpty.emptyBookshelf({
    super.key,
    this.description = '书架空空如也\n快去添加书籍吧',
    this.action,
  })  : icon = Icons.menu_book_outlined,
        iconSize = 64,
        iconColor = null,
        imageUrl = null,
        image = null,
        type = TDThemedEmptyType.emptyBookshelf;

  /// 创建"空列表"空状态
  const TDThemedEmpty.emptyList({
    super.key,
    this.description = '列表为空',
    this.action,
  })  : icon = Icons.list_alt_outlined,
        iconSize = 64,
        iconColor = null,
        imageUrl = null,
        image = null,
        type = TDThemedEmptyType.emptyList;

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    final defaultDescription = _getDefaultDescription();
    final effectiveIcon = icon ?? _getDefaultIcon();
    final effectiveIconColor = iconColor ??
        (isEink ? Colors.black38 : tdTheme.fontGyColor4);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图片或图标
            if (image != null)
              image!
            else if (imageUrl != null)
              Image.network(
                imageUrl!,
                width: 120,
                height: 120,
                errorBuilder: (_, __, ___) => Icon(
                  effectiveIcon,
                  size: iconSize ?? 64,
                  color: effectiveIconColor,
                ),
              )
            else
              Icon(
                effectiveIcon,
                size: iconSize ?? 64,
                color: effectiveIconColor,
              ),
            const SizedBox(height: 16),
            // 描述文本
            Text(
              description ?? defaultDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                height: 1.5,
              ),
            ),
            // 操作按钮
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case TDThemedEmptyType.noData:
        return Icons.inbox_outlined;
      case TDThemedEmptyType.noSearchResult:
        return Icons.search_off_outlined;
      case TDThemedEmptyType.noNetwork:
        return Icons.wifi_off_outlined;
      case TDThemedEmptyType.loadFailed:
        return Icons.error_outline;
      case TDThemedEmptyType.emptyBookshelf:
        return Icons.menu_book_outlined;
      case TDThemedEmptyType.emptyList:
        return Icons.list_alt_outlined;
      case TDThemedEmptyType.general:
        return Icons.hourglass_empty_outlined;
    }
  }

  String _getDefaultDescription() {
    switch (type) {
      case TDThemedEmptyType.noData:
        return '暂无数据';
      case TDThemedEmptyType.noSearchResult:
        return '未找到相关内容';
      case TDThemedEmptyType.noNetwork:
        return '网络连接失败，请检查网络';
      case TDThemedEmptyType.loadFailed:
        return '加载失败，请重试';
      case TDThemedEmptyType.emptyBookshelf:
        return '书架空空如也\n快去添加书籍吧';
      case TDThemedEmptyType.emptyList:
        return '列表为空';
      case TDThemedEmptyType.general:
        return '暂无内容';
    }
  }
}

/// 空状态类型
enum TDThemedEmptyType {
  /// 通用
  general,

  /// 无数据
  noData,

  /// 无搜索结果
  noSearchResult,

  /// 无网络
  noNetwork,

  /// 加载失败
  loadFailed,

  /// 空书架
  emptyBookshelf,

  /// 空列表
  emptyList,
}

/// TDesign 风格的结果页组件
/// 支持 EInk 模式
class TDThemedResult extends StatelessWidget {
  /// 结果类型
  final TDThemedResultType type;

  /// 标题
  final String? title;

  /// 描述
  final String? description;

  /// 自定义图标
  final IconData? icon;

  /// 自定义图标颜色
  final Color? iconColor;

  /// 自定义图标大小
  final double? iconSize;

  /// 主操作按钮
  final Widget? primaryAction;

  /// 次要操作按钮
  final Widget? secondaryAction;

  const TDThemedResult({
    super.key,
    required this.type,
    this.title,
    this.description,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.primaryAction,
    this.secondaryAction,
  });

  /// 创建成功结果页
  const TDThemedResult.success({
    super.key,
    this.title = '操作成功',
    this.description,
    this.primaryAction,
    this.secondaryAction,
  })  : type = TDThemedResultType.success,
        icon = null,
        iconColor = null,
        iconSize = null;

  /// 创建失败结果页
  const TDThemedResult.error({
    super.key,
    this.title = '操作失败',
    this.description,
    this.primaryAction,
    this.secondaryAction,
  })  : type = TDThemedResultType.error,
        icon = null,
        iconColor = null,
        iconSize = null;

  /// 创建警告结果页
  const TDThemedResult.warning({
    super.key,
    this.title = '注意',
    this.description,
    this.primaryAction,
    this.secondaryAction,
  })  : type = TDThemedResultType.warning,
        icon = null,
        iconColor = null,
        iconSize = null;

  /// 创建信息结果页
  const TDThemedResult.info({
    super.key,
    this.title = '提示',
    this.description,
    this.primaryAction,
    this.secondaryAction,
  })  : type = TDThemedResultType.info,
        icon = null,
        iconColor = null,
        iconSize = null;

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    final effectiveIcon = icon ?? _getDefaultIcon();
    final effectiveIconColor = iconColor ?? _getDefaultIconColor(isEink, tdTheme);
    final effectiveTitle = title ?? _getDefaultTitle();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Container(
              width: iconSize ?? 80,
              height: iconSize ?? 80,
              decoration: BoxDecoration(
                color: isEink ? Colors.transparent : effectiveIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: isEink ? Border.all(color: effectiveIconColor, width: 2) : null,
              ),
              child: Icon(
                effectiveIcon,
                size: (iconSize ?? 80) * 0.5,
                color: effectiveIconColor,
              ),
            ),
            const SizedBox(height: 24),
            // 标题
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isEink ? Colors.black : tdTheme.fontGyColor1,
              ),
            ),
            // 描述
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isEink ? Colors.black54 : tdTheme.fontGyColor3,
                  height: 1.5,
                ),
              ),
            ],
            // 操作按钮
            if (primaryAction != null || secondaryAction != null) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (secondaryAction != null) ...[
                    secondaryAction!,
                    const SizedBox(width: 16),
                  ],
                  if (primaryAction != null) primaryAction!,
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case TDThemedResultType.success:
        return Icons.check_circle_outline;
      case TDThemedResultType.error:
        return Icons.cancel_outlined;
      case TDThemedResultType.warning:
        return Icons.warning_amber_outlined;
      case TDThemedResultType.info:
        return Icons.info_outline;
    }
  }

  Color _getDefaultIconColor(bool isEink, TDThemeData tdTheme) {
    if (isEink) return Colors.black;

    switch (type) {
      case TDThemedResultType.success:
        return tdTheme.successNormalColor;
      case TDThemedResultType.error:
        return tdTheme.errorNormalColor;
      case TDThemedResultType.warning:
        return tdTheme.warningNormalColor;
      case TDThemedResultType.info:
        return tdTheme.brandNormalColor;
    }
  }

  String _getDefaultTitle() {
    switch (type) {
      case TDThemedResultType.success:
        return '操作成功';
      case TDThemedResultType.error:
        return '操作失败';
      case TDThemedResultType.warning:
        return '注意';
      case TDThemedResultType.info:
        return '提示';
    }
  }
}

/// 结果类型
enum TDThemedResultType {
  /// 成功
  success,

  /// 失败
  error,

  /// 警告
  warning,

  /// 信息
  info,
}

/// TDesign 风格的通知栏
class TDThemedNoticeBar extends StatelessWidget {
  /// 内容
  final String content;

  /// 前置图标
  final IconData? prefixIcon;

  /// 前置图标颜色
  final Color? prefixIconColor;

  /// 主题
  final TDThemedNoticeBarTheme theme;

  /// 是否可关闭
  final bool closable;

  /// 是否滚动
  final bool marquee;

  /// 点击回调
  final VoidCallback? onTap;

  /// 关闭回调
  final VoidCallback? onClose;

  const TDThemedNoticeBar({
    super.key,
    required this.content,
    this.prefixIcon,
    this.prefixIconColor,
    this.theme = TDThemedNoticeBarTheme.info,
    this.closable = false,
    this.marquee = true,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isEink = EInkTDTheme.isEInkMode;
    final tdTheme = TDTheme.of(context);

    final (bgColor, textColor, iconColor) = _getColors(isEink, tdTheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        border: isEink ? Border.all(color: Colors.black12) : null,
      ),
      child: Row(
        children: [
          // 前置图标
          if (prefixIcon != null || theme != TDThemedNoticeBarTheme.info)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                prefixIcon ?? _getDefaultIcon(),
                size: 18,
                color: prefixIconColor ?? iconColor,
              ),
            ),
          // 内容
          Expanded(
            child: marquee
                ? _MarqueeText(
                    text: content,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  )
                : Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          // 关闭按钮
          if (closable)
            GestureDetector(
              onTap: onClose,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: textColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (theme) {
      case TDThemedNoticeBarTheme.info:
        return Icons.info_outline;
      case TDThemedNoticeBarTheme.success:
        return Icons.check_circle_outline;
      case TDThemedNoticeBarTheme.warning:
        return Icons.warning_amber_outlined;
      case TDThemedNoticeBarTheme.error:
        return Icons.error_outline;
    }
  }

  (Color, Color, Color) _getColors(bool isEink, TDThemeData tdTheme) {
    if (isEink) {
      return (Colors.white, Colors.black87, Colors.black54);
    }

    switch (theme) {
      case TDThemedNoticeBarTheme.info:
        return (
          tdTheme.brandLightColor.withValues(alpha: 0.2),
          tdTheme.brandNormalColor,
          tdTheme.brandNormalColor
        );
      case TDThemedNoticeBarTheme.success:
        return (
          tdTheme.successLightColor.withValues(alpha: 0.2),
          tdTheme.successNormalColor,
          tdTheme.successNormalColor
        );
      case TDThemedNoticeBarTheme.warning:
        return (
          tdTheme.warningLightColor.withValues(alpha: 0.2),
          tdTheme.warningNormalColor,
          tdTheme.warningNormalColor
        );
      case TDThemedNoticeBarTheme.error:
        return (
          tdTheme.errorLightColor.withValues(alpha: 0.2),
          tdTheme.errorNormalColor,
          tdTheme.errorNormalColor
        );
    }
  }
}

/// 通知栏主题
enum TDThemedNoticeBarTheme {
  /// 信息
  info,

  /// 成功
  success,

  /// 警告
  warning,

  /// 错误
  error,
}

/// 滚动文本组件
class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _MarqueeText({
    required this.text,
    required this.style,
  });

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  double _textWidth = 0;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTextWidth();
    });
  }

  void _calculateTextWidth() {
    final RenderBox? renderBox =
        _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _textWidth = renderBox.size.width;
        if (_textWidth > 0) {
          _animation = Tween<Offset>(
            begin: Offset.zero,
            end: Offset(-_textWidth / 200, 0),
          ).animate(CurvedAnimation(
            parent: _controller,
            curve: Curves.linear,
          ));
          _controller.repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: _textWidth > 0
                  ? _animation.value * MediaQuery.of(context).size.width
                  : Offset.zero,
              child: child,
            );
          },
          child: Text(
            widget.text,
            key: _textKey,
            style: widget.style,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
