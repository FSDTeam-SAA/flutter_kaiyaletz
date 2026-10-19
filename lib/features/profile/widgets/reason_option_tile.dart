import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// One radio row in a [ReasonOptionList].
///
/// Figma: 24×24 circle, border 1.5px #D6B698, gap 12 → label DM Sans
/// Regular 16 #333333. Selected: outer ring #C29266, filled inner dot
/// #C29266 (8px).
class ReasonOptionTile extends StatelessWidget {
  const ReasonOptionTile({
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: .circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.brown300,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: .circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single-select list of reasons, used on the "Delete Account" /
/// "Are you sure?" confirmation screen.
///
/// Pass [reasons] with no duplicates — the Figma design has
/// "I'm concerned about my privacy" listed twice; drop one when wiring
/// real copy.
class ReasonOptionList extends StatelessWidget {
  const ReasonOptionList({
    super.key,
    required this.reasons,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> reasons;
  final int? selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        for (var i = 0; i < reasons.length; i++)
          ReasonOptionTile(
            label: reasons[i],
            isSelected: selectedIndex == i,
            onTap: () => onChanged(i),
          ),
      ],
    );
  }
}
