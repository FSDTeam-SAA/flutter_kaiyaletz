import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/utils/app_snackbar.dart';
import 'package:flutter_kaiyaletz/core/utils/date_formatter.dart';
import 'package:flutter_kaiyaletz/core/utils/gap.dart';
import 'package:flutter_kaiyaletz/core/utils/navigation.dart';
import 'package:flutter_kaiyaletz/features/measure/model/measure_state.dart';
import 'package:flutter_kaiyaletz/features/measure/model/room_scan.dart';
import 'package:flutter_kaiyaletz/features/measure/model/room_spec.dart';
import 'package:flutter_kaiyaletz/features/measure/screens/ar_measure_screen.dart';
import 'package:flutter_kaiyaletz/features/measure/screens/room_scan_screen.dart';
import 'package:flutter_kaiyaletz/features/measure/widgets/room_spec_editor.dart';
import 'package:flutter_kaiyaletz/features/catalog/controller/catalog_cotroller.dart';
import 'package:flutter_kaiyaletz/features/job/controller/job_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/widgets/app_text_field.dart';
import '../../../core/common/widgets/summary_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../catalog/model/catalog_model.dart';
import '../widgets/elevation_view.dart';
import '../widgets/estimate_table.dart';
import '../widgets/proposal_view.dart';
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

class RoomCaptureStep extends ConsumerWidget {
  const RoomCaptureStep({super.key});

  /// Opens the AR camera and turns the pinned floor corners into walls.
  Future<void> _scan(WidgetRef ref) async {
    final result = await AppNav.to<MeasureState>(const ArMeasureScreen());
    if (result == null) return;
    if (result.points.length < 2) {
      AppSnackbar.warning('Pin at least two corners to measure a wall');
      return;
    }
    if (result.points.length > 4) {
      AppSnackbar.warning('Only the first 3 walls were used');
    }
    ref
        .read(jobProvider.notifier)
        .setRoomDraft(RoomSpec.fromCornerPoints(result.points));
  }

  /// Scans the room with RoomPlan; the user picks the kitchen walls.
  Future<void> _scanLidar(WidgetRef ref) async {
    final result = await AppNav.to<RoomScanResult>(const RoomScanScreen());
    if (result == null) return;
    ref.read(jobProvider.notifier).setRoomDraft(result.room);
    if (result.notes.isNotEmpty) AppSnackbar.warning(result.notes.join('\n'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(jobProvider.select((s) => s.roomDraft));
    final lidar = ref.watch(roomScanSupportedProvider).value ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(h: 16),
        Text(
          'How would you like to capture the kitchen space?',
          style: AppTextStyles.bodyMedium,
        ),
        Gap(h: 16),
        if (lidar) ...[
          OptionCard(
            icon: Icons.view_in_ar_outlined,
            title: 'LiDAR Room Scan',
            description:
                'Walls, doors, windows, sink and hob are found automatically',
            badgeLabel: 'LiDAR',
            isSelected: room?.source == .lidarScan,
            onTap: () => _scanLidar(ref),
          ),
          Gap(h: 12),
        ],
        OptionCard(
          icon: Icons.photo_camera_outlined,
          title: 'Room Scan',
          description: 'Pin each kitchen corner at floor level with the camera',
          badgeLabel: 'AR',
          isSelected:
              room != null && room.isEstimate && room.source != .lidarScan,
          onTap: () => _scan(ref),
        ),
        Gap(h: 12),
        OptionCard(
          icon: Icons.edit_outlined,
          title: 'Enter Manually',
          description: 'Type in wall lengths measured with a tape',
          isSelected: room?.source == .manual,
          onTap: () {
            if (room?.source == .manual) return;
            ref.read(jobProvider.notifier).setRoomDraft(RoomSpec.manual());
          },
        ),
        if (room != null) ...[
          Gap(h: 16),
          Text(
            [
              for (var i = 0; i < room.walls.length; i++)
                '${wallName(i)}: ${room.walls[i].lengthMm} mm',
            ].join(' · '),
            style: AppTextStyles.bodySmall,
          ),
        ],
      ],
    );
  }
}

