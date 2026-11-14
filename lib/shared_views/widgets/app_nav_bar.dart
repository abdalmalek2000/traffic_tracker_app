import 'package:flutter/material.dart';

/// Unified Navbar destination item configuration.
class AppNavBarItem {
  final IconData icon;
  final String label;
  final IconData? selectedIcon;
  final Color? selectedColor;

  const AppNavBarItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.selectedColor,
  });

  NavigationDestination toDestination(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = selectedColor ?? theme.colorScheme.primary;

    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(
        selectedIcon ?? icon,
        color: activeColor,
      ),
      label: label,
    );
  }
}

/// Unified AppNavBar for consistent bottom navigation across the app.
class AppNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavBarItem> items;
  final double height;

  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: height,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: items.map((item) => item.toDestination(context)).toList(),
    );
  }
}
