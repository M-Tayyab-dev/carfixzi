import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum StatusBadgeVariant {
  success,
  warning,
  error,
  info,
  neutral,
  accent,
}

/// Pill-shaped status badge for booking status, verification status, and badges
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeVariant variant;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.info,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (variant) {
      case StatusBadgeVariant.success:
        bgColor = AppColors.successContainer;
        textColor = AppColors.success;
        break;
      case StatusBadgeVariant.warning:
        bgColor = AppColors.warningContainer;
        textColor = AppColors.warning;
        break;
      case StatusBadgeVariant.error:
        bgColor = AppColors.errorContainer;
        textColor = AppColors.error;
        break;
      case StatusBadgeVariant.info:
        bgColor = AppColors.surfaceContainerHigh;
        textColor = AppColors.primaryContainer;
        break;
      case StatusBadgeVariant.neutral:
        bgColor = AppColors.surfaceDim;
        textColor = AppColors.onSurfaceVariant;
        break;
      case StatusBadgeVariant.accent:
        bgColor = AppColors.tertiaryFixed;
        textColor = AppColors.onTertiaryFixed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999), // full pill
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
