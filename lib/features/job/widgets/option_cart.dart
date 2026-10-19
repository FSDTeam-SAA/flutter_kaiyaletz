import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';


/// Tappable option card with a round icon, title, description and an
/// optional badge.
///
/// Figma (Room Capture): 353×75, radius 8, padding 12, tan fill
/// #ECDDD0; icon circle 40×40 (light fill, brown #C29266 icon 24) →
/// 8px gap → title DM Sans Medium 16 #000 + description Regular 12
/// (#7A7972); badge "AI": pill, padding 10/2, fill #3B82B8 @20%,
/// text DM Sans Regular 12 #3B82B8.
/// Used on: Room Capture ("Room Scan").
class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.badgeLabel,
    this.isSelected = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;

  /// e.g. "AI". Hidden when null.
  final String? badgeLabel;

  /// Adds a brown outline. The design shows no selected state yet, so
  /// this is off by default.
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceTag,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? const BorderSide(color: AppColors.primary)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceCream,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.inputLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badgeLabel != null) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.statusNew.withAlpha(51),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              badgeLabel!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.statusNew,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(description, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}