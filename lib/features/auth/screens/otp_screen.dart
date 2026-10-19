import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../../../core/common/widgets/app_buttons.dart';
import '../../../core/common/widgets/app_logo.dart';
import '../../../core/common/widgets/app_scaffold.dart';
import '../../../core/constants/assets_const.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/gap.dart';
import '../controller/auth_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.email,
    this.isFogoteVerify = false,
  });

  final String email;
  final bool? isFogoteVerify;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final otpController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    otpController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> verify() {
    if (widget.isFogoteVerify == true) {
      return ref
          .read(authCtrlProvider.notifier)
          .verifyResetOtp(widget.email, otpController.text);
    } else {
      return ref
          .read(authCtrlProvider.notifier)
          .verifyOtp(widget.email, otpController.text.trim());
    }
  }

  Future<void> resend() {
    return ref.read(authCtrlProvider.notifier).resendOtp(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: AppTextStyles.h2.copyWith(color: AppColors.primary),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.borderFocus),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: AppColors.surfaceCream,
        border: Border.all(color: AppColors.borderFocus),
      ),
    );

    return AppScaffold(
      backgroundColor: AppColors.surface,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: 420,
              ),
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  AppLogo(images: AppAssets.img.logo, h: 90, fit: .cover),

                  Gap.h(20),

                  /// [Text] widget for the screen title.
                  Text('OTP', style: AppTextStyles.h1),
                  Gap.h(8),

                  /// [Text] widget for the helper message.
                  Text(
                    'Enter the 6-digit code sent to your email',
                    style: AppTextStyles.bodyLarge,
                    textAlign: .center,
                  ),

                  Gap.h(24),

                  /// [Pinput] widget for the OTP input.
                  Consumer(
                    builder: (context, ref, child) {
                      final isLoading = ref.watch(
                        authCtrlProvider.select((s) => s.isLoading),
                      );
                      return Pinput(
                        length: 6,
                        controller: otpController,
                        focusNode: focusNode,
                        enabled: !isLoading,
                        autofocus: true,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        showCursor: true,
                        // onCompleted: (_) => verify(),
                      );
                    },
                  ),

                  Gap.h(12),

                  /// [Row] widget for the "Didn't received code? Resend" link.
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        "Didn't received code?",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      Gap.w(8),
                      GestureDetector(
                        onTap: resend,
                        child: Text(
                          'Resend',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Gap.h(24),

                  /// [errMsg]
                  Consumer(
                    builder: (context, ref, child) {
                      final errMsg = ref.watch(
                        authCtrlProvider.select((s) => s.verifyOtpErrMsg),
                      );

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

                  /// [AppPrimaryButton] widget for the verify action.
                  AppPrimaryButton(label: 'Verify', onAsyncPressed: verify),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
