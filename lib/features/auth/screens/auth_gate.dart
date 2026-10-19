import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/utils/d_print.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/common/widgets/app_loading_indicator.dart';
import '../../../core/common/widgets/app_logo.dart';
import '../../../core/constants/assets_const.dart';
import '../../../core/common/models/session_status.dart';
import '../../../core/providers/core_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/navigation.dart';
import '../../nav/screen/bottom_nav_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

/// Resolves the signed-in status and stored first name once, holding the
/// result for at least [_floorDuration] so the splash doesn't flash by.
final sessionStatusProvider =
    FutureProvider.autoDispose<(SessionStatus, String)>((ref) async {
      final authStorage = ref.watch(authStorageServiceProvider);
      final results = await Future.wait([
        authStorage.currentSessionStatus(),
        authStorage.getFirstName(),
        Future.delayed(_floorDuration),
      ]);
      return (results[0] as SessionStatus, (results[1] as String?) ?? '');
    });

const _floorDuration = Duration(milliseconds: 600);

/// Wires the global session-expiry hooks once (cached by Riverpod for as
/// long as something watches it), so [AuthGate] doesn't need State/initState
/// just to run this a single time.
final _authNavHooksProvider = Provider<void>((ref) {
  ApiClient.onSessionExpired = () => AppNav.offAll(const LoginScreen());
  ApiClient.onAuthRequired = () {};
});

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DPrint.log("Auth Gate");

    ref.watch(_authNavHooksProvider);

    // Fires only on an actual previous -> next transition, so extra
    // rebuilds of this widget can't trigger a second navigation.
    ref.listen<AsyncValue<(SessionStatus, String)>>(sessionStatusProvider, (
      _,
      next,
    ) {
      if (!next.hasValue) return;
      final (status, firstName) = next.value ?? (SessionStatus.guest, '');

      if (status == SessionStatus.authenticated) {
        if (firstName.isEmpty) {
          AppNav.offAll(const ProfileScreen());
        } else {
          AppNav.offAll(const BottomNavScreen());
        }
      } else {
        AppNav.offAll(const LoginScreen());
      }
    });

    return const _SplashScreen();
  }
}

/// Branded splash shown while [sessionStatusProvider] resolves.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            AppLogo(
              images: AppAssets.img.logo,
              h: 110,
              borderRadius: 24,
              fit: .cover,
            ),
            const SizedBox(height: 32),
            const AppLoadingIndicator(size: 28),
          ],
        ),
      ),
    );
  }
}
