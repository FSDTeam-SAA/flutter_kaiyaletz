import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// App-wide ThemeData. Fixes two things that default Material 3 gets
/// wrong for this design:
///  1. Dialogs get a purple-tinted surface unless surfaceTintColor is
///     explicitly cleared.
///  2. The barrier behind a dialog defaults to Colors.black54, not the
///     #000000 @25% overlay used elsewhere in the design (auth screens,
///     modals).
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppFonts.body,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: .light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        // Without this, Material 3 tints the dialog with a translucent
        // wash of colorScheme.primary — this keeps it plain cream/white.
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: AppTextStyles.h2,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // Themes Flutter's built-in showDatePicker to match the app instead
      // of building a custom calendar widget — used by AppDateField.
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: AppColors.onPrimary,
        headerHeadlineStyle: AppTextStyles.h2.copyWith(
          color: AppColors.onPrimary,
        ),
        weekdayStyle: AppTextStyles.bodySmall,
        dayStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        todayForegroundColor: WidgetStateProperty.all(AppColors.textLabel),
        todayBorder: const BorderSide(color: AppColors.primary),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.onPrimary;
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textPlaceholder;
          }
          return AppColors.textPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return null;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
