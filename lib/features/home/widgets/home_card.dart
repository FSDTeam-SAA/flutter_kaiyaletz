import 'package:flutter/material.dart';

import '../../../core/common/widgets/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// "Create New Job" hero card at the top of Home.
///
/// Figma: fill #ECDDD0 (tan), radius 12, padding 16; title Playfair
/// SemiBold 24 #000; description DM Sans 16 #545454; 40×40 brown square
/// icon button (bottom-left); kitchen elevation sketch illustration
/// bleeding off the right edge.
///
/// The illustration is a design asset, not something drawn in code —
/// export it from Figma as a PNG/SVG and pass it as [illustration].
class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    this.title = 'Create New Job',
    this.description = 'Start a new project and win more customers.',
    required this.onTap,
    this.illustration,
  });

  final String title;
  final String description;
  final VoidCallback onTap;

  /// e.g. `Image.asset('assets/images/kitchen_sketch.png')`. Card still
  /// renders correctly (just without the right-side art) if omitted.
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceTag,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          if (illustration != null)
            Positioned(
              right: -8,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
                child: SizedBox(width: 160, child: illustration),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                SizedBox(
                  width: illustration != null ? 170 : null,
                  child: Text(title, style: AppTextStyles.h1),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: illustration != null ? 170 : null,
                  child: Text(
                    description,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppIconButton(icon: Icons.add, onSimplePressed: onTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
