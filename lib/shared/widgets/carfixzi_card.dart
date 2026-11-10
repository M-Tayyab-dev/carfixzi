import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Card container with 8px radius, crisp 1px hairline border, and clean white background
class CarfixziCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;

  const CarfixziCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: border ??
            Border.all(
              color: const Color.fromRGBO(45, 49, 66, 0.08),
              width: 1,
            ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
