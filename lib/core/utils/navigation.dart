import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Transition styles for [AppNav], mirroring GetX's `Transition` enum.
enum NavTransition { fade, rightToLeft, leftToRight, upToDown, downToUp, none }

/// Default duration for pushing a new screen onto the stack.
const forwardDuration = Duration(milliseconds: 300);

/// Default duration for popping back off the stack — snappier than the push.
const backDuration = Duration(milliseconds: 220); // ~25% faster

/// Static navigation helper backed by a global [NavigatorState] key, so
/// screens can be pushed/replaced without a [BuildContext].
///
/// Usage:
/// ```dart
/// AppNav.to(const LoginScreen());
/// AppNav.off(const LoginScreen(), transition: .leftToRight);
/// AppNav.offAll(const LoginScreen());
/// AppNav.back();
/// ```
class AppNav {
  AppNav._();

  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static NavigatorState get _navigator => key.currentState!;

  /// Push [page] onto the stack. Equivalent to `Get.to`.
  ///
  /// When [cupertino] is true (default) and [transition] is the default
  /// `rightToLeft`, this uses [CupertinoPageRoute] for a native iOS push
  /// with the built-in swipe-to-back gesture — [duration] is ignored in
  /// that case, since Cupertino's timing is fixed internally.
  static Future<T?> to<T>(
    Widget page, {
    NavTransition transition = .rightToLeft,
    Duration duration = forwardDuration,
    bool cupertino = true,
  }) {
    return _navigator.push<T>(
      _buildRoute(page, transition, duration, cupertino),
    );
  }

  /// Replace the current screen with [page]. Equivalent to `Get.off`.
  static Future<T?> off<T>(
    Widget page, {
    NavTransition transition = .rightToLeft,
    Duration duration = forwardDuration,
    bool cupertino = true,
  }) {
    return _navigator.pushReplacement<T, void>(
      _buildRoute(page, transition, duration, cupertino),
    );
  }

  /// Replace the entire stack with [page]. Equivalent to `Get.offAll`.
  static Future<T?> offAll<T>(
    Widget page, {
    NavTransition transition = .rightToLeft,
    Duration duration = forwardDuration,
    bool cupertino = true,
  }) {
    return _navigator.pushAndRemoveUntil<T>(
      _buildRoute(page, transition, duration, cupertino),
      (route) => false,
    );
  }

  /// Pop the current screen. Equivalent to `Get.back`.
  static void back<T>([T? result]) {
    if (_navigator.canPop()) _navigator.pop<T>(result);
  }

  static Route<T> _buildRoute<T>(
    Widget page,
    NavTransition transition,
    Duration duration,
    bool cupertino,
  ) {
    if (cupertino && transition == .rightToLeft) {
      return CupertinoPageRoute<T>(builder: (_) => page);
    }
    return _route(page, transition, duration);
  }

  static Route<T> _route<T>(
    Widget page,
    NavTransition transition,
    Duration duration,
  ) {
    if (transition == .none) {
      return MaterialPageRoute<T>(builder: (_) => page);
    }

    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: backDuration,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic, // arriving: eases out
          reverseCurve: Curves.easeInCubic, // leaving: eases in
        );

        switch (transition) {
          case .fade:
            return FadeTransition(opacity: curved, child: child);
          case .rightToLeft:
            return SlideTransition(
              position: Tween(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            );
          case .leftToRight:
            return SlideTransition(
              position: Tween(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            );
          case .downToUp:
            return SlideTransition(
              position: Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            );
          case .upToDown:
            return SlideTransition(
              position: Tween(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            );
          case .none:
            return child;
        }
      },
    );
  }
}
