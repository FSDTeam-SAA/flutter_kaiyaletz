import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/common/widgets/widgets.dart';
import 'package:flutter_kaiyaletz/core/utils/gap.dart';
import 'package:flutter_kaiyaletz/core/utils/navigation.dart';
import 'package:flutter_kaiyaletz/features/catalog/screens/catalog_details_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/catalog_cotroller.dart';
import '../model/catalog_model.dart';

/// Index 0 is "All" (no category filter); the rest follow [ProductCategory].
const _categoryFilters = <ProductCategory?>[null, ...ProductCategory.values];

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(
      catalogProvider.select((s) => s.category),
    );

    return AppScaffold(
      body: Column(
        crossAxisAlignment: .stretch,
        children: [
          AppSearchField(
            hint: 'Search products or SKU...',
            controller: _searchController,
            onChanged: (value) =>
                ref.read(catalogProvider.notifier).setSearch(value),
          ),
          const Gap(h: 12),
          FilterChipRow(
            options: ['All', for (final c in ProductCategory.values) c.label],
            selectedIndex: _categoryFilters.indexOf(selectedCategory),
            onSelected: (index) => ref
                .read(catalogProvider.notifier)
                .setCategory(_categoryFilters[index]),
          ),
          const Gap(h: 20),
          const Expanded(child: _CatalogGrid()),
        ],
      ),
    );
  }
}

class _CatalogGrid extends ConsumerWidget {
  const _CatalogGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(catalogProvider.select((s) => s.isLoading));
    final catalogs = ref.watch(catalogProvider.select((s) => s.catalogs));
    final isLoadingMore = ref.watch(
      catalogProvider.select((s) => s.isLoadingMore),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnForWidth(constraints.maxWidth);

        if (isLoading && catalogs == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = catalogs ?? [];

        return RefreshIndicator.adaptive(
          onRefresh: () => ref.read(catalogProvider.notifier).getCatalogs(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final nearBottom =
                  notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200;
              if (nearBottom) ref.read(catalogProvider.notifier).loadMore();
              return false;
            },
            child: items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('No products found')),
                      ),
                    ],
                  )
                : CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 196,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) =>
                            _ProductTile(item: items[i]),
                      ),
                      if (isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

int _columnForWidth(double width) {
  if (width < 600) return 2;
  if (width < 900) return 3;
  return 4;
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.item});

  final CatalogModel item;

  @override
  Widget build(BuildContext context) {
    return ProductCard(
      sku: item.sku,
      name: item.name,
      dimensions: item.dimensions,
      price: '\$${item.price.toStringAsFixed(item.price % 1 == 0 ? 0 : 2)}',
      category: item.category.label,
      image: item.imageUrl == null
          ? null
          : Image.network(item.imageUrl!, fit: .cover),
      onTap: () {
        AppNav.to(CatalogDetailsScreen(item: item));
      },
    );
  }
}
