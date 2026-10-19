import 'package:flutter/material.dart';

import '../../constants/assets_const.dart' hide Icons;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_svg.dart';

/// Screen header.
///
/// Use the default constructor for the back-arrow + title header used on
/// most screens. Use [AppHeader.custom] to build any other header layout
/// (e.g. the Home avatar + greeting + notification-bell header) out of
/// generic `leading` / `middle` / `trailing` slots, so new header designs
/// don't need new fields added here.
///
/// Pass it to `AppScaffold(header: ...)`.
class AppHeader extends StatelessWidget {
  /// Back arrow + title.
  ///
  /// Figma ("Navigation Stutus"): back icon 24 → 8px gap → title
  /// Playfair Display SemiBold 20 #1E1E1E.
  /// Used on 18 screens: All Jobs, Catalog, Catalog Details, Catalog Add,
  /// Create Job, Job Details, Room Capture, Measurements,
  /// Continue to Room Captured, Ai Layout, Estimate, Proposal, Edit Profile,
  /// General Settings, Change Password, Notification settings,
  /// Delete Account, Contact us.
  const AppHeader({
    super.key,
    required String this.title,
    this.onBack,
    this.showBack,
    this.trailing,
  }) : leading = null,
       middle = null,
       spacing = 8;

  /// Any header layout, built from generic slots.
  ///
  /// [leading] and [trailing] are placed at the edges, [middle] fills the
  /// remaining space (via `Expanded`), and [spacing] is the gap on either
  /// side of [middle]. Any of the three can be omitted.
  ///
  /// e.g. the Home header (avatar 40 circle → 12px gap → "GOOD EVENING"
  /// overline above the user's name → round notification button):
  /// ```dart
  /// AppHeader.custom(
  ///   leading: const CircleAvatar(radius: 20, backgroundImage: ...),
  ///   middle: Column(
  ///     crossAxisAlignment: .start,
  ///     mainAxisSize: .min,
  ///     children: [
  ///       Text('Good evening', style: AppTextStyles.overline),
  ///       Text('Roberts Adam', style: AppTextStyles.h2),
  ///     ],
  ///   ),
  ///   trailing: InkResponse(onTap: ..., child: const CircleAvatar(...)),
  /// )
  /// ```
  const AppHeader.custom({
    super.key,
    this.leading,
    this.middle,
    this.trailing,
    this.spacing = 12,
  }) : title = null,
       onBack = null,
       showBack = null;

  final String? title;

  /// Defaults to `Navigator.maybePop`. [AppHeader] (back + title) only.
  final VoidCallback? onBack;

  /// Whether to show the back arrow. Defaults to `null`, which shows it
  /// only when there's a previous route to pop back to (via
  /// `Navigator.canPop`) — e.g. hidden automatically on tab-root screens
  /// like Catalog opened from the bottom nav. Pass `true`/`false` to
  /// override the auto-detection. [AppHeader] (back + title) only.
  final bool? showBack;

  /// [AppHeader.custom]: widget at the left edge (e.g. an avatar or icon).
  /// [AppHeader] (back + title): optional widget on the right instead
  /// (e.g. an edit or share icon).
  final Widget? leading;

  /// Widget on the right. See [leading] for which constructor uses which.
  final Widget? trailing;

  /// [AppHeader.custom] only: fills the remaining space between [leading]
  /// and [trailing].
  final Widget? middle;

  /// [AppHeader.custom] only: gap on either side of [middle].
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (title == null) {
      return Row(
        children: [
          if (leading != null) ...[leading!, SizedBox(width: spacing)],
          if (middle != null) Expanded(child: middle!),
          if (trailing != null) ...[SizedBox(width: spacing), trailing!],
        ],
      );
    }

    final canGoBack = showBack ?? Navigator.canPop(context);
    return Row(
      children: [
        if (canGoBack) ...[
          InkResponse(
            onTap: onBack ?? () => Navigator.maybePop(context),
            radius: 20,
            child: AppSvg(
              asset: AppAssets.icons.back,
              width: 24,
              height: 24,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title!,
            style: AppTextStyles.h2,
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }
}
