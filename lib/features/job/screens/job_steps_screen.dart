import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/utils/date_formatter.dart';
import 'package:flutter_kaiyaletz/core/utils/gap.dart';
import 'package:flutter_kaiyaletz/core/utils/navigation.dart';
import 'package:flutter_kaiyaletz/features/measure/screens/ar_measure_screen.dart';
import 'package:flutter_kaiyaletz/features/catalog/controller/catalog_cotroller.dart';
import 'package:flutter_kaiyaletz/features/job/controller/job_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/widgets/app_text_field.dart';
import '../../../core/common/widgets/summary_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../catalog/model/catalog_model.dart';
import '../widgets/estimate_table.dart';
import '../widgets/info_row.dart';
import '../widgets/option_cart.dart';
import '../widgets/product_seletc_title.dart';

/// Placeholder body for a job step. Replace each with the real UI later.
class _StepPlaceholder extends StatelessWidget {
  const _StepPlaceholder(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(child: Text(name)),
    );
  }
}

class JobDetailsStep extends ConsumerWidget {
  const JobDetailsStep({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobDetails = ref.watch(jobProvider.select((s) => s.singleJob));

    final String date = formatDate(jobDetails?.date ?? DateTime.now());

    return Column(
      children: [
        Gap(h: 16),
        InfoRow(label: 'Date', value: date),
        InfoRow(
          label: 'Customer Name',
          value: jobDetails?.customerName ?? "No Name",
        ),
        InfoRow(
          label: 'Property Address',
          value: jobDetails?.propertyAddress ?? "No Address",
        ),
        InfoRow(
          label: 'Phone Number',
          value: jobDetails?.phoneNumber ?? "No Phone",
        ),
        InfoRow(
          label: 'Email Address',
          value: jobDetails?.emailAddress ?? "No Email",
        ),
        Gap(h: 12),
        DashedNotesBox(
          label: 'Projects Notes',
          text:
              jobDetails?.notes ??
              "Renovation — existing layout to be retained if possible",
        ),
      ],
    );
  }
}

class RoomCaptureStep extends StatelessWidget {
  const RoomCaptureStep({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(h: 16),
        Text(
          'How would you like to capture the kitchen space?',
          style: AppTextStyles.bodyMedium,
        ),
        Gap(h: 16),
        OptionCard(
          icon: Icons.photo_camera_outlined,
          title: 'Room Scan',
          description: 'Use camera to automatically detect room dimensions',
          badgeLabel: 'AI',
          onTap: () => AppNav.to(const ArMeasureScreen()),
        ),
      ],
    );
  }
}

class MeasurementsStep extends StatelessWidget {
  const MeasurementsStep({super.key});
  @override
  Widget build(BuildContext context) => const _StepPlaceholder("Measurements");
}

class SelectProductStep extends ConsumerWidget {
  const SelectProductStep({super.key});

