import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:traffic_tracker_app/constants/typography.dart';
import 'package:traffic_tracker_app/controllers/navigation_controller.dart';
import 'package:traffic_tracker_app/controllers/settings_controller.dart';
import 'package:traffic_tracker_app/controllers/traffic_controller.dart';
import 'package:traffic_tracker_app/controllers/vpn_controller.dart';
import 'package:traffic_tracker_app/models/captured_connection.dart';
import 'package:traffic_tracker_app/views/traffic/traffic_list_view.dart';
import 'package:traffic_tracker_app/views/vpn/vpn_dashboard_view.dart';

void main() {
  group('Responsive Typography Scaling Tests', () {
    test('Calculates smooth font scaling across screen sizes within safe bounds', () {
      // Reference width should yield 1.0
      expect(AppTypography.getResponsiveFontScale(390.0), closeTo(1.0, 0.001));

      // Narrow split screen (280dp) scales down gracefully without falling below minScale
      final narrowScale = AppTypography.getResponsiveFontScale(280.0);
      expect(narrowScale, greaterThanOrEqualTo(0.85));
      expect(narrowScale, lessThan(1.0));

      // Extremely tiny screen (e.g. 150dp) should be strictly clamped to minScale (0.85)
      expect(AppTypography.getResponsiveFontScale(150.0), equals(0.85));

      // Plus / large phone (430dp) scales up moderately
      final largeScale = AppTypography.getResponsiveFontScale(430.0);
      expect(largeScale, greaterThan(1.0));
      expect(largeScale, lessThanOrEqualTo(1.18));

      // Giant tablet / desktop width (1200dp) strictly clamped to maxScale (1.18)
      expect(AppTypography.getResponsiveFontScale(1200.0), equals(1.18));
    });
  });

  group('Narrow Split-Screen Overflow Verification', () {
    testWidgets('VpnDashboardView renders long appName in 270px width without overflow', (tester) async {
      Get.reset();
      Get.put(NavigationController());
      Get.put(SettingsController());
      Get.put(TrafficController());
      final vpnController = Get.put(VpnController());

      // Add a connection with a very long application name and title
      vpnController.connections.add(
        CapturedConnection(
          id: 'test_conn_1',
          protocol: 'HTTPS',
          srcIp: '192.168.1.100',
          srcPort: 54321,
          dstIp: '142.250.190.46',
          dstPort: 443,
          timestamp: DateTime.now(),
          appName: 'com.google.android.youtube.music.vanced',
          domain: 'very-long-subdomain-api-endpoint.googlevideo.com',
          length: 1048576,
        ),
      );

      // Set surface size to narrow split-screen width (270 x 700)
      tester.view.physicalSize = const Size(270 * 2.0, 700 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final fluidScale = AppTypography.getResponsiveFontScale(mediaQuery.size.width);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(fluidScale),
              ),
              child: child!,
            );
          },
          home: const VpnDashboardView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that no exceptions or overflow occurred
      expect(tester.takeException(), isNull);
      expect(find.text('HTTPS'), findsWidgets);
    });

    testWidgets('TrafficListView renders in extremely short height (220px) without overflow', (tester) async {
      Get.reset();
      Get.put(NavigationController());
      Get.put(SettingsController());
      Get.put(TrafficController());

      // Ultra-short screen simulating split-screen horizontal or keyboard collision
      tester.view.physicalSize = const Size(360 * 2.0, 220 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TrafficListView(),
        ),
      );

      await tester.pumpAndSettle();

      // Zero exceptions and zero RenderFlex overflow
      expect(tester.takeException(), isNull);
    });
  });
}
