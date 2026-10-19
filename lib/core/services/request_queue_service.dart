import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../api/api_client.dart';
import 'connectivity_service.dart';

class QueuedRequest {
  final String method;
  final String endpoint;
  final dynamic data;
  final String timestamp;

  const QueuedRequest({
    required this.method,
    required this.endpoint,
    this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'method': method,
    'endpoint': endpoint,
    'data': data,
    'timestamp': timestamp,
  };

  factory QueuedRequest.fromJson(Map<String, dynamic> json) => QueuedRequest(
    method: json['method'],
    endpoint: json['endpoint'],
    data: json['data'],
    timestamp: json['timestamp'],
  );
}

/// Persists mutating requests (POST/PATCH/PUT/DELETE with `useQueue: true`)
/// made while offline, and replays them automatically once the device
/// reconnects.
///
/// [ApiClient] and [RequestQueueService] depend on each other (the client
/// queues requests here; this service replays them through the client), so
/// the cycle is broken with [attachApiClient] instead of a constructor
/// argument — call it once, right after both are created. See
/// riverpod_providers.dart for the wiring.
class RequestQueueService {
  static const String _boxName = 'request_queue_box';
  late Box _box;
  bool _isProcessing = false;

  final ConnectivityService _connectivityService;
  ApiClient? _apiClient;

  RequestQueueService({required this._connectivityService});

  void attachApiClient(ApiClient apiClient) {
    _apiClient = apiClient;
  }

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    _connectivityService.onReconnected.listen((_) => flushQueue());
  }

  Future<void> addToQueue({
    required String method,
    required String endpoint,
    dynamic data,
  }) async {
    final request = QueuedRequest(
      method: method,
      endpoint: endpoint,
      data: data,
      timestamp: DateTime.now().toIso8601String(),
    );
    await _box.add(jsonEncode(request.toJson()));
  }

  int get pendingCount => _box.length;

  Future<void> flushQueue() async {
    if (_isProcessing || _box.isEmpty) return;
    if (!_connectivityService.isConnected) return;
    if (_apiClient == null) return; // not attached yet

    _isProcessing = true;

    final items = List<dynamic>.from(_box.values);
    final keys = List<dynamic>.from(_box.keys);

    for (var i = 0; i < items.length; i++) {
      final request = QueuedRequest.fromJson(jsonDecode(items[i]));
      try {
        final result = await _apiClient!.requestGeneric(
          method: request.method,
          endpoint: request.endpoint,
          data: request.data,
        );
        if (result.isRight()) {
          await _box.delete(keys[i]);
        } else {
          break; // stop on first failure, retry the rest next reconnect
        }
      } catch (_) {
        break;
      }
    }

    _isProcessing = false;
  }
}
