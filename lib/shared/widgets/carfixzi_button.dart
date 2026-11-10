import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum ButtonVariant { primary, secondary, ghost, danger }

/// Reusable Button Component following CARFIXZI Design Tokens:
/// - Primary: Golden Yellow fill + Dark Slate text (Ignition CTA)
/// - Secondary: Deep Navy fill + White text
/// - Ghost: Clean outline + Blue text
/// - Danger: Red fill or border for emergency / reject
class CarfixziButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const CarfixziButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        bgColor = AppColors.accentGold;
        textColor = AppColors.darkSlate;
        break;
      case ButtonVariant.secondary:
        bgColor = AppColors.secondaryNavy;
        textColor = Colors.white;
        break;
      case ButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = AppColors.primaryContainer;
        borderSide = const BorderSide(color: AppColors.primaryContainer, width: 1.5);
        break;
      case ButtonVariant.danger:
        bgColor = AppColors.error;
        textColor = Colors.white;
        break;
    }

    final effectiveOnPressed = isLoading ? null : onPressed;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: effectiveOnPressed == null ? bgColor.withOpacity(0.5) : bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: borderSide,
        ),
        child: InkWell(
          onTap: effectiveOnPressed,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: textColor),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: AppTypography.labelLarge.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
