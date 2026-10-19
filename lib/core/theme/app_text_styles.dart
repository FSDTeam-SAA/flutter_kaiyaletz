import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppFonts {
  AppFonts._();

  // Must match the `family:` names in pubspec.yaml
  static const String heading = 'PlayfairDisplay';
  static const String body = 'DMSans';
}

class AppTextStyles {
  AppTextStyles._();

  // ---- Headings: Playfair Display ----
  static const TextStyle display = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 30,
    fontWeight: .w400,
    height: 36 / 30,
    letterSpacing: -0.8,
    color: AppColors.textWarmDark,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 24,
    fontWeight: .w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 20,
    fontWeight: .w600,
    height: 1.2,
    color: AppColors.textDark,
  );

  // ---- Body / UI: DM Sans ----
  static const TextStyle priceLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 24,
    fontWeight: .w600,
    height: 1.2,
    color: AppColors.primary,
  );

  static const TextStyle statValue = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 20,
    fontWeight: .w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle listTitle = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 18,
    fontWeight: .w600,
    height: 1.2,
    color: AppColors.textNavy,
  );

  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: .w500,
    height: 1.2,
    color: AppColors.onPrimary,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: .w500,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle placeholder = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: .w400,
    height: 1.2,
    color: AppColors.textPlaceholder,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: .w400,
    height: 1.2,
    color: AppColors.textSecondary,
  );

  static const TextStyle productName = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: .w600,
    height: 1.2,
    color: AppColors.textNavy,
  );

  static const TextStyle productPrice = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: .w600,
    height: 1.2,
    color: AppColors.primary,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: .w500,
    height: 20 / 14,
    letterSpacing: 0.3,
    color: AppColors.textWarmMuted,
  ); // apply .toUpperCase() to text

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: .w400,
    height: 1.2,
    color: AppColors.textMeta,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: .w400,
    height: 1.2,
    color: AppColors.textMeta,
  );

  static const TextStyle link = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: .w400,
    height: 1.2,
    color: AppColors.primary,
  );

  static const TextStyle paragraph = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: .w400,
    height: 1.5,
    color: AppColors.textMeta,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 10,
    fontWeight: .w400,
    height: 1.2,
    color: AppColors.textMeta,
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: .w400,
    height: 1.2,
    color: AppColors.textMuted,
  );
}
