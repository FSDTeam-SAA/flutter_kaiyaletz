import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/common/widgets/widgets.dart';
import 'package:flutter_kaiyaletz/core/theme/app_colors.dart';
import 'package:flutter_kaiyaletz/core/theme/app_text_styles.dart';
import 'package:flutter_kaiyaletz/core/utils/gap.dart';
import 'package:flutter_kaiyaletz/core/utils/navigation.dart';
import 'package:flutter_kaiyaletz/features/job/screens/select_job_screen.dart';

import '../model/catalog_model.dart';
import 'image_view.dart';

class CatalogDetailsScreen extends StatelessWidget {
  const CatalogDetailsScreen({super.key, required this.item});

  final CatalogModel item;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: AppHeader(title: item.name),
      ),
      padding: .zero,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverToBoxAdapter(
              child: _ImageCarousel(images: item.images),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(item.sku, style: AppTextStyles.caption),
                            const Gap(h: 4),
                            Text(item.name, style: AppTextStyles.h2),
                          ],
                        ),
                      ),
                      Text(
                        '\$${item.price.toStringAsFixed(item.price % 1 == 0 ? 0 : 2)}',
                        style: AppTextStyles.priceLarge,
                      ),
                    ],
                  ),
                  const Gap(h: 4),
                  Text(
                    '${item.finish} finish',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const Gap(h: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _MeasurementBox(
                          label: 'Width',
                          value: '${item.width.toStringAsFixed(0)}mm',
                        ),
                      ),
                      const Gap(w: 8),
                      Expanded(
                        child: _MeasurementBox(
                          label: 'Height',
                          value: '${item.height.toStringAsFixed(0)}mm',
                        ),
                      ),
                      const Gap(w: 8),
                      Expanded(
                        child: _MeasurementBox(
                          label: 'Depth',
                          value: '${item.depth.toStringAsFixed(0)}mm',
                        ),
                      ),
                    ],
                  ),
                  if (item.description case final description?
                      when description.isNotEmpty) ...[
                    const Gap(h: 24),
                    Text('Description', style: AppTextStyles.listTitle),
                    const Gap(h: 8),
                    Text(description, style: AppTextStyles.paragraph),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomBar: BottomActionBar(
        label: "Add to Project",
        onSimplePressed: () {
          AppNav.to(
            SelectJobScreen(item: item),
            transition: .downToUp,
            duration: Duration(milliseconds: 400),
          );
        },
      ),
    );
  }
}

/// Product photo carousel with page-dot indicator.
///
/// Figma: 16:9-ish hero image, radius 12, dot indicator centered below.
class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel({required this.images});

  final List<String> images;

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: images.isEmpty
                ? const _ImagePlaceholder()
                : PageView.builder(
                    controller: _controller,
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => AppNav.to(
                        ImageViewScreen(images: images, initialIndex: i),
                        transition: .fade,
                      ),
                      child: Image.network(images[i], fit: .cover),
                    ),
                  ),
          ),
        ),
        if (images.length > 1) ...[
          const Gap(h: 10),
          Row(
            mainAxisAlignment: .center,
            children: [
              for (var i = 0; i < images.length; i++) ...[
                if (i > 0) const Gap(w: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == _page ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? AppColors.primary
                        : AppColors.surfaceTag,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
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
          size: 48,
          color: AppColors.textPlaceholder,
        ),
      ),
    );
  }
}

/// Width / Height / Depth stat box.
///
/// Figma: fill #F9F4F0, border 1px #ECDDD0, radius 8, centered label above
/// value.
class _MeasurementBox extends StatelessWidget {
  const _MeasurementBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Gap(h: 4),
          Text(value, style: AppTextStyles.inputLabel),
        ],
      ),
    );
  }
}
