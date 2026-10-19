import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// One product line in the [EstimateTable]. All values are display
/// strings, already formatted (e.g. "$275").
class EstimateLine {
  const EstimateLine({
    required this.name,
    required this.details,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  final String name;

  /// e.g. "BC-900-W · 900W × 580D mm"
  final String details;
  final int quantity;
  final String unitPrice;
  final String total;
}

/// Read-only product table (Product / Qty / Unit / Total).
///
/// Figma (Estimate): radius 8, 1px border, header row 38 high on a tan
/// fill, body rows 54 high, padding 12, column gap 8, Qty/Unit/Total
/// columns 51 wide. Text is DM Sans: header Regular 12 #7A7972; name
/// Medium 12 #000 over details Regular 10 #545454; qty Regular 12;
/// unit Regular 12 #545454; total Medium 12 #000.
/// Used on: Estimate.
class EstimateTable extends StatelessWidget {
  const EstimateTable({super.key, required this.lines});

  final List<EstimateLine> lines;

  static const double _colWidth = 51;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceCream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _HeaderRow(),
          for (final line in lines) ...[
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            _LineRow(line: line),
          ],
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.bodySmall; // Regular 12 #7A7972

    return Container(
      height: 38,
      color: AppColors.surfaceTag,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(child: Text('Product', style: style)),
          const SizedBox(width: 8),
          SizedBox(
            width: EstimateTable._colWidth,
            child: Text('Qty', style: style, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: EstimateTable._colWidth,
            child: Text('Unit', style: style, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: EstimateTable._colWidth,
            child: Text('Total', style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line});

  final EstimateLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  line.details,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: EstimateTable._colWidth,
            child: Text(
              '${line.quantity}',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: EstimateTable._colWidth,
            child: Text(
              line.unitPrice,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: EstimateTable._colWidth,
            child: Text(
              line.total,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
