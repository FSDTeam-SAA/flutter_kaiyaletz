import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Search input.
///
/// Figma: 353×38, border 1px #ECDDD0, radius 8, padding 8, search icon 16,
/// placeholder DM Sans Regular 12 #7D7D7D.
/// Used on: All Jobs ("Search jobs, customers..."), Catalog, Catalog Details,
/// Catalog Add ("Search products or SKU...").
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.hint = 'Search...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: .search,
      cursorColor: AppColors.primary,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 8, right: 8),
          child: Icon(Icons.search, size: 16, color: AppColors.textMuted),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 16,
        ),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.borderFocus),
      ),
    );
  }
}
