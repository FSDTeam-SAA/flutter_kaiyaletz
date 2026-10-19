import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_initializer.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_snackbar.dart';
import 'core/utils/navigation.dart';
import 'features/auth/screens/auth_gate.dart';

Future<void> main() async {
  final container = await AppInitializer.initializeApp();

  runApp(
    UncontrolledProviderScope(container: container, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapNDesign',
      theme: AppTheme.light,
      navigatorKey: AppNav.key,
      scaffoldMessengerKey: AppSnackbar.key,
      home: AuthGate(),
    );
  }
}
