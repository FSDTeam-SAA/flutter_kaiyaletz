import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/common/widgets/app_dialog.dart';
import 'package:flutter_kaiyaletz/core/common/widgets/widgets.dart';
import 'package:flutter_kaiyaletz/core/theme/app_text_styles.dart';
import 'package:flutter_kaiyaletz/features/profile/controller/profile_controller.dart';
import 'package:flutter_kaiyaletz/features/profile/widgets/reason_option_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';

class DeleteScreenConfrimation extends ConsumerStatefulWidget {
  const DeleteScreenConfrimation({super.key});

  @override
  ConsumerState<DeleteScreenConfrimation> createState() =>
      _DeleteScreenConfrimationState();
}

class _DeleteScreenConfrimationState
    extends ConsumerState<DeleteScreenConfrimation> {
  final _otherReasonController = TextEditingController();

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: 'Delete account?',
      message:
          'This action cannot be undone. Your profile, settings, and '
          'all associated data will be permanently removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (!confirmed || !context.mounted) return;
    await ref.read(profileProvider.notifier).deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(
      profileProvider.select((s) => s.deleteAccountReasonIndex),
    );
    final isOtherReason = selected == deleteAccountReasons.length - 1;
    final isLoading = ref.watch(
      profileProvider.select((s) => s.isLoadingDeleteAccoung),
    );

    return AppScaffold(
      header: const AppHeader(title: 'General Settings'),
      isLoading: isLoading,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Text(
              'Are you sure to delete your account?',
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Deleting your account will permanently remove your profile, '
              'settings, and all associated data from our platform. Once the '
              'deletion process is completed, your account cannot be restored '
              'and you will lose access to all features and services linked '
              'to it.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Are you sure to delete your account?',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            ReasonOptionList(
              reasons: deleteAccountReasons,
              selectedIndex: selected,
              onChanged: (i) => ref
                  .read(profileProvider.notifier)
                  .selectDeleteAccountReason(i),
            ),
            if (isOtherReason) ...[
              const SizedBox(height: 12),
              AppTextField(
                hint: 'Tell us your reason',
                controller: _otherReasonController,
                maxLines: 3,
                onChanged: (value) => ref
                    .read(profileProvider.notifier)
                    .setDeleteAccountOtherReason(value),
              ),
            ],
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: AppOutlineButton(
                    label: 'Cancel',
                    onSimplePressed: () => Navigator.maybePop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppPrimaryButton(
                    label: 'Delete',
                    onSimplePressed: () => _confirmDelete(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
