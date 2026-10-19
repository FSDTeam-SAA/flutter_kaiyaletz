import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// One tab in [AppBottomNavBar].
class AppNavItem {
  const AppNavItem({required this.label, required this.icon, this.activeIcon});

  final String label;
  final IconData icon;
  final IconData? activeIcon;
}

/// Main bottom navigation (Home, Jobs, Catalog, Settings).
///
/// Figma ("Navigation"): 393×62, fill #F9F4F0, top border 1px #ECDDD0,
/// padding 20/12. Item: icon 20 → 4px gap → label DM Sans Regular 12.
/// Active: #C29266 + 48×2 indicator bar on the top edge. Inactive: #7D7D7D.
/// Used on: Home, Catalog, Catalog Details, Catalog Add, Settings.
///
/// Pass it to `AppScaffold(bottomBar: ...)`.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = defaultItems,
  });

  static const defaultItems = [
    AppNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    AppNavItem(label: 'Jobs', icon: Icons.work_outline, activeIcon: Icons.work),
    AppNavItem(
      label: 'Catalog',
      icon: Icons.grid_view,
      activeIcon: Icons.grid_view_rounded,
    ),
    AppNavItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
  ];

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;

  static const double _horizontalPadding = 20;
  static const double _indicatorWidth = 48;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCream,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth =
                  (constraints.maxWidth - _horizontalPadding * 2) /
                  items.length;
              final indicatorLeft =
                  _horizontalPadding +
                  itemWidth * currentIndex +
                  (itemWidth - _indicatorWidth) / 2;

              return Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _horizontalPadding,
                      ),
                      child: Row(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Expanded(
                              child: _NavButton(
                                item: items[i],
                                isActive: i == currentIndex,
                                onTap: () => onTap(i),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    top: 0,
                    left: indicatorLeft,
                    child: Container(
                      width: _indicatorWidth,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final AppNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textMuted;

    return GestureDetector(
      behavior: .opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(
            isActive ? (item.activeIcon ?? item.icon) : item.icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: AppTextStyles.navLabel.copyWith(color: color),
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ],
      ),
    );
  }
}
