import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Logo + title + subtitle at the top of auth screens.
///
/// Figma: logo 150×99 (centered) → 40px gap →
/// title Playfair Display SemiBold 24 #000 → 8px gap →
/// subtitle DM Sans Regular 16 #000.
/// Used on: Login Screen, Forgot Password, OTP, Create Account.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.logo,
    this.logoGap = 40,
  });

  /// e.g. "Welcome back"
  final String title;

  /// e.g. "Please enter your email & password to access your account."
  final String? subtitle;

  /// e.g. `Image.asset('assets/images/logo.png')`
  final Widget? logo;
  final double logoGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        if (logo != null) ...[
          Center(child: SizedBox(width: 150, height: 99, child: logo)),
          SizedBox(height: logoGap),
        ],
        Text(title, style: AppTextStyles.h1),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

/// "Don't have an account? Sign Up" style line.
///
/// Figma: centered, DM Sans Regular 12 #000 + 8px gap +
/// link DM Sans Regular 12 #C29266.
/// Used on: Login Screen, Forgot Password ("Remember Password? Sign In"),
/// Create Account ("Already have an account? Sign In").
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  final String text;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      children: [
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          behavior: .opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(linkText, style: AppTextStyles.link),
          ),
        ),
      ],
    );
  }
}
