import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:traffic_tracker_app/controllers/navigation_controller.dart';
import 'package:traffic_tracker_app/controllers/traffic_controller.dart';
import 'package:traffic_tracker_app/controllers/vpn_controller.dart';
import 'package:traffic_tracker_app/main.dart';

void main() {
  testWidgets('TrafficTrackerApp smoke test', (WidgetTester tester) async {
    Get.reset();
    Get.put(NavigationController());
    Get.put(TrafficController());
    Get.put(VpnController());

    await tester.pumpWidget(const TrafficTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('مراقب الشبكة'), findsOneWidget);
    expect(find.text('الكل (0)'), findsOneWidget);
  });
}
