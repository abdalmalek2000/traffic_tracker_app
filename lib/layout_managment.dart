import 'package:flutter/material.dart';
import 'views/main_navigation_view.dart';
import 'tablet_views/main_navigation_view.dart';

/// Responsive Layout Manager dispatching between Phone and Tablet layouts.
class LayoutManagement extends StatelessWidget {
  const LayoutManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint for Tablets (expanded layout for screens with width >= 720dp)
        if (constraints.maxWidth >= 720) {
          return const TabletMainNavigationView();
        } else {
          return const MainNavigationView();
        }
      },
    );
  }
}
