import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Selectable product row with an optional quantity stepper.
///
/// Figma (Select Product): radius 8, padding 12, gap 8, border 1px
/// #ECDDD0. Unselected: fill #F6F6F6, height 61. Selected: fill
/// #F0DCC4, height 72 (price on top, [QuantityStepper] under it).
/// Left: 24px check circle. Middle: name (DM Sans Medium 16 #000) over
/// "SKU · dimensions" (Regular 14 #979797). Right: price (Medium 16).
/// Used on: Select Product.
class ProductSelectTile extends StatelessWidget {
  const ProductSelectTile({
    super.key,
    required this.name,
    required this.details,
    required this.price,
    required this.isSelected,
    required this.onToggle,
    this.quantity = 1,
    this.onQuantityChanged,
  });

  final String name;

  /// e.g. "BC-900-W · 900W × 580D mm"
  final String details;

  /// Already formatted, e.g. "$275"
  final String price;
  final bool isSelected;
  final VoidCallback onToggle;

  /// Only shown while [isSelected] and [onQuantityChanged] is set.
  final int quantity;
  final ValueChanged<int>? onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final showStepper = isSelected && onQuantityChanged != null;

    return Material(
      color: isSelected
          ? AppColors.surfaceOptionSelected
          : AppColors.surfaceOption,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _CheckCircle(isSelected: isSelected),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.inputLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPlaceholder,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(price, style: AppTextStyles.inputLabel),
                  if (showStepper) ...[
                    const SizedBox(height: 8),
                    QuantityStepper(
                      quantity: quantity,
                      onChanged: onQuantityChanged!,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.brown300,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 14, color: AppColors.primary)
          : null,
    );
  }
}

/// Small "− 1 +" stepper.
///
/// Figma: 53×21, white fill, radius 6, padding 4/2, gap 4, 16px
/// minus/plus icons around the number.
/// Note: the 16px icons are small touch targets (that's the design);
/// consider enlarging them if testers miss taps.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepIcon(
            icon: Icons.indeterminate_check_box_outlined,
            enabled: quantity > min,
            onTap: () => onChanged(quantity - 1),
          ),
          const SizedBox(width: 4),
          Text(
            '$quantity',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          _StepIcon(
            icon: Icons.add_box_outlined,
            enabled: quantity < max,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Icon(
        icon,
        size: 16,
        color: enabled ? AppColors.textDark : AppColors.textDisabled,
      ),
    );
  }
}
