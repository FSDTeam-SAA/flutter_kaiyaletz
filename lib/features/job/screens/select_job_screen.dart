import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/common/widgets/widgets.dart';
import 'package:flutter_kaiyaletz/core/theme/app_colors.dart';
import 'package:flutter_kaiyaletz/core/theme/app_text_styles.dart';
import 'package:flutter_kaiyaletz/core/utils/app_snackbar.dart';
import 'package:flutter_kaiyaletz/core/utils/gap.dart';
import 'package:flutter_kaiyaletz/core/utils/navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/model/catalog_model.dart';
import '../controller/job_controller.dart';

const _statusFilters = <String, JobStatus?>{
  'All': null,
  'New': .newJob,
  'In Progress': .inProgress,
  'Proposal Sent': .proposalSent,
  'Completed': .completed,
};

/// Lets the user pick which job a catalog [item] is added to.
class SelectJobScreen extends ConsumerStatefulWidget {
  const SelectJobScreen({super.key, required this.item});

  final CatalogModel item;

  @override
  ConsumerState<SelectJobScreen> createState() => _SelectJobScreenState();
}

class _SelectJobScreenState extends ConsumerState<SelectJobScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addToJob(String jobId) async {
    final added = await ref
        .read(jobProvider.notifier)
        .addProductToJob(jobId: jobId, productId: widget.item.id);

    if (!added) return;
    AppSnackbar.success('${widget.item.name} added to job');
    AppNav.back();
  }

  @override
  Widget build(BuildContext context) {
    final selectedStatus = ref.watch(jobProvider.select((s) => s.status));
    final selectedIndex = _statusFilters.values.toList().indexWhere(
      (status) => status?.apiValue == selectedStatus,
    );

    return AppScaffold(
      isLoading: ref.watch(jobProvider.select((s) => s.isJobLoading)),
      header: AppHeader(
        title: 'Add to Job',
        showBack: false,
        trailing: InkResponse(
          onTap: AppNav.back,
          radius: 20,
          child: const Icon(Icons.close, color: AppColors.textDark),
        ),
      ),
      body: Column(
        crossAxisAlignment: .stretch,
        children: [
          _ProductSummary(item: widget.item),
          const Gap(h: 16),
          AppSearchField(
            hint: 'Search jobs, customers...',
            controller: _searchController,
            onChanged: (value) =>
                ref.read(jobProvider.notifier).setSearch(value),
          ),
          const Gap(h: 12),
          FilterChipRow(
            options: _statusFilters.keys.toList(),
            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
            onSelected: (index) {
              final status = _statusFilters.values.elementAt(index);
              ref.read(jobProvider.notifier).setStatus(status?.apiValue);
            },
          ),
          const Gap(h: 12),
          Expanded(
            child: JobListView(
              paginate: true,
              onJobTap: (job) => _addToJob(job.id),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact card showing which catalog product is being added.
class _ProductSummary extends StatelessWidget {
  const _ProductSummary({required this.item});

  final CatalogModel item;

  @override
  Widget build(BuildContext context) {
    final price = item.price.toStringAsFixed(item.price % 1 == 0 ? 0 : 2);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCream,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 56,
              height: 56,
              child: item.imageUrl == null
                  ? const ColoredBox(
                      color: AppColors.border,
                      child: Icon(Icons.image_outlined),
                    )
                  : Image.network(item.imageUrl!, fit: .cover),
            ),
          ),
          const Gap(w: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(item.sku, style: AppTextStyles.caption),
                Text(
                  item.name,
                  style: AppTextStyles.listTitle,
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
              ],
            ),
          ),
          const Gap(w: 8),
          Text('\$$price', style: AppTextStyles.listTitle),
        ],
      ),
    );
  }
}
