import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core_provider.dart';

/// Bootstraps everything the app needs before [runApp]: Flutter bindings,
/// Hive, and the cache/request-queue services (which open their own Hive
/// boxes via `initialize()` and must be ready before any widget can hit
/// the network).
class AppInitializer {
  const AppInitializer._();

  static Future<ProviderContainer> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    final container = ProviderContainer();
    await container.read(apiCacheServiceProvider).initialize();
    await container.read(requestQueueServiceProvider).initialize();
    container
        .read(requestQueueServiceProvider)
        .attachApiClient(container.read(apiClientProvider));

    return container;
  }
}
