import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Full-width step indicator for the job flow.
///
/// Figma: segments 55×12, radius 99, gap 4,
/// done #C29266 / not done #D9D9D9.
/// Used on: Job Details, Room Capture, Measurements,
/// Continue to Room Captured, Ai Layout, Estimate, Proposal.
///
/// Note: the design shows 6, 7 and 8 segments on different screens.
/// Use one [totalSteps] value for the whole flow.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 8,
    this.height = 12,
    this.gap = 4,
    this.onStepTap,
  }) : assert(totalSteps > 0);

  /// Number of completed steps (0 = none, [totalSteps] = all).
  final int currentStep;
  final int totalSteps;
  final double height;
  final double gap;

  final ValueChanged<int>? onStepTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) return SizedBox(width: gap);
        final index = i ~/ 2;
        final step = index + 1;
        final canTap = onStepTap != null && step <= currentStep;
        return Expanded(
          child: GestureDetector(
            behavior: .opaque,
            onTap: canTap ? () => onStepTap!(step) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: height,
              decoration: BoxDecoration(
                color: index < currentStep
                    ? AppColors.primary
                    : AppColors.progressEmpty,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Small step indicator inside job cards.
///
/// Figma: 7 segments 16×6, radius 18, gap 2.
/// Used on: Home (Recent Jobs), All Jobs.
class MiniStepProgress extends StatelessWidget {
  const MiniStepProgress({
    super.key,
    required this.currentStep,
    this.totalSteps = 7,
  });

  /// Number of completed steps.
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) return const SizedBox(width: 2);
        final index = i ~/ 2;
        return Container(
          width: 16,
          height: 6,
          decoration: BoxDecoration(
            color: index < currentStep
                ? AppColors.primary
                : AppColors.progressEmpty,
            borderRadius: BorderRadius.circular(18),
          ),
        );
      }),
    );
  }
}
