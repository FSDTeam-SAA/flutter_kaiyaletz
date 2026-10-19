import 'dart:async';

import 'package:flutter_kaiyaletz/features/catalog/model/catalog_model.dart';
import 'package:flutter_kaiyaletz/features/catalog/repos/catalog_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catalogProvider =
    NotifierProvider.autoDispose<CatalogController, CatalogState>(
      CatalogController.new,
    );

class CatalogState {
  final List<CatalogModel>? catalogs;
  final bool isLoading;
  final bool isLoadingMore;
  final String search;
  final ProductCategory? category;
  final int page;
  final int? totalPages;

  CatalogState({
    this.catalogs,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.search = '',
    this.category,
    this.page = 1,
    this.totalPages,
  });

  bool get hasMore => totalPages == null || page < totalPages!;

  CatalogState copyWith({
    List<CatalogModel>? catalogs,
    bool? isLoading,
    bool? isLoadingMore,
    String? search,
    ProductCategory? category,
    bool clearCategory = false,
    int? page,
    int? totalPages,
  }) {
    return CatalogState(
      catalogs: catalogs ?? this.catalogs,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
      category: clearCategory ? null : (category ?? this.category),
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class CatalogController extends Notifier<CatalogState> {
  Timer? _searchDebounce;

  @override
  CatalogState build() {
    ref.onDispose(() => _searchDebounce?.cancel());
    Future.microtask(getCatalogs);
    return CatalogState();
  }

  /// Fetches page 1 with the current search/category filters, replacing the list.
  Future<void> getCatalogs() async {
    final repo = ref.read(catalogRepo);

    state = state.copyWith(isLoading: true, page: 1);

    repo
        .getCatalogs(search: state.search, category: state.category, page: 1)
        .listen((either) {
          either.fold(
            (f) => state = state.copyWith(isLoading: false),
            (s) => state = state.copyWith(
              catalogs: s.data,
              isLoading: false,
              page: s.pagination?.page ?? 1,
              totalPages: s.pagination?.pages,
            ),
          );
        });
  }

  /// Fetches the next page and appends it, for infinite scroll.
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;

    final repo = ref.read(catalogRepo);
    final nextPage = state.page + 1;

    state = state.copyWith(isLoadingMore: true);

    repo
        .getCatalogs(
          search: state.search,
          category: state.category,
          page: nextPage,
        )
        .listen((either) {
          either.fold(
            (f) => state = state.copyWith(isLoadingMore: false),
            (s) => state = state.copyWith(
              catalogs: [...?state.catalogs, ...s.data],
              isLoadingMore: false,
              page: s.pagination?.page ?? nextPage,
              totalPages: s.pagination?.pages,
            ),
          );
        });
  }

  /// Debounces user input before re-querying page 1.
  void setSearch(String value) {
    state = state.copyWith(search: value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), getCatalogs);
  }

  /// Pass `null` to clear the category filter.
  void setCategory(ProductCategory? category) {
    state = state.copyWith(category: category, clearCategory: category == null);
    getCatalogs();
  }
}
