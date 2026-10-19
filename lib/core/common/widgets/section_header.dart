import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Section title with an optional "View all" link.
///
/// Figma: title Playfair Display SemiBold 20 #1A2332,
/// link DM Sans Regular 12 #C29266 + arrow 14 (4px gap).
/// Used on: Home ("Recent Jobs").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel = 'View all',
    this.onAction,
  });

  final String title;
  final String actionLabel;

  /// The link is hidden when null.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.h2.copyWith(color: AppColors.textNavy),
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
        if (onAction != null)
          GestureDetector(
            behavior: .opaque,
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: .min,
                children: [
                  Text(actionLabel, style: AppTextStyles.link),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