class MeasurementsStep extends ConsumerWidget {
  const MeasurementsStep({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(jobProvider.select((s) => s.roomDraft));
    if (room == null) {
      return const _StepPlaceholder('Capture the room in the previous step');
    }
    return RoomSpecEditor(
      room: room,
      onChanged: ref.read(jobProvider.notifier).setRoomDraft,
    );
  }
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

    // Fit check against the measured walls. Tall units take floor and wall
    // space, so they count in both.
    final room = ref.watch(jobProvider.select((s) => s.roomDraft));
    int usedMm(List<ProductCategory> categories) => selectedItems
        .where((p) => categories.contains(p.category))
        .fold(0, (mm, p) => mm + p.width.round() * selected[p.id]!);

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
        if (room != null) ...[
          Gap(h: 12),
          _FitRow(
            label: 'Floor units',
            usedMm: usedMm([.base, .tall]),
            capacityMm: room.runCapacityMm(),
          ),
          Gap(h: 8),
          _FitRow(
            label: 'Wall units',
            usedMm: usedMm([.wall, .tall]),
            capacityMm: room.runCapacityMm(wallUnits: true),
          ),
        ],
      ],
    );
  }
}

/// "Floor units: 2750 / 2700 mm" with a bar that turns red when over.
class _FitRow extends StatelessWidget {
  const _FitRow({
    required this.label,
    required this.usedMm,
    required this.capacityMm,
  });

  final String label;
  final int usedMm;
  final int capacityMm;

  @override
  Widget build(BuildContext context) {
    final over = usedMm > capacityMm;
    final color = over ? AppColors.error : AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$label: $usedMm / $capacityMm mm${over ? ' · too long for the walls' : ''}',
          style: AppTextStyles.bodySmall.copyWith(color: over ? color : null),
        ),
        Gap(h: 4),
        LinearProgressIndicator(
          value: capacityMm == 0 ? 1 : (usedMm / capacityMm).clamp(0, 1),
          color: color,
          backgroundColor: AppColors.progressEmpty,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }
}

class AiLayoutStep extends ConsumerStatefulWidget {
  const AiLayoutStep({super.key});

  @override
  ConsumerState<AiLayoutStep> createState() => _AiLayoutStepState();
}

