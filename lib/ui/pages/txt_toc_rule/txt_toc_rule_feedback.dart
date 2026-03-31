import 'package:flutter/material.dart';

import '../../widgets/home/home_shell.dart';

enum TxtTocRuleFeedbackType {
  info,
  success,
  error,
  warning,
}

class TxtTocRuleFeedback {
  TxtTocRuleFeedback._();

  static void show(
    BuildContext context,
    String message, {
    TxtTocRuleFeedbackType type = TxtTocRuleFeedbackType.info,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final icon = switch (type) {
      TxtTocRuleFeedbackType.info => Icons.info_outline_rounded,
      TxtTocRuleFeedbackType.success => Icons.check_circle_outline_rounded,
      TxtTocRuleFeedbackType.error => Icons.error_outline_rounded,
      TxtTocRuleFeedbackType.warning => Icons.warning_amber_rounded,
    };

    final accent = switch (type) {
      TxtTocRuleFeedbackType.info => theme.colorScheme.primary,
      TxtTocRuleFeedbackType.success => const Color(0xFF14B8A6),
      TxtTocRuleFeedbackType.error => theme.colorScheme.error,
      TxtTocRuleFeedbackType.warning => const Color(0xFFF59E0B),
    };

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          duration: const Duration(seconds: 2),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: HomePalette.card(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.16)),
              boxShadow: HomePalette.cardShadow(context),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 16, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: HomePalette.primaryText(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
