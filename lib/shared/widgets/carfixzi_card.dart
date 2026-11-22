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
    final effectiveBorderSide = border != null
        ? border!.top
        : const BorderSide(
            color: Color.fromRGBO(45, 49, 66, 0.08),
            width: 1,
          );

    return Material(
      color: color ?? AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: effectiveBorderSide,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

