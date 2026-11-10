import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// CARFIXZI Typography: Space Grotesk for Headings/Labels + Hanken Grotesk for Body
class AppTypography {
  static TextStyle displayLarge = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 1.2,
  );

  static TextStyle headlineLarge = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.28,
  );

  static TextStyle headlineMedium = GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.27,
  );

  static TextStyle headlineSmall = GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.33,
  );

  static TextStyle bodyLarge = GoogleFonts.hankenGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.hankenGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.42,
  );

  static TextStyle bodySmall = GoogleFonts.hankenGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.outline,
    height: 1.33,
  );

  static TextStyle labelLarge = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    letterSpacing: 0.2,
  );

  static TextStyle labelMedium = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelSmall = GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}

