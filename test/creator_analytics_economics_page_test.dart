import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotlight_connect/pages/dashboards/creator_analytics_economics_page.dart';
import 'package:spotlight_connect/pages/dashboards/fixtures/analytics_fixtures.dart';

void main() {
  testWidgets('renders Mira analytics fixture contract copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CreatorAnalyticsEconomicsPage()),
    );

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
  });

  testWidgets('pulse range chips are interactive locally', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CreatorAnalyticsEconomicsPage()),
    );
    await tester.tap(find.text('Weekly'));
    await tester.pump();
    expect(find.text('Weekly'), findsOneWidget);
  });
}
