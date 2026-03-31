import 'dart:ui';

import 'package:flutter/material.dart';

class HomePalette {
  static const Color accent = Color(0xFF1677FF);
  static const Color accentStrong = Color(0xFF0F62FE);
  static const Color accentSoft = Color(0x1A1677FF);
  static const Color textPrimary = Color(0xFF1F2329);
  static const Color textSecondary = Color(0xFF4E5969);
  static const Color textTertiary = Color(0xFF86909C);
  static const Color surface = Color(0xFFFDFDFE);
  static const Color surfaceSoft = Color(0xFFF7F8FA);
  static const Color line = Color(0xFFE5E6EB);

  static Color background(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF0F1720)
        : const Color(0xFFF7F8FA);
  }

  static Color card(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF18212C)
        : Colors.white.withValues(alpha: 0.94);
  }

  static Color mutedCard(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF121A23)
        : const Color(0xFFF8FAFC);
  }

  static Color lineColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : line.withValues(alpha: 0.92);
  }

  static Color primaryText(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : textPrimary;
  }

  static Color secondaryText(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.72)
        : textSecondary;
  }

  static Color tertiaryText(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.48)
        : textTertiary;
  }

  static List<BoxShadow> cardShadow(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return const [];
    }
    return [
      BoxShadow(
        color: const Color(0xFF0F1720).withValues(alpha: 0.06),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ];
  }
}

class HomePageBackground extends StatelessWidget {
  final Widget child;
  final List<Color> glowColors;

  const HomePageBackground({
    super.key,
    required this.child,
    required this.glowColors,
  });

  @override
  Widget build(BuildContext context) {
    final background = HomePalette.background(context);

    return Container(
      color: background,
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -40,
            child: _GlowBubble(
              color: glowColors.first.withValues(alpha: 0.18),
              size: 260,
            ),
          ),
          Positioned(
            top: 40,
            right: -70,
            child: _GlowBubble(
              color: glowColors.last.withValues(alpha: 0.14),
              size: 220,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBubble({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class HomeSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final VoidCallback? onTap;

  const HomeSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);

    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? HomePalette.card(context),
        borderRadius: radius,
        border: Border.all(color: HomePalette.lineColor(context)),
        boxShadow: HomePalette.cardShadow(context),
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class HomeSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const HomeSearchField({
    super.key,
    this.controller,
    this.hintText = '搜索',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: HomePalette.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HomePalette.lineColor(context)),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        style: TextStyle(
          color: HomePalette.primaryText(context),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: HomePalette.tertiaryText(context)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: HomePalette.tertiaryText(context),
          ),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller!.clear();
                    onChanged?.call('');
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: HomePalette.tertiaryText(context),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

class HomeTabItem {
  final String label;
  final IconData icon;

  const HomeTabItem({
    required this.label,
    required this.icon,
  });
}

class HomePillTabBar extends StatelessWidget {
  final TabController controller;
  final List<HomeTabItem> items;

  const HomePillTabBar({
    super.key,
    required this.controller,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: HomePalette.card(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HomePalette.lineColor(context)),
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = controller.index == index;

              return Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: index == items.length - 1 ? 0 : 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => controller.animateTo(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? HomePalette.accentSoft
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: 18,
                            color: selected
                                ? HomePalette.accentStrong
                                : HomePalette.tertiaryText(context),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w600,
                              color: selected
                                  ? HomePalette.accentStrong
                                  : HomePalette.secondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class HomeSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const HomeSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: HomePalette.primaryText(context),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: HomePalette.tertiaryText(context),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
