import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Label / value line.
///
/// Figma: label DM Sans Regular 14 #333333, value DM Sans Medium 16 #000.
/// Used on: Estimate, Proposal.
class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key, required this.label, required this.value});

  /// e.g. "Sub Total", "Tax(10%)", "Total"
  final String label;

  /// e.g. "$875"
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLabel,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: AppTextStyles.inputLabel),
      ],
    );
  }
}

/// Grey card with totals.
///
/// Figma: fill #E6E6E6, radius 8, padding 12, gap 8,
/// divider 1px #D7D7D7 above the last row (Total).
/// Used on: Estimate, Proposal.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.rows,
    this.dividerBeforeLast = true,
  });

  final List<SummaryRow> rows;
  final bool dividerBeforeLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            if (dividerBeforeLast &&
                rows.length > 1 &&
                i == rows.length - 1) ...[
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.dividerGrey,
              ),
              const SizedBox(height: 8),
            ],
            rows[i],
          ],
        ],
      ),
    );
  }
}
