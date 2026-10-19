import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/common/widgets/app_scaffold.dart';
import 'package:flutter_kaiyaletz/features/notification/controller/notification_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/widgets/app_header.dart';
import '../../../core/common/widgets/app_switch.dart';
import '../../../core/common/widgets/settings_widgets.dart';

class NotificationSettingScreen extends ConsumerWidget {
  const NotificationSettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);
    final controller = ref.read(notificationProvider.notifier);

    return AppScaffold(
      header: const AppHeader(title: 'Notification settings'),
      body: SingleChildScrollView(
        child: SettingsGroup(
          children: [
            for (final entry in state.values.entries)
              SettingsTile(
                label: entry.key,
                trailing: AppSwitch(
                  value: entry.value,
                  enabled: !state.isLoading,
                  onChanged: (v) => controller.toggleChange(entry.key, v),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
