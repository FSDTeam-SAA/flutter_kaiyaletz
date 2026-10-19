import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'app_loading_indicator.dart';

/// Base screen layout used by every mobile screen.
///
/// Figma layout: status bar → header (y 54) → 20px gap → content (y 98),
/// 20px horizontal screen padding, decorative blurred cream shape in the
/// top-right corner ("Group 13").
///
/// Background colors from the design:
///   AppColors.background     (#FDFCFA) → most screens (default)
///   AppColors.backgroundWarm (#F2EEE3) → Home, Create Account, Profile Setup
///   AppColors.surface        (#FFFFFF) → Login Screen, Forgot Password, OTP
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.header,
    this.backgroundColor = AppColors.background,
    this.bottomBar,
    this.floatingActionButton,
    this.showDecoration = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
    this.headerGap = 20,
    this.resizeToAvoidBottomInset = true,
    this.isUnfocus = true,
    this.isLoading = false,
    this.showLoadingOverlay = true,
  });

  final Widget body;

  /// Usually [AppBackHeader].
  final Widget? header;
  final Color backgroundColor;

  /// [AppBottomNavBar] or [BottomActionBar].
  final Widget? bottomBar;
  final Widget? floatingActionButton;

  /// Shows the blurred decorative shape behind the content.
  final bool showDecoration;
  final EdgeInsets padding;
  final double headerGap;
  final bool resizeToAvoidBottomInset;
  final bool? isUnfocus;
  final bool? isLoading;
  final bool showLoadingOverlay;

  @override
  Widget build(BuildContext context) {
    final loading = isLoading ?? false;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottomBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: loading,
            child: GestureDetector(
              onTap: () =>
                  isUnfocus == false ? {} : FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  if (showDecoration)
                    const Positioned(
                      top: -233,
                      right: -148,
                      child: IgnorePointer(child: _BackgroundBlob()),
                    ),
                  SafeArea(
                    bottom: bottomBar == null,
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        if (header != null)
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              padding.left,
                              0,
                              padding.right,
                              headerGap,
                            ),
                            child: header,
                          ),
                        Expanded(
                          child: Padding(padding: padding, child: body),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (loading && showLoadingOverlay)
            Positioned.fill(child: ColoredBox(color: AppColors.overlay)),
          if (loading) const Center(child: AppLoadingIndicator()),
        ],
      ),
    );
  }
}

/// Two blurred cream ovals (Figma "Group 13": 406×444 shapes,
/// layer blur 81 and 130, fill #F9F4F0).
class _BackgroundBlob extends StatelessWidget {
  const _BackgroundBlob();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 453,
      height: 537,
      child: Stack(
        children: [
          Positioned(left: 0, top: 93, child: _BlurOval(sigma: 40)),
          Positioned(left: 47, top: 0, child: _BlurOval(sigma: 65)),
        ],
      ),
    );
  }
}

class _BlurOval extends StatelessWidget {
  const _BlurOval({required this.sigma});

  final double sigma;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: sigma,
        sigmaY: sigma,
        tileMode: .decal,
      ),
      child: Container(
        width: 406,
        height: 444,
        decoration: const BoxDecoration(
          color: AppColors.surfaceCream,
          borderRadius: BorderRadius.all(Radius.elliptical(203, 222)),
        ),
      ),
    );
  }
}
