import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/features/auth/controller/auth_controller.dart';
import 'package:flutter_kaiyaletz/features/auth/screens/forgate_pass_screen.dart';
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
import '../widgets/remember_forgot_widget.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // focus
  final passFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passFocusNode.dispose();
    super.dispose();
  }

  Future<void> login(bool? verify) {
    final email = emailController.text.trim();
    final pass = passwordController.text;

    if (verify == true) {
      return ref.read(authCtrlProvider.notifier).resendOtp(email);
    }

    return ref.read(authCtrlProvider.notifier).login(email, pass);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building LoginScreen");

    final isLoading = ref.watch(authCtrlProvider.select((s) => s.isLoading));

    final errMsg = ref.watch(authCtrlProvider.select((s) => s.loginErrMsg));

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
                    Text('Welcome Back', style: AppTextStyles.h1),
                    Gap.h(8),

                    /// [Text] widget for the welcome message.
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        'Please enter your email & password to access your account.',
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

                    AppTextField(
                      hint: 'Enter your email ',
                      autovalidateMode: .disabled,
                      controller: emailController,
                      keyboardType: .emailAddress,
                      textInputAction: .next,
                      onSubmitted: (_) => passFocusNode.requestFocus(),
                      enabled: !isLoading,
                      validator: Validators.email,
                    ),

                    Gap.h(12),

                    /// [Text] widget for the password label.
                    Align(
                      alignment: .centerLeft,
                      child: Text('Password', style: AppTextStyles.inputLabel),
                    ),
                    Gap.h(8),

                    AppTextField(
                      hint: 'Enter your password',
                      autovalidateMode: .disabled,
                      controller: passwordController,
                      focusNode: passFocusNode,
                      textInputAction: .done,
                      isPassword: true,
                      enabled: !isLoading,
                      validator: (value) => Validators.required(
                        value,
                        message: 'Please enter your password',
                      ),
                    ),

                    Gap.h(12),

                    /// [RememberForgotRow] widget for the "Remember Me" checkbox and "Forgot Password?" link.
                    RememberForgotRow(
                      onForgotTap: () {
                        AppNav.to(ForgatePassScreen());
                      },
                    ),

                    Gap.h(24),

                    /// [errMsg]
                    if (errMsg.isNotEmpty) ...[
                      Text(errMsg, style: TextStyle(color: AppColors.error)),
                      Gap.h(8),
                    ],

                    /// [AppPrimaryButton] widget for the login action.
                    /// [Botton Change to Verify] Login button can be Send OTP button if user is not verified
                    Consumer(
                      builder: (context, ref, _) {
                        final loginButtonText = ref.watch(
                          authCtrlProvider.select((b) => b.loginButtonText),
                        );
                        final verify = loginButtonText == "Verify Email";

                        return AppPrimaryButton(
                          label: loginButtonText,
                          onValidate: () => formKey.currentState!.validate(),
                          onAsyncPressed: () => login(verify),
                        );
                      },
                    ),

                    Gap.h(16),

                    /// [Row] widget for the "Don't have an account? Sign Up" link.
                    Row(
                      mainAxisAlignment: .center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Gap.w(8),
                        GestureDetector(
                          onTap: () {
                            AppNav.to(const SignupScreen());
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
