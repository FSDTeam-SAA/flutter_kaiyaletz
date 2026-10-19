import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'app_buttons.dart';

/// Fixed bottom bar holding the flow's main action.
///
/// Figma ("Navigation"): 393×75, fill #F9F4F0, top border 1px #ECDDD0,
/// padding 20 horizontal / 12 vertical.
/// Used on: Create Job, Job Details, Room Capture, Measurements,
/// Continue to Room Captured (×2), Ai Layout, Estimate, Proposal.
///
/// Pass it to `AppScaffold(bottomBar: ...)`.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    this.label,
    this.onSimplePressed,
    this.onAsyncPressed,
    this.child,
  }) : assert(
         label != null || child != null,
         'Provide either a label or a child',
       );

  /// Shortcut: builds an [AppPrimaryButton] with this label.
  final String? label;

  /// Sync action (navigation, local state). Ignored while loading.
  final VoidCallback? onSimplePressed;

  /// Async action (API call). Button manages its own loading spinner.
  final Future<void> Function()? onAsyncPressed;

  /// Custom content (e.g. two buttons in a Row). Overrides [label].
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCream,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child:
              child ??
              AppPrimaryButton(
                label: label!,
                onSimplePressed: onSimplePressed,
                onAsyncPressed: onAsyncPressed,
              ),
        ),
      ),
    );
  }
}
