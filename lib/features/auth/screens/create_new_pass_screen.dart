import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/widgets/app_buttons.dart';
import '../../../core/common/widgets/app_logo.dart';
import '../../../core/common/widgets/app_scaffold.dart';
import '../../../core/common/widgets/app_text_field.dart';
import '../../../core/constants/assets_const.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/gap.dart';
import '../../../core/utils/validators.dart';
import '../controller/auth_controller.dart';

class CreateNewPassScreen extends ConsumerStatefulWidget {
  const CreateNewPassScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  final String email;
  final String otp;

  @override
  ConsumerState<CreateNewPassScreen> createState() =>
      _CreateNewPassScreenState();
}

class _CreateNewPassScreenState extends ConsumerState<CreateNewPassScreen> {
  final formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // focus
  final confirmPassFocusNode = FocusNode();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    confirmPassFocusNode.dispose();
    super.dispose();
  }

  Future<void> resetPassword() {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    return ref
        .read(authCtrlProvider.notifier)
        .resetPass(widget.email, widget.otp, password, confirmPassword);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
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
                key: formKey,
                child: Column(
                  mainAxisAlignment: .center,
                  children: [
                    AppLogo(images: AppAssets.img.logo, h: 90, fit: .cover),

                    Gap.h(20),

                    /// [Text] widget for the screen title.
                    Text('Create New Password', style: AppTextStyles.h1),

                    Gap.h(24),

                    /// [Text] widget for the new password label.
                    Align(
                      alignment: .centerLeft,
                      child: Text(
                        'New Password',
                        style: AppTextStyles.inputLabel,
                      ),
                    ),
                    Gap.h(8),

                    Consumer(
                      builder: (context, ref, child) {
                        final isLoading = ref.watch(
                          authCtrlProvider.select((s) => s.isLoading),
                        );
                        return AppTextField(
                          hint: 'Enter your new password',
                          controller: passwordController,
                          textInputAction: .next,
                          isPassword: true,
                          enabled: !isLoading,
                          validator: (value) => Validators.password(
                            value,
                            requiredMessage: 'Please enter a new password',
                          ),
                        );
                      },
                    ),

                    Gap.h(12),

                    /// [Text] widget for the confirm password label.
                    Align(
                      alignment: .centerLeft,
                      child: Text(
                        'Confirm Password',
                        style: AppTextStyles.inputLabel,
                      ),
                    ),
                    Gap.h(8),

                    Consumer(
                      builder: (context, ref, child) {
                        final isLoading = ref.watch(
                          authCtrlProvider.select((s) => s.isLoading),
                        );
                        return AppTextField(
                          hint: 'Confirm your new password',
                          controller: confirmPasswordController,
                          focusNode: confirmPassFocusNode,
                          textInputAction: .done,
                          isPassword: true,
                          enabled: !isLoading,
                          validator: (value) => Validators.confirmPassword(
                            value,
                            passwordController.text,
                          ),
                        );
                      },
                    ),

                    Gap.h(24),

                    /// [errMsg]
                    Consumer(
                      builder: (context, ref, child) {
                        final errMsg = ref.watch(
                          authCtrlProvider.select((s) => s.resetPassError),
                        );

                        if (errMsg.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            Text(
                              errMsg,
                              style: TextStyle(color: AppColors.error),
                            ),
                            Gap.h(8),
                          ],
                        );
                      },
                    ),

                    /// [AppPrimaryButton] widget for the reset password action.
                    AppPrimaryButton(
                      label: 'Sign In',
                      onValidate: () => formKey.currentState!.validate(),
                      onAsyncPressed: resetPassword,
                    ),
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
