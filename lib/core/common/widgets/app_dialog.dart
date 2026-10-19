import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'app_buttons.dart';

/// Shared confirm/destructive dialog helper. Centralizes the barrier
/// color (#000000 @25%, matching the auth-screen overlay elsewhere in
/// the design) so no call site has to know that value.
class AppDialogs {
  AppDialogs._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Confirm',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.overlay, // #000000 @25%
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: MediaQuery.sizeOf(dialogContext).width - 48,
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Text(title, style: AppTextStyles.h2),
                const SizedBox(height: 12),
                Text(message, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppOutlineButton(
                        label: cancelLabel,
                        onSimplePressed: () =>
                            Navigator.of(dialogContext).pop(false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isDestructive
                          ? AppDangerButton(
                              label: confirmLabel,
                              onSimplePressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                            )
                          : AppPrimaryButton(
                              label: confirmLabel,
                              onSimplePressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return result ?? false;
  }
}
