import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// 4-Bar Password Strength Visual Meter following design specification
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = Validators.getPasswordStrength(password);
    Color barColor;
    String strengthLabel;

    switch (strength) {
      case 0:
      case 1:
        barColor = AppColors.error;
        strengthLabel = 'Weak';
        break;
      case 2:
        barColor = AppColors.warning;
        strengthLabel = 'Fair';
        break;
      case 3:
        barColor = AppColors.secondary;
        strengthLabel = 'Good';
        break;
      case 4:
      default:
        barColor = AppColors.success;
        strengthLabel = 'Strong (Firebase Compliant)';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            final isFilled = index < strength;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 4),
                decoration: BoxDecoration(
                  color: isFilled ? barColor : AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Strength: $strengthLabel',
              style: AppTypography.bodySmall.copyWith(
                color: barColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${password.length}/12 chars minimum',
              style: AppTypography.bodySmall.copyWith(
                color: password.length >= 12 ? AppColors.success : AppColors.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

