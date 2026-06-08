import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/md3_theme.dart';

/// 毛玻璃效果底部导航栏 - 灵感来自 legado-with-MD3
class GlassBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final double blur;
  final Color? backgroundColor;

  const GlassBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.blur = 30.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final defaultBgColor = brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.8);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? defaultBgColor,
            border: Border(
              top: BorderSide(
                color: brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final isSelected = index == currentIndex;
                  final item = items[index];

                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onTap(index),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MD3Palette.primaryContainer(context)
                                    .withValues(alpha: 0.5)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconTheme(
                                data: IconThemeData(
                                  size: 24,
                                  color: isSelected
                                      ? MD3Palette.primary(context)
                                      : MD3Palette.onSurfaceVariant(context),
                                ),
                                child: isSelected && item.activeIcon != null
                                    ? item.activeIcon!
                                    : item.icon!,
                              ),
                              if (item.label != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.label!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? MD3Palette.primary(context)
                                        : MD3Palette.onSurfaceVariant(context),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 悬浮操作按钮容器 - 带阴影和动画
class FabContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const FabContainer({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 4,
  });

  @override
  State<FabContainer> createState() => _FabContainerState();
}

class _FabContainerState extends State<FabContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? MD3Palette.primaryContainer(context),
            shape: BoxShape.circle,
            boxShadow: MD3Palette.elevationOverlay(context, elevation: widget.elevation),
          ),
          padding: const EdgeInsets.all(16),
          child: IconTheme(
            data: IconThemeData(
              color: widget.foregroundColor ?? MD3Palette.onPrimaryContainer(context),
              size: 24,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// 现代化列表项
class MD3ListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const MD3ListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: enabled
              ? MD3Palette.onSurface(context)
              : MD3Palette.onSurfaceVariant(context).withValues(alpha: 0.5),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: MD3Palette.onSurfaceVariant(context),
              ),
            )
          : null,
      leading: leading,
      trailing: trailing,
      enabled: enabled,
    );

    if (onTap == null) {
      return tile;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: tile,
        ),
      ),
    );
  }
}

/// 分组标题
class MD3SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const MD3SectionHeader({
    super.key,
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: MD3Palette.primary(context),
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// 空状态页面
class MD3EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const MD3EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: MD3Palette.surfaceVariant(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: MD3Palette.onSurfaceVariant(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: MD3Palette.onSurface(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: MD3Palette.onSurfaceVariant(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// 加载指示器
class MD3LoadingIndicator extends StatelessWidget {
  final String? message;

  const MD3LoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: MD3Palette.primary(context),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: MD3Palette.onSurfaceVariant(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
