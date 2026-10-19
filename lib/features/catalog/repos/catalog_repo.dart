import 'package:flutter_kaiyaletz/core/api/api_client.dart';
import 'package:flutter_kaiyaletz/core/common/models/network_result.dart';
import 'package:flutter_kaiyaletz/core/constants/api_constants.dart';
import 'package:flutter_kaiyaletz/core/providers/core_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/catalog_model.dart';

final catalogRepo = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return CatalogRepoImpl(apiClient: apiClient);
});

abstract class CatalogRepo {
  NetworkStream<List<CatalogModel>> getCatalogs({
    String search = "",
    ProductCategory? category,
    int page = 1,
    int limit = 24,
  });
}

class CatalogRepoImpl implements CatalogRepo {
  final ApiClient apiClient;

  CatalogRepoImpl({required this.apiClient});

  @override
  NetworkStream<List<CatalogModel>> getCatalogs({
    String search = "",
    ProductCategory? category,
    int page = 1,
    int limit = 24,
  }) {
    return apiClient.getStream(
      endpoint: ApiConstants.catalog.catalogs,
      queryParameters: {
        if (search.isNotEmpty) "search": search,
        if (category != null) "category": category.value,
        "page": page,
        "limit": limit,
      },

      fromJsonT: (json) =>
          (json as List).map((item) => CatalogModel.fromJson(item)).toList(),
    );
  }
}
