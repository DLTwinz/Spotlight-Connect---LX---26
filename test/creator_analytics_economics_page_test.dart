import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotlight_connect/pages/dashboards/creator_analytics_economics_page.dart';
import 'package:spotlight_connect/pages/dashboards/fixtures/analytics_fixtures.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: CreatorAnalyticsEconomicsPage()),
    );
  }

  testWidgets('renders Mira analytics fixture contract copy', (tester) async {
    await pumpPage(tester);

    expect(find.text('Creator Analytics & Economics'), findsOneWidget);
    expect(find.text('See what is moving your world'), findsOneWidget);
    expect(find.textContaining('Mira Solis'), findsWidgets);
    expect(find.text('Economic Pulse'), findsOneWidget);
    expect(find.text('Where it came from'), findsOneWidget);
    expect(find.text('Quick Insights'), findsOneWidget);
    expect(find.text('Data Confidence Key'), findsOneWidget);
    expect(find.text(AnalyticsFixtures.disclosure), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Cumulative'), findsOneWidget);
    expect(find.textContaining('live financial'), findsNothing);
    expect(find.textContaining('payout'), findsNothing);
    expect(find.textContaining('settlement'), findsNothing);
  });

  testWidgets('pulse range chips are interactive locally', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Weekly'));
    await tester.pump();
    expect(find.text('Weekly'), findsOneWidget);
  });
}
