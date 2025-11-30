import 'package:flutter_test/flutter_test.dart';
import 'package:solar_system_explorer/app.dart';

void main() {
  testWidgets('App launches and shows APOD screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SolarSystemApp());

    // Verify that the APOD screen title is present
    expect(find.text('NASA Picture of the Day'), findsOneWidget);
    
    // Verify loading state initially
    expect(find.text('Fetching the cosmos...'), findsOneWidget);
  });
}
