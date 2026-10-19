import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'status_chip.dart';
import 'step_progress_bar.dart';

enum JobCardStyle {
  /// Standalone card: fill #F9F4F0, border #ECDDD0, radius 12. (All Jobs)
  card,

  /// Plain row for use inside [JobListCard]. (Home "Recent Jobs")
  row,
}

/// Job summary.
///
/// Figma (353×87, padding 12, gap 8):
///   name     DM Sans SemiBold 18 #1A2332
///   address  DM Sans Regular 14 #7A7972
///   StatusChip on the right
///   MiniStepProgress + step label + date (DM Sans Regular 10 #7A7972)
/// Used on: Home, All Jobs, Catalog Add.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.customerName,
    required this.address,
    required this.status,
    required this.currentStep,
    required this.stepLabel,
    required this.date,
    this.totalSteps = 7,
    this.onTap,
    this.style = .card,
  });

  final String customerName;
  final String address;
  final JobStatus status;

  /// Number of completed steps for the mini progress bar.
  final int currentStep;
  final int totalSteps;

  /// e.g. "Step 5: AI Layout"
  final String stepLabel;

  /// e.g. "2026-08-14"
  final String date;
  final VoidCallback? onTap;
  final JobCardStyle style;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      customerName,
                      style: AppTextStyles.listTitle,
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              MiniStepProgress(
                currentStep: currentStep,
                totalSteps: totalSteps,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  stepLabel,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(date, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );

    if (style == .row) {
      return InkWell(onTap: onTap, child: content);
    }

    return Material(
      color: AppColors.surfaceCream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: .antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}

/// White card grouping several jobs with dividers.
///
/// Figma: fill #FFFFFF, border 1px #DDD9D0, radius 12,
/// dividers 1px #ECDDD0.
/// Used on: Home ("Recent Jobs").
///
/// Children should be `JobCard(style: .row, ...)`.
class JobListCard extends StatelessWidget {
  const JobListCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderCard),
      ),
      clipBehavior: .antiAlias,
      child: Column(
        mainAxisSize: .min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppColors.border),
            children[i],
          ],
        ],
      ),
    );
  }
}
