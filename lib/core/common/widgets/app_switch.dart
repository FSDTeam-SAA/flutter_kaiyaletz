import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Custom two-state toggle for Notification settings rows.
///
/// Figma: track 51×31, fully rounded, thumb 27×27 white circle inset 2px.
///   ON:  track fill #C29266 (primary), thumb sits right
///   OFF: track fill #292D32 (dark charcoal — NOT grey), thumb sits left
/// This does not match Material's or Cupertino's default switch colors
/// (both default to a light-grey off-state), so it's a standalone widget
/// rather than a themed Switch/CupertinoSwitch.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  static const _trackWidth = 51.0;
  static const _trackHeight = 31.0;
  static const _thumbSize = 27.0;
  static const _inset = 2.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: GestureDetector(
        behavior: .opaque,
        onTap: enabled ? () => onChanged(!value) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: _trackWidth,
          height: _trackHeight,
          padding: const EdgeInsets.all(_inset),
          decoration: BoxDecoration(
            color: value ? AppColors.primary : AppColors.textProfileName,
            borderRadius: BorderRadius.circular(_trackHeight / 2),
          ),
          child: Align(
            alignment: value ? .centerRight : .centerLeft,
            child: Container(
              width: _thumbSize,
              height: _thumbSize,
              decoration: const BoxDecoration(
                color: AppColors.onPrimary,
                shape: .circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