class _AiLayoutStepState extends ConsumerState<AiLayoutStep> {
  @override
  void initState() {
    super.initState();
    // Build the layout on arrival unless one is already saved.
    Future.microtask(() {
      if (ref.read(jobProvider).layout == null) {
        ref.read(jobProvider.notifier).generateLayout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(jobProvider.select((s) => s.layout));
    final busy = ref.watch(jobProvider.select((s) => s.isGeneratingLayout));
    final notifier = ref.read(jobProvider.notifier);

    final wallCount = layout?.items.map((i) => i.wallId).toSet().length ?? 0;
    final status = busy
        ? 'Placing your cabinets…'
        : layout == null
        ? 'Layout not generated yet'
        : '${layout.items.length} cabinets placed on $wallCount '
              '${wallCount == 1 ? 'wall' : 'walls'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(h: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCream,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                size: 32,
                color: AppColors.primary,
              ),
              Gap(h: 8),
              Text('Layout Engine', style: AppTextStyles.listTitle),
              Gap(h: 4),
              Text(status, style: AppTextStyles.bodySmall),
              if (!busy && layout != null) ...[
                Gap(h: 4),
                Text(
                  layout.aiModel != null
                      ? 'Planned by AI (${layout.aiModel}), checked by the layout rules'
                      : 'Planned by the layout rules (AI unavailable)',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
              if (busy) ...[
                Gap(h: 12),
                const LinearProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.progressEmpty,
                ),
              ],
            ],
          ),
        ),
        if (layout != null) ...[
          Gap(h: 16),
          for (final check in layout.checks)
            _ResultRow(
              icon: check.passed ? Icons.check_circle : Icons.cancel_outlined,
              color: check.passed ? AppColors.success : AppColors.error,
              text: check.label,
            ),
          for (final warning in layout.warnings)
            _ResultRow(
              icon: Icons.warning_amber_rounded,
              color: AppColors.primaryDark,
              text: warning,
            ),
        ],
        if (!busy) ...[
          Gap(h: 8),
          Align(
            child: TextButton.icon(
              onPressed: notifier.generateLayout,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(layout == null ? 'Generate layout' : 'Regenerate'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          Gap(w: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

class DesignStep extends ConsumerStatefulWidget {
  const DesignStep({super.key});

  @override
  ConsumerState<DesignStep> createState() => _DesignStepState();
}

class _DesignStepState extends ConsumerState<DesignStep> {
  /// Index into the layout's items.
  int? _selected;

  void _move(int dir) {
    final moved = ref.read(jobProvider.notifier).moveItem(_selected!, dir);
    if (!moved) AppSnackbar.warning("It can't move that way");
  }

  @override
  Widget build(BuildContext context) {
    final room = ref.watch(jobProvider.select((s) => s.roomDraft));
    final layout = ref.watch(jobProvider.select((s) => s.layout));
    if (room == null || layout == null) {
      return const _StepPlaceholder('Generate the layout in the previous step');
    }
    final selected = _selected != null && _selected! < layout.items.length
        ? layout.items[_selected!]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(h: 16),
        Text('Layout A — Recommended', style: AppTextStyles.listTitle),
        Gap(h: 4),
        Text(
          'Tap a cabinet to move it along its wall.',
          style: AppTextStyles.bodySmall,
        ),
        for (var w = 0; w < room.walls.length; w++) ...[
          Gap(h: 12),
          WallElevation(
            room: room,
            layout: layout,
            wallIndex: w,
            selected: _selected,
            onTapItem: (n) => setState(() => _selected = n),
          ),
        ],
        if (selected != null) ...[
          Gap(h: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCream,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Move left',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _move(-1),
                ),
                Expanded(
                  child: Text(
                    '${selected.name ?? selected.sku}\n'
                    '${selected.sku} · ${selected.widthMm} mm',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Move right',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _move(1),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class EstimateStep extends ConsumerStatefulWidget {
  const EstimateStep({super.key});

  @override
  ConsumerState<EstimateStep> createState() => _EstimateStepState();
}

class _EstimateStepState extends ConsumerState<EstimateStep> {
  // Start from the saved charges; edits go to the controller, which saves
  // them on Continue.
  late final _installation = TextEditingController(
    text: _initial(ref.read(jobProvider).installationCharge),
  );
  late final _delivery = TextEditingController(
    text: _initial(ref.read(jobProvider).deliveryCharge),
  );

  static String _initial(double v) =>
      v == 0 ? '' : v.toStringAsFixed(v % 1 == 0 ? 0 : 2);

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
          onChanged: (_) {
            ref
                .read(jobProvider.notifier)
                .setCharges(installation: _parse(_installation));
            setState(() {});
          },
        ),
        Gap(h: 12),
        AppTextField(
          label: 'Delivery Charge',
          hint: '\$100',
          controller: _delivery,
          keyboardType: TextInputType.number,
          onChanged: (_) {
            ref
                .read(jobProvider.notifier)
                .setCharges(delivery: _parse(_delivery));
            setState(() {});
          },
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

class ProposalStep extends ConsumerStatefulWidget {
  const ProposalStep({super.key});

  @override
  ConsumerState<ProposalStep> createState() => _ProposalStepState();
}

class _ProposalStepState extends ConsumerState<ProposalStep> {
  @override
  void initState() {
    super.initState();
    // The backend reuses its stored PDF when nothing changed.
    Future.microtask(ref.read(jobProvider.notifier).loadProposal);
  }

  @override
  Widget build(BuildContext context) {
    final proposal = ref.watch(jobProvider.select((s) => s.proposal));
    final loading = ref.watch(jobProvider.select((s) => s.isLoadingProposal));

    if (proposal == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: loading
              ? const CircularProgressIndicator()
              : TextButton.icon(
                  onPressed: ref.read(jobProvider.notifier).loadProposal,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Generate proposal'),
                ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ProposalCard(proposal: proposal),
    );
  }
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
