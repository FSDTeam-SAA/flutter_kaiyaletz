import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Three-tile stat row shown under Home's "Overview" heading
/// (Active Jobs / Proposals / This Month).
class OverviewStats extends StatelessWidget {
  const OverviewStats({
    super.key,
    required this.activeJobs,
    required this.proposals,
    required this.thisMonthRevenue,
  });

  final int activeJobs;
  final int proposals;
  final num thisMonthRevenue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.work_outline,
            label: 'Active Jobs',
            value: '$activeJobs',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.description_outlined,
            label: 'Proposals',
            value: '$proposals',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.attach_money,
            label: 'This Month',
            value: _formatRevenue(thisMonthRevenue),
          ),
        ),
      ],
    );
  }

  static String _formatRevenue(num value) {
    if (value >= 1000) {
      final thousands = value / 1000;
      final rounded = thousands == thousands.roundToDouble()
          ? thousands.toStringAsFixed(0)
          : thousands.toStringAsFixed(1);
      return '\$${rounded}k';
    }
    return '\$${value.toStringAsFixed(0)}';
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.statValue),
        ],
      ),
    );
  }
}
