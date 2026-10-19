import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/common/widgets/widgets.dart';
import 'package:flutter_kaiyaletz/core/utils/d_print.dart';
import 'package:flutter_kaiyaletz/features/home/screens/home_screen.dart';
import 'package:flutter_kaiyaletz/features/nav/controller/bottom_nav_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/screens/catalog_screen.dart';
import '../../job/screens/jobs_screen.dart';
import '../../profile/screen/setting_screen.dart';

class BottomNavScreen extends StatelessWidget {
  const BottomNavScreen({super.key});

  static const _tabs = [
    HomeScreen(),
    JobsScreen(),
    CatalogScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    DPrint.log("Bottom Nav Screen");

    return AppScaffold(
      padding: .zero,
      body: Consumer(
        builder: (context, ref, _) {
          final currentIndex = ref.watch(bottomNavCtrlProvider).currentIndex;

          return IndexedStack(index: currentIndex, children: _tabs);
        },
      ),
      bottomBar: Consumer(
        builder: (context, ref, _) {
          final currentIndex = ref.watch(bottomNavCtrlProvider).currentIndex;
          return AppBottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) =>
                ref.read(bottomNavCtrlProvider.notifier).setIndex(index),
          );
        },
      ),
    );
  }
}
