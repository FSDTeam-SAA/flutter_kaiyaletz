import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Caches GET responses in Hive, keyed by endpoint + query parameters, so
/// [ApiClient.get] (with a `cacheDuration`) and [ApiClient.getStream] can
/// serve something instantly and offline.
class ApiCacheService {
  static const String _cacheBoxName = 'api_cache_box';
  static const String _durationPrefix = 'cache_duration_';
  static const Duration _defaultCacheDuration = Duration(hours: 24);

  late Box _box;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _box = Hive.isBoxOpen(_cacheBoxName)
        ? Hive.box(_cacheBoxName)
        : await Hive.openBox(_cacheBoxName);
    _isInitialized = true;
  }

  String _keyFor(String endpoint, Map<String, dynamic>? requestData) {
    if (requestData == null || requestData.isEmpty) return endpoint;
    final sortedKeys = requestData.keys.toList()..sort();
    final query = sortedKeys.map((k) => '$k=${requestData[k]}').join('&');
    return '$endpoint?$query';
  }

  Future<void> cacheData(
    String endpoint, {
    required dynamic data,
    Map<String, dynamic>? requestData,
    Duration? cacheDuration,
  }) async {
    final key = _keyFor(endpoint, requestData);
    await _box.put(key, jsonEncode(data));
    await _box.put(
      '$_durationPrefix$key',
      DateTime.now()
          .add(cacheDuration ?? _defaultCacheDuration)
          .toIso8601String(),
    );
  }

  Future<dynamic> getCachedData(
    String endpoint, {
    Map<String, dynamic>? requestData,
  }) async {
    final key = _keyFor(endpoint, requestData);
    if (!(await isCacheValid(endpoint, requestData: requestData))) {
      return null;
    }
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isCacheValid(
    String endpoint, {
    Map<String, dynamic>? requestData,
  }) async {
    final key = _keyFor(endpoint, requestData);
    final expiryString = _box.get('$_durationPrefix$key');
    if (expiryString == null) return false;
    final expiry = DateTime.tryParse(expiryString);
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  /// Clears every cached entry whose key starts with [pathPrefix].
  /// Pass an exact endpoint to invalidate one call, or a shared prefix
  /// (e.g. `/jobs`) to invalidate a whole resource after a mutation.
  Future<void> clearCache(String pathPrefix) async {
    final keysToRemove = _box.keys
        .where(
          (k) => k
              .toString()
              .replaceFirst(_durationPrefix, '')
              .startsWith(pathPrefix),
        )
        .toList();
    await _box.deleteAll(keysToRemove);
  }

  Future<void> clearAllCache() async {
    await _box.clear();
  }
}
