import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/features/auth/controller/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/widgets/app_buttons.dart';
import '../../../core/common/widgets/app_logo.dart';
import '../../../core/common/widgets/app_scaffold.dart';
import '../../../core/common/widgets/app_text_field.dart';
import '../../../core/constants/assets_const.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/gap.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/utils/validators.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // focus
  final passFocusNode = FocusNode();
  final confirmPassFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    passFocusNode.dispose();
    confirmPassFocusNode.dispose();
    super.dispose();
  }

  Future<void> signup() {
    final email = emailController.text;
    final pass = passwordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    return ref.read(authCtrlProvider.notifier).signup(email, pass, confirmPass);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building SignupScreen");

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

                    /// [Text] widget for the welcome message.
                    Text('Create Account', style: AppTextStyles.h1),
                    Gap.h(8),

                    /// [Text] widget for the welcome message.
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        'Please enter your information and create your account.',
                        style: AppTextStyles.bodyLarge,
                        textAlign: .center,
                      ),
                    ),

                    Gap.h(24),

                    /// [Text] widget for the email label.
                    Align(
                      alignment: .centerLeft,
                      child: Text('Email', style: AppTextStyles.inputLabel),
                    ),
                    Gap.h(8),

                    Consumer(
                      builder: (context, ref, child) {
                        final isLoading = ref.watch(
                          authCtrlProvider.select((s) => s.isLoading),
                        );
                        return AppTextField(
                          hint: 'Enter your email',
                          autovalidateMode: .disabled,
                          controller: emailController,
                          keyboardType: .emailAddress,
                          textInputAction: .next,
                          enabled: !isLoading,
                          validator: Validators.email,
                        );
                      },
                    ),

                    Gap.h(12),

                    /// [Text] widget for the password label.
                    Align(
                      alignment: .centerLeft,
                      child: Text('Password', style: AppTextStyles.inputLabel),
                    ),
                    Gap.h(8),

                    Consumer(
                      builder: (context, ref, child) {
                        final isLoading = ref.watch(
                          authCtrlProvider.select((s) => s.isLoading),
                        );
                        return AppTextField(
                          hint: 'Enter your password',
                          autovalidateMode: .disabled,
                          controller: passwordController,
                          focusNode: passFocusNode,
                          textInputAction: .next,
                          isPassword: true,
                          enabled: !isLoading,
                          validator: (value) => Validators.password(
                            value,
                            requiredMessage: 'Please enter a password',
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
                          hint: 'Enter your confirm password',
                          autovalidateMode: .disabled,
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
                          authCtrlProvider.select((s) => s.signupErrMsg),
                        );

                        // if (errMsg.isEmpty) {
                        //   return const SizedBox.shrink();
                        // }
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

                    /// [AppPrimaryButton] widget for the signup action.
                    AppPrimaryButton(
                      label: 'Create Account',
                      onValidate: () => formKey.currentState!.validate(),
                      onAsyncPressed: signup,
                    ),

                    Gap.h(16),

                    /// [Row] widget for the "Already have an account? Sign Up" link.
                    Row(
                      mainAxisAlignment: .center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Gap.w(8),
                        GestureDetector(
                          onTap: () {
                            AppNav.back();
                          },
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
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
