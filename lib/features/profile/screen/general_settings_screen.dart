import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/common/widgets/widgets.dart';
import 'package:flutter_kaiyaletz/core/theme/app_colors.dart';

import '../../../core/constants/assets_const.dart';
import '../../../core/utils/navigation.dart';
import 'change_password.dart';
import 'delete_screen_confrimation.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: const AppHeader(title: 'General Settings'),
      body: Column(
        children: [
          SettingsGroup(
            children: [
              SettingsTile(
                icon: AppAssets.icons.password,
                label: 'Change Password',
                onTap: () {
                  AppNav.to(ChangePassword());
                },
              ),
              SettingsTile(
                icon: AppAssets.icons.delete,
                label: 'Delete Account',
                color: AppColors.error,
                onTap: () {
                  AppNav.to(const DeleteScreenConfrimation());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
