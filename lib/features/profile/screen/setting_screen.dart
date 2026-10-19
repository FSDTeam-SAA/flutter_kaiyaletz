import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/common/widgets/widgets.dart';
import 'package:flutter_kaiyaletz/core/constants/assets_const.dart';
import 'package:flutter_kaiyaletz/core/theme/app_colors.dart';
import 'package:flutter_kaiyaletz/core/utils/navigation.dart';
import 'package:flutter_kaiyaletz/features/auth/controller/auth_controller.dart';
import 'package:flutter_kaiyaletz/features/profile/controller/profile_controller.dart';
import 'package:flutter_kaiyaletz/features/support/screens/contact_us_screen.dart';
import 'package:flutter_kaiyaletz/features/profile/screen/edit_profile_screen.dart';
import 'package:flutter_kaiyaletz/features/profile/screen/general_settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/gap.dart';
import '../../notification/screens/notification_setting_screen.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).user;

    return AppScaffold(
      header: const AppHeader(title: 'Settings', showBack: false),
      body: RefreshIndicator.adaptive(
        onRefresh: () =>
            ref.read(profileProvider.notifier).getUser(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SettingsProfileCard(
                name: profile?.fullName ?? '',
                email: profile?.email ?? '',
                avatar: profile != null && profile.profileImage.url.isNotEmpty
                    ? NetworkImage(profile.profileImage.url)
                    : null,
              ),
              Gap.h(20),
              SettingsGroup(
                children: [
                  SettingsTile(
                    icon: AppAssets.icons.edit,
                    label: 'Edit Profile',
                    onTap: () {
                      AppNav.to(EditProfileScreen());
                    },
                  ),
                  SettingsTile(
                    icon: AppAssets.icons.general,
                    label: 'General Settings',
                    onTap: () {
                      AppNav.to(GeneralSettingsScreen());
                    },
                  ),
                  SettingsTile(
                    icon: AppAssets.icons.notification,
                    label: 'Notification',
                    onTap: () {
                      AppNav.to(NotificationSettingScreen());
                    },
                  ),
                  SettingsTile(
                    icon: AppAssets.icons.email,
                    label: 'Contact Us',
                    onTap: () {
                      AppNav.to(ContactUsScreen());
                    },
                  ),
                ],
              ),
              Gap.h(20),
              AppOutlineButton(
                onSimplePressed: () =>
                    ref.read(authCtrlProvider.notifier).logout(),
                label: 'Logout',
                color: AppColors.danger,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
