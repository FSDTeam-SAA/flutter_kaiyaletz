import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/common/widgets/filter_chips.dart';

/// Catalog product tile.
///
/// Figma (170×196, fill #F9F4F0, border 1px #ECDDD0, radius 8):
///   image area 110 high
///   padding 8:
///     SKU         DM Sans Regular 10 #7A7972
///     name        DM Sans SemiBold 14 #1A2332
///     dimensions  DM Sans Regular 12 #7A7972
///     price       DM Sans SemiBold 14 #C29266  +  CategoryTag
/// Used on: Catalog, Catalog Details, Catalog Add (29 copies).
///
/// In a grid use:
/// `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,
///  mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 196)`
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.sku,
    required this.name,
    required this.dimensions,
    required this.price,
    required this.category,
    this.image,
    this.onTap,
    this.isSelected = false,
    this.imageHeight = 110,
  });

  /// e.g. "BC-900-W"
  final String sku;

  /// e.g. "Base Cabinet 900"
  final String name;

  /// e.g. "900W × 580D mm"
  final String dimensions;

  /// Already formatted, e.g. "$420"
  final String price;

  /// e.g. "Base"
  final String category;

  /// e.g. `Image.network(url, fit: .cover)`. Shows a placeholder if null.
  final Widget? image;
  final VoidCallback? onTap;

  /// Highlights the border in brown (e.g. selected product in Catalog Add).
  final bool isSelected;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.borderFocus : AppColors.border,
        ),
      ),
      clipBehavior: .antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            SizedBox(
              height: imageHeight,
              child: image ?? const _ImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    sku,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: AppTextStyles.productName,
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dimensions,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          price,
                          style: AppTextStyles.productPrice,
                          maxLines: 1,
                          overflow: .ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      CategoryTag(label: category),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceImage,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: AppColors.textPlaceholder,
        ),
      ),
    );
  }
}
