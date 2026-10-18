import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_tracker_app/main.dart';

void main() {
  testWidgets('TrafficTrackerApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TrafficTrackerApp());
    await tester.pumpAndSettle();

    // Verify main components are rendered
    expect(find.text('مراقب الشبكة'), findsOneWidget);
    expect(find.text('الكل (0)'), findsOneWidget);
  });
}
