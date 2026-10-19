import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Tracks online/offline status and exposes a stream that fires once on
/// every reconnect (used by [ApiClient] and [RequestQueueService]).
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isInitialCheck = true;

  final ValueNotifier<bool> _isConnectedNotifier = ValueNotifier<bool>(true);
  ValueNotifier<bool> get isConnectedNotifier => _isConnectedNotifier;
  bool get isConnected => _isConnectedNotifier.value;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  /// Every connectivity change (true = online, false = offline).
  Stream<bool> get connectivityStream => _controller.stream;

  /// Fires exactly once each time the device goes from offline to online.
  /// [ApiClient] and [RequestQueueService] listen to this to retry/flush.
  Stream<void> get onReconnected =>
      _controller.stream.where((connected) => connected).map((_) {});

  Future<void> initialize() async {
    await _checkConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen((_) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    final connected = results.any((r) => r != ConnectivityResult.none);

    final changed = _isConnectedNotifier.value != connected || _isInitialCheck;
    _isInitialCheck = false;
    _isConnectedNotifier.value = connected;

    if (changed) _controller.add(connected);
  }

  /// Waits up to [timeout] for connectivity to become true. Throws a
  /// [TimeoutException] if it doesn't. Used by [ApiClient] to ride out a
  /// brief signal drop before failing a request outright.
  Future<void> waitForConnection({required Duration timeout}) {
    if (isConnected) return Future.value();

    final completer = Completer<void>();
    late StreamSubscription<bool> sub;
    sub = connectivityStream.listen((connected) {
      if (connected) {
        sub.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        sub.cancel();
        throw TimeoutException('No connection within $timeout');
      },
    );
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
    _isConnectedNotifier.dispose();
  }
}
