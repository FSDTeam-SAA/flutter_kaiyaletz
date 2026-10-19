import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Visual variants for [AppSnackbar].
enum SnackType { success, error, warning, info }

/// Static, context-free snackbar helper backed by a global
/// [ScaffoldMessengerState] key, so it can be called from anywhere
/// (controllers, repos, services) without a [BuildContext].
///
/// Setup (already wired in `main.dart`):
/// ```dart
/// MaterialApp(
///   scaffoldMessengerKey: AppSnackbar.key,
///   ...
/// )
/// ```
///
/// Usage:
/// ```dart
/// AppSnackbar.success('Profile updated');
/// AppSnackbar.error('Something went wrong');
/// AppSnackbar.warning('Check your connection');
/// AppSnackbar.info('New update available');
/// ```
class AppSnackbar {
  AppSnackbar._();

  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();

  static ScaffoldMessengerState? get _messenger => key.currentState;

  /// Shows a success snackbar.
  static void success(String message, {Duration? duration}) {
    _show(message, type: .success, duration: duration);
  }

  /// Shows an error snackbar.
  static void error(String message, {Duration? duration}) {
    _show(message, type: .error, duration: duration);
  }

  /// Shows a warning snackbar.
  static void warning(String message, {Duration? duration}) {
    _show(message, type: .warning, duration: duration);
  }

  /// Shows an info snackbar.
  static void info(String message, {Duration? duration}) {
    _show(message, type: .info, duration: duration);
  }

  /// Hides the currently visible snackbar, if any.
  static void hide() {
    _messenger?.hideCurrentSnackBar();
  }

  static void _show(
    String message, {
    required SnackType type,
    Duration? duration,
  }) {
    final messenger = _messenger;
    if (messenger == null) return;

    final style = _SnackStyle.of(type);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          duration: duration ?? const Duration(seconds: 3),
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          padding: EdgeInsets.zero,
          content: _SnackContent(message: message, style: style),
        ),
      );
  }
}

class _SnackStyle {
  const _SnackStyle({
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final IconData icon;

  static _SnackStyle of(SnackType type) {
    switch (type) {
      case .success:
        return const _SnackStyle(
          background: AppColors.success,
          foreground: AppColors.onPrimary,
          icon: Icons.check_circle_rounded,
        );
      case .error:
        return const _SnackStyle(
          background: AppColors.danger,
          foreground: AppColors.onPrimary,
          icon: Icons.error_rounded,
        );
      case .warning:
        return const _SnackStyle(
          background: AppColors.statusInProgress,
          foreground: AppColors.onPrimary,
          icon: Icons.warning_rounded,
        );
      case .info:
        return const _SnackStyle(
          background: AppColors.textNavy,
          foreground: AppColors.onPrimary,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _SnackContent extends StatelessWidget {
  const _SnackContent({required this.message, required this.style});

  final String message;
  final _SnackStyle style;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: .start,
          children: [
            Icon(style.icon, color: style.foreground, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: style.foreground,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
