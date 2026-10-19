import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Tap-to-open date field.
///
/// Figma: label DM Sans Medium 16 #000 → 8px gap → field h51,
/// border 1px #ECDDD0, radius 8, padding 16, placeholder "--/--/--"
/// #979797, calendar icon 20 #7A7972 trailing.
/// Used on: Create Job. Uses Flutter's built-in showDatePicker, themed
/// to match the app via AppTheme.datePickerTheme — no custom calendar
/// grid needed.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    this.label,
    this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.hint = '--/--/--',
  });

  final String? label;

  /// Currently selected date, or null to show [hint].
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String hint;

  String _format(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.year}';

  Future<void> _openPicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(now.year - 5),
      lastDate: lastDate ?? DateTime(now.year + 5),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.inputLabel),
          const SizedBox(height: 8),
        ],
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openPicker(context),
            child: Container(
              height: 51,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value != null ? _format(value!) : hint,
                      style: AppTextStyles.placeholder.copyWith(
                        color: value != null
                            ? AppColors.textPrimary
                            : AppColors.textPlaceholder,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.textMeta,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
