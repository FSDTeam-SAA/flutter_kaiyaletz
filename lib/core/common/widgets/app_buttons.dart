import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// The one loading treatment every button in this file shares.
///
/// Two ways to trigger a button:
/// - `onSimplePressed`: plain sync action (navigation, local state) — fires
///   immediately, no animation.
/// - `onAsyncPressed`: async action (API call) — the surface contracts into
///   a compact, rounded square the same size as the button, which then
///   rotates slowly and continuously (~1 turn/sec) until the future
///   resolves, then eases back to its idle shape. Errors are not caught
///   here; they propagate to the caller after the surface has settled back
///   down, so screens can show their own error UI.
///
/// Buttons that are already square (icon buttons, the FAB) pass a `width`
/// equal to `height`, so the width "morph" is a no-op and only the
/// rotate/crossfade portion of the animation plays.
class _AnimatedActionSurface extends StatefulWidget {
  const _AnimatedActionSurface({
    required this.width,
    required this.height,
    required this.idleRadius,
    required this.squareRadius,
    required this.markerColor,
    required this.onSimplePressed,
    required this.onAsyncPressed,
    required this.content,
    this.onValidate,
    this.fillColor,
    this.disabledFillColor,
    this.borderColor,
    this.splashColor,
    this.highlightColor,
    this.markerSizeFactor = 0.36,
  });

  /// Idle width. Pass `double.infinity` to fill the parent, or the same
  /// value as [height] for a button that's already square.
  final double width;
  final double height;
  final double idleRadius;

  /// Corner radius once fully contracted. Pass the same value as
  /// [idleRadius] for a button that's already square/circular.
  final double squareRadius;

  final Color? fillColor;

  /// Fill shown when neither callback is provided. Defaults to [fillColor]
  /// (i.e. no visual change) when null.
  final Color? disabledFillColor;

  final Color? borderColor;
  final Color? splashColor;
  final Color? highlightColor;

  /// Color of the small rotating square shown while loading.
  final Color markerColor;

  /// Marker side length as a fraction of [height].
  final double markerSizeFactor;

  final VoidCallback? onSimplePressed;
  final Future<void> Function()? onAsyncPressed;

  /// Synchronous pre-check run right before [onAsyncPressed], before any
  /// animation starts. Return `false` to cancel the tap silently (no
  /// morph/spin, [onAsyncPressed] is not called) — for cheap local checks
  /// (e.g. "do the two password fields match?") that shouldn't be mistaken
  /// for a network call. Ignored when [onAsyncPressed] is null.
  final bool Function()? onValidate;

  /// Idle-state content (an icon, or an icon+label row).
  final Widget content;

  @override
  State<_AnimatedActionSurface> createState() => _AnimatedActionSurfaceState();
}

