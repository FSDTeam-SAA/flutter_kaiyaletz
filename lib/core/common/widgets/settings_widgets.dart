import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_svg.dart';

/// White card that groups [SettingsTile]s with dividers.
///
/// Figma: fill #FFFFFF, border 1px #F6F6F6, radius 12, padding 12,
/// row dividers 1px #F0F0F0.
/// Used on: Settings, General Settings, Notification settings.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      clipBehavior: .antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: .min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.dividerLight,
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// One settings row.
///
/// Figma: height 48, icon 24 #1E1E1E → 16px gap → label 14 #111111,
/// chevron 24 #696969 on the right.
/// Normalized to DM Sans (the design uses Roboto here).
///
/// For Notification settings, pass a `Switch` as [trailing].
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.color,
  });

  /// Path to the icon SVG asset (see [AppAssets.icons]).
  final String? icon;
  final String label;
  final VoidCallback? onTap;

  /// Replaces the chevron (e.g. a Switch).
  final Widget? trailing;

  /// Overrides icon & label color (e.g. AppColors.danger for "Delete Account").
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            if (icon != null) ...[
              AppSvg(
                asset: icon!,
                width: 24,
                height: 24,
                color: color ?? AppColors.textDark,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color ?? AppColors.textTile,
                ),
                maxLines: 1,
                overflow: .ellipsis,
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: AppColors.iconMuted,
                ),
          ],
        ),
      ),
    );
  }
}

/// User card at the top of Settings.
///
/// Figma: fill #FFFFFF, border 1px #F6F6F6, radius 8, padding 8,
/// avatar 48 circle → 16px gap → name Medium 18 #292D32,
/// email Regular 12 #696969 (6px gap).
/// Used on: Settings.
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({
    super.key,
    required this.name,
    required this.email,
    this.avatar,
    this.onTap,
  });

  final String name;
  final String email;

  /// e.g. `NetworkImage(url)`. Shows a person icon if null.
  final ImageProvider? avatar;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      clipBehavior: .antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceTag,
                backgroundImage: avatar,
                child: avatar == null
                    ? const Icon(
                        Icons.person_outline,
                        color: AppColors.textDark,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.listTitle.copyWith(
                        fontWeight: .w500,
                        color: AppColors.textProfileName,
                      ),
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.iconMuted,
                      ),
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: AppColors.iconMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
