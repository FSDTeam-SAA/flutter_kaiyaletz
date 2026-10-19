import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../services/api_cache_service.dart';
import '../services/auth_storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/request_queue_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

final apiCacheServiceProvider = Provider<ApiCacheService>((ref) {
  return ApiCacheService();
});

final authStorageServiceProvider = Provider<AuthStorageService>((ref) {
  return AuthStorageService();
});

final requestQueueServiceProvider = Provider<RequestQueueService>((ref) {
  return RequestQueueService(
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    connectivityService: ref.watch(connectivityServiceProvider),
    cacheService: ref.watch(apiCacheServiceProvider),
    authStorageService: ref.watch(authStorageServiceProvider),
    requestQueue: ref.watch(requestQueueServiceProvider),
  );
});
