import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/theme/app_colors.dart';
import 'package:flutter_kaiyaletz/features/profile/controller/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/widgets/widgets.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/gap.dart';
import '../../../core/utils/validators.dart';

class ChangePassword extends ConsumerStatefulWidget {
  const ChangePassword({super.key});

  @override
  ConsumerState<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends ConsumerState<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final newPasswordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(profileProvider.notifier)
        .changePassword(
          currentPass: currentPasswordController.text,
          newPass: newPasswordController.text,
          confirmPass: confirmPasswordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: const AppHeader(title: 'Change Password'),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: 420,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    Text('Current Password', style: AppTextStyles.inputLabel),
                    Gap.h(8),
                    AppTextField(
                      hint: 'Enter current password',
                      controller: currentPasswordController,
                      isPassword: true,
                      textInputAction: .next,
                      onSubmitted: (_) => newPasswordFocus.requestFocus(),
                      validator: (value) => Validators.required(
                        value,
                        message: 'Please enter your current password',
                      ),
                    ),

                    Gap.h(16),

                    Text('New Password', style: AppTextStyles.inputLabel),
                    Gap.h(8),
                    AppTextField(
                      hint: 'Enter new password',
                      controller: newPasswordController,
                      focusNode: newPasswordFocus,
                      isPassword: true,
                      textInputAction: .next,
                      onSubmitted: (_) => confirmPasswordFocus.requestFocus(),
                      validator: (value) => Validators.password(
                        value,
                        requiredMessage: 'Please enter a new password',
                      ),
                    ),

                    Gap.h(16),

                    Text('Confirm Password', style: AppTextStyles.inputLabel),
                    Gap.h(8),
                    AppTextField(
                      hint: 'Re-enter new password',
                      controller: confirmPasswordController,
                      focusNode: confirmPasswordFocus,
                      isPassword: true,
                      textInputAction: .done,
                      validator: (value) => Validators.confirmPassword(
                        value,
                        newPasswordController.text,
                        requiredMessage: 'Please confirm your new password',
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Consumer(
                        builder: (context, ref, _) {
                          return Center(
                            child: Text(
                              ref.watch(
                                profileProvider.select(
                                  (t) => t.changePassErrorMsg,
                                ),
                              ),
                              textAlign: .center,
                              style: TextStyle(color: AppColors.error),
                            ),
                          );
                        },
                      ),
                    ),

                    // Gap.h(24),
                    AppPrimaryButton(label: 'Save', onAsyncPressed: save),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
