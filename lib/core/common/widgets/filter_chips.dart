import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Small category label (read-only).
///
/// Figma: fill #ECDDD0, padding 6/2, DM Sans Regular 10 #7D7D7D.
/// Used on: ProductCard ("Base", "Wall", "Tall", "Island") in Catalog,
/// Catalog Details, Catalog Add.
class CategoryTag extends StatelessWidget {
  const CategoryTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: AppColors.surfaceTag,
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}

/// Single selectable filter chip.
///
/// Figma: padding 10/4, DM Sans Regular 12.
/// Selected: fill #C29266, text #FFFFFF. Unselected: fill #ECDDD0, text #545454.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: .opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceTag,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Horizontal row of filter chips (scrolls if it doesn't fit).
///
/// Figma: chips with 8px gap.
/// Used on: All Jobs (All / New / In Progress / Completed / Proposal),
/// Catalog, Catalog Details, Catalog Add (All / Base / Wall / Tall / Island).
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            AppFilterChip(
              label: options[i],
              isSelected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          ],
        ],
      ),
    );
  }
}