  static const _sections = [
    (ProductCategory.base, 'Base Cabinets'),
    (ProductCategory.wall, 'Wall Cabinets'),
    (ProductCategory.tall, 'Tall Cabinets'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(jobProvider.select((s) => s.selectedQty));
    final catalogs = ref.watch(catalogProvider.select((s) => s.catalogs)) ?? [];
    final isLoading = ref.watch(catalogProvider.select((s) => s.isLoading));
    final notifier = ref.read(jobProvider.notifier);

    Widget tile(CatalogModel p) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ProductSelectTile(
        name: p.name,
        details: '${p.sku} · ${p.dimensions}',
        price: '\$${p.price.toStringAsFixed(0)}',
        isSelected: selected.containsKey(p.id),
        quantity: selected[p.id] ?? 1,
        onToggle: () => notifier.toggleProduct(p.id),
        onQuantityChanged: (q) => notifier.setQuantity(p.id, q),
      ),
    );

    final selectedItems = catalogs.where((p) => selected.containsKey(p.id));
    final totalCount = selectedItems.fold<int>(
      0,
      (n, p) => n + selected[p.id]!,
    );
    final totalCost = selectedItems.fold<double>(
      0,
      (sum, p) => sum + p.price * selected[p.id]!,
    );

    final added =
        ref.watch(jobProvider.select((s) => s.singleJob?.selectedProducts)) ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(h: 16),
        Text(
          'Products',
          style: AppTextStyles.statValue.copyWith(fontWeight: FontWeight.w500),
        ),
        Gap(h: 8),
        Text(
          'Select products to include in this project. Only selected items will appear in the layout.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Gap(h: 16),
        if (added.isNotEmpty) ...[
          Text('Added Products', style: AppTextStyles.inputLabel),
          Gap(h: 12),
          ...added.map((i) => tile(i.productId)),
        ],
        Gap(h: 16),
        if (isLoading && catalogs.isEmpty)
          const Center(child: CircularProgressIndicator()),
        for (final (category, title) in _sections) ...[
          Text(title, style: AppTextStyles.inputLabel),
          Gap(h: 12),
          ...catalogs.where((p) => p.category == category).map(tile),
          Gap(h: 4),
        ],
        Text('Product Selected: $totalCount', style: AppTextStyles.bodyMedium),
        Text(
          'Total Cost: \$${totalCost.toStringAsFixed(0)}',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

class AiLayoutStep extends StatelessWidget {
  const AiLayoutStep({super.key});
  @override
  Widget build(BuildContext context) => const _StepPlaceholder("AI Layout");
}

class DesignStep extends StatelessWidget {
  const DesignStep({super.key});
  @override
  Widget build(BuildContext context) => const _StepPlaceholder("Design");
}

class EstimateStep extends ConsumerStatefulWidget {
  const EstimateStep({super.key});

  @override
  ConsumerState<EstimateStep> createState() => _EstimateStepState();
}

class _EstimateStepState extends ConsumerState<EstimateStep> {
  final _installation = TextEditingController();
  final _delivery = TextEditingController();

  @override
  void dispose() {
    _installation.dispose();
    _delivery.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(r'$', '').trim()) ?? 0;

  /// 875 -> "$875", 87.5 -> "$87.5"
  String _money(double v) => '\$${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}';

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(jobProvider.select((s) => s.selectedQty));
    final taxRate =
        ref.watch(jobProvider.select((s) => s.singleJob?.estimate?.taxRate)) ??
        10;
    final catalogs = ref.watch(catalogProvider.select((s) => s.catalogs)) ?? [];

    final items = catalogs.where((p) => selected.containsKey(p.id)).toList();

    final lines = [
      for (final p in items)
        EstimateLine(
          name: p.name,
          details: '${p.sku} · ${p.dimensions}',
          quantity: selected[p.id] ?? 1,
          unitPrice: _money(p.price),
          total: _money(p.price * (selected[p.id] ?? 1)),
        ),
    ];

    final productTotal = items.fold<double>(
      0,
      (sum, p) => sum + p.price * (selected[p.id] ?? 1),
    );
    final subTotal = productTotal + _parse(_installation) + _parse(_delivery);
    final tax = subTotal * taxRate / 100;
    final total = subTotal + tax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(h: 16),
        EstimateTable(lines: lines),
        Gap(h: 16),
        AppTextField(
          label: 'Installation Charge',
          hint: '\$100',
          controller: _installation,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        Gap(h: 12),
        AppTextField(
          label: 'Delivery Charge',
          hint: '\$100',
          controller: _delivery,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        Gap(h: 16),
        SummaryCard(
          rows: [
            SummaryRow(label: 'Sub Total', value: _money(subTotal)),
            SummaryRow(
              label:
                  'Tax(${taxRate.toStringAsFixed(taxRate % 1 == 0 ? 0 : 1)}%)',
              value: _money(tax),
            ),
            SummaryRow(label: 'Total', value: _money(total)),
          ],
        ),
      ],
    );
  }
}

class ProposalStep extends StatelessWidget {
  const ProposalStep({super.key});
  @override
  Widget build(BuildContext context) => const _StepPlaceholder("Proposal");
}

/// Index 0 = step 1. Same order as [jobStepNames].
const List<Widget> jobStepWidgets = [
  JobDetailsStep(),
  RoomCaptureStep(),
  MeasurementsStep(),
  SelectProductStep(),
  AiLayoutStep(),
  DesignStep(),
  EstimateStep(),
  ProposalStep(),
];
