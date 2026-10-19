import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/features/auth/controller/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// "Remember Me" checkbox + "Forgot Password?" link row.
///
/// Figma: checkbox 20×20, radius 4, border 1px #000000 (checked: fill
/// #C29266); "Remember Me" DM Sans Regular 14 #000000; "Forgot Password?"
/// DM Sans Regular 14 #C29266, right-aligned.
/// Used on: Login Screen.
class RememberForgotRow extends StatelessWidget {
  const RememberForgotRow({super.key, required this.onForgotTap});

  final VoidCallback onForgotTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RememberMeCheckbox(),
        const Spacer(),
        GestureDetector(
          behavior: .opaque,
          onTap: onForgotTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Forgot Password?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RememberMeCheckbox extends ConsumerWidget {
  const RememberMeCheckbox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: .opaque,
      onTap: () {
        final current = ref.read(authCtrlProvider.select((s) => s.rememberMe));
        ref.read(authCtrlProvider.notifier).rememberMe(!current);
      },
      child: Row(
        mainAxisSize: .min,
        children: [
          Consumer(
            builder: (context, ref, child) {
              final rememberMe = ref.watch(
                authCtrlProvider.select((state) => state.rememberMe),
              );

              return SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: rememberMe,
                  onChanged: null, // outer GestureDetector owns the toggle
                  activeColor: AppColors.primary,
                  checkColor: AppColors.onPrimary,
                  side: const BorderSide(color: AppColors.textPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Remember Me',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