class _AnimatedActionSurfaceState extends State<_AnimatedActionSurface>
    with TickerProviderStateMixin {
  static const _morphDuration = Duration(milliseconds: 420);
  static const _turnDuration = Duration(seconds: 1);

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  /// 0 = idle shape, 1 = settled compact square.
  late final AnimationController _morphController = AnimationController(
    vsync: this,
    duration: _morphDuration,
  );
  late final Animation<double> _morph = CurvedAnimation(
    parent: _morphController,
    curve: Curves.easeInOutCubic,
  );

  /// One full turn per second while settled; stopped otherwise.
  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: _turnDuration,
  );

  @override
  void dispose() {
    _morphController.dispose();
    _rotationController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isLoading.value) return;

    if (widget.onAsyncPressed == null) {
      widget.onSimplePressed?.call();
      return;
    }

    if (widget.onValidate != null && !widget.onValidate!()) return;

    _isLoading.value = true;
    await _morphController.forward();
    if (!mounted) return;
    _rotationController.repeat();

    try {
      await widget.onAsyncPressed!();
    } finally {
      // Ease the wheel to a stop on a whole turn (no visual snap) before
      // un-morphing, so the shape never reverses mid-spin.
      final restingTurn = _rotationController.value.ceilToDouble();
      await _rotationController.animateTo(
        restingTurn,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
      _rotationController
        ..stop()
        ..value = 0;

      if (mounted) await _morphController.reverse();
      if (mounted) _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = widget.width.isFinite
            ? widget.width
            : constraints.maxWidth;

        return ValueListenableBuilder(
          valueListenable: _isLoading,
          builder: (context, isLoading, _) {
            final disabled =
                widget.onSimplePressed == null &&
                widget.onAsyncPressed == null &&
                !_isLoading.value;
            final idleFill = disabled
                ? (widget.disabledFillColor ?? widget.fillColor)
                : widget.fillColor;
            final squareSize = widget.height;

            return AnimatedBuilder(
              animation: Listenable.merge([_morph, _rotationController]),
              builder: (context, _) {
                // Cubic curves can overshoot [0, 1] by a hair of floating-point
                // error at the boundaries; clamp before deriving anything from it.
                final t = _morph.value.clamp(0.0, 1.0);
                final width = fullWidth + (squareSize - fullWidth) * t;
                final radius =
                    widget.idleRadius +
                    (widget.squareRadius - widget.idleRadius) * t;
                // Each opacity below is itself a division, which can independently
                // round a hair past 0/1 even when t is exactly 0 or 1 — clamp the
                // results too, since Opacity asserts on the exact bound.
                // Dims quickly on tap, holds while contracted, undims as it
                // expands back — a function of shape state, not direction.
                final dim = (1.0 - 0.08 * math.min(t / 0.2, 1.0)).clamp(
                  0.0,
                  1.0,
                );
                // Fades out over the first third of the contraction and back in
                // over the last third of the expansion — same function of t
                // either way, so the fade naturally overlaps the shape change.
                final contentOpacity = (1.0 - math.min(t / 0.33, 1.0)).clamp(
                  0.0,
                  1.0,
                );
                // Mirror image of contentOpacity: the wheel only appears once
                // mostly settled, and fades (not cuts) as it un-morphs.
                final markerOpacity = math
                    .max((t - 0.7) / 0.3, 0.0)
                    .clamp(0.0, 1.0);
                final markerSize = squareSize * widget.markerSizeFactor;

                return SizedBox(
                  width: widget.width.isFinite ? widget.width : null,
                  height: widget.height,
                  child: Center(
                    child: Opacity(
                      opacity: dim,
                      child: SizedBox(
                        width: width,
                        height: widget.height,
                        child: Material(
                          color: idleFill ?? Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(radius),
                            side: widget.borderColor == null
                                ? BorderSide.none
                                : BorderSide(color: widget.borderColor!),
                          ),
                          child: InkWell(
                            onTap: (_isLoading.value || disabled)
                                ? null
                                : _handleTap,
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radius),
                            ),
                            splashColor: widget.splashColor,
                            highlightColor: widget.highlightColor,
                            child: Center(
                              child: Stack(
                                alignment: .center,
                                children: [
                                  if (markerOpacity > 0)
                                    Opacity(
                                      opacity: markerOpacity,
                                      child: Transform.rotate(
                                        angle:
                                            _rotationController.value *
                                            2 *
                                            math.pi,
                                        child: Container(
                                          width: markerSize,
                                          height: markerSize,
                                          decoration: BoxDecoration(
                                            color: widget.markerColor,
                                            borderRadius: BorderRadius.circular(
                                              markerSize * 0.28,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (contentOpacity > 0)
                                    Opacity(
                                      opacity: contentOpacity,
                                      child: widget.content,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Primary brown button.
///
/// Figma: 353×51, radius 8, fill #C29266, label DM Sans Medium 16 white.
/// Used on: Login Screen, Forgot Password, OTP, Create Account, Profile Setup,
/// Create Job → Proposal (flow buttons), Catalog Add, Edit Profile,
/// Change Password.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onSimplePressed,
    this.onAsyncPressed,
    this.onValidate,
    this.icon,
    this.width = double.infinity,
    this.height = 51,
  });

  final String label;

  /// Sync action (navigation, local state). Ignored while loading.
  final VoidCallback? onSimplePressed;

  /// Async action (API call). Button manages its own loading animation.
  final Future<void> Function()? onAsyncPressed;

  /// Synchronous pre-check run before the loading animation starts. Return
  /// `false` to cancel the tap without animating or calling
  /// [onAsyncPressed] — use for local checks (e.g. matching password
  /// fields) that shouldn't look like a network call.
  final bool Function()? onValidate;

  /// Optional icon shown before the label.
  final Widget? icon;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _AnimatedActionSurface(
      width: width,
      height: height,
      idleRadius: 8,
      squareRadius: 16,
      fillColor: AppColors.primary,
      disabledFillColor: AppColors.primary.withAlpha(128),
      splashColor: AppColors.primaryPressed.withAlpha(102),
      highlightColor: AppColors.primaryPressed.withAlpha(51),
      markerColor: AppColors.onPrimary,
      onSimplePressed: onSimplePressed,
      onAsyncPressed: onAsyncPressed,
      onValidate: onValidate,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: .min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 10)],
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.button,
                maxLines: 1,
                overflow: .ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Outline button (transparent fill, colored border and label).
class AppOutlineButton extends StatelessWidget {
  const AppOutlineButton({
    super.key,
    required this.label,
    this.onSimplePressed,
    this.onAsyncPressed,
    this.onValidate,
    this.color = AppColors.primary,
    this.icon,
    this.width = double.infinity,
    this.height = 51,
    this.radius = 8,
  });

  final String label;
  final VoidCallback? onSimplePressed;
  final Future<void> Function()? onAsyncPressed;
  final bool Function()? onValidate;
  final Color color;
  final Widget? icon;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return _AnimatedActionSurface(
      width: width,
      height: height,
      idleRadius: radius,
      squareRadius: math.max(radius, 16),
      borderColor: color,
      splashColor: color.withAlpha(38),
      highlightColor: color.withAlpha(20),
      markerColor: color,
      onSimplePressed: onSimplePressed,
      onAsyncPressed: onAsyncPressed,
      onValidate: onValidate,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisSize: .min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.button.copyWith(color: color),
                maxLines: 1,
                overflow: .ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Red outline button for destructive actions.
///
/// Figma: h48, radius 12, border 1px #FF4B26, label DM Sans Medium 16 #FF4B26.
/// Used on: Settings ("Log out"), Delete Account ("Delete Account").
class AppDangerButton extends StatelessWidget {
  const AppDangerButton({
    super.key,
    required this.label,
    this.onSimplePressed,
    this.onAsyncPressed,
    this.onValidate,
    this.icon,
    this.width = double.infinity,
  });

  final String label;
  final VoidCallback? onSimplePressed;
  final Future<void> Function()? onAsyncPressed;
  final bool Function()? onValidate;
  final Widget? icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AppOutlineButton(
      label: label,
      onSimplePressed: onSimplePressed,
      onAsyncPressed: onAsyncPressed,
      onValidate: onValidate,
      icon: icon,
      width: width,
      height: 48,
      radius: 12,
      color: AppColors.danger,
    );
  }
}

/// Square or circular icon button.
///
/// Default (square): 40×40, radius 8, fill #C29266, white icon 24.
///   Used on: Home "Create New Job" card arrow.
/// [AppIconButton.circle]: 36×36 circle, fill #ECDDD0, dark icon 20.
///   Used on: Home header notification button.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onSimplePressed,
    this.onAsyncPressed,
    this.onValidate,
    this.size = 40,
    this.iconSize = 24,
    this.radius = 8,
    this.backgroundColor = AppColors.primary,
    this.iconColor = AppColors.onPrimary,
  });

  const AppIconButton.circle({
    super.key,
    required this.icon,
    this.onSimplePressed,
    this.onAsyncPressed,
    this.onValidate,
    this.size = 36,
    this.iconSize = 20,
    this.backgroundColor = AppColors.surfaceTag,
    this.iconColor = AppColors.textDark,
  }) : radius = size / 2;

  final IconData icon;
  final VoidCallback? onSimplePressed;
  final Future<void> Function()? onAsyncPressed;
  final bool Function()? onValidate;
  final double size;
  final double iconSize;
  final double radius;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return _AnimatedActionSurface(
      width: size,
      height: size,
      idleRadius: radius,
      squareRadius: radius,
      fillColor: backgroundColor,
      markerColor: iconColor,
      markerSizeFactor: iconSize / size,
      onSimplePressed: onSimplePressed,
      onAsyncPressed: onAsyncPressed,
      onValidate: onValidate,
      content: Icon(icon, size: iconSize, color: iconColor),
    );
  }
}

/// Floating action button.
///
/// Figma: 56×56, radius 12, fill #C29266, 2px border #F9F4F0, white icon 32,
/// brown shadow (0 10 15 -3 and 0 4 6 -4 at 20%).
/// Used on: Home, All Jobs, Catalog, Catalog Details, Catalog Add.
/// Pass it to `AppScaffold(floatingActionButton: ...)`.
class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    this.onSimplePressed,
    this.onAsyncPressed,
    this.onValidate,
    this.icon = Icons.add,
  });

  final VoidCallback? onSimplePressed;
  final Future<void> Function()? onAsyncPressed;
  final bool Function()? onValidate;
  final IconData icon;

  static const _size = 56.0;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(51),
            offset: const Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: AppColors.primary.withAlpha(51),
            offset: const Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
          ),
        ],
        border: Border.all(color: AppColors.surfaceCream, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _AnimatedActionSurface(
          width: _size - 4,
          height: _size - 4,
          idleRadius: 10,
          squareRadius: 10,
          fillColor: AppColors.primary,
          markerColor: AppColors.onPrimary,
          markerSizeFactor: 24 / (_size - 4),
          onSimplePressed: onSimplePressed,
          onAsyncPressed: onAsyncPressed,
          onValidate: onValidate,
          content: Icon(icon, size: 32, color: AppColors.onPrimary),
        ),
      ),
    );
  }
}
