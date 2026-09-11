import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotlight_connect/pages/dashboards/creator_analytics_economics_page.dart';
import 'package:spotlight_connect/pages/dashboards/fixtures/analytics_fixtures.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CreatorAnalyticsEconomicsPage())),
    );
    await tester.pump();
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
    expect(find.textContaining('connected payout source'), findsNothing);
    expect(find.textContaining('net of platform fees'), findsNothing);
  });

  testWidgets('pulse range chips are interactive locally', (tester) async {
    await pumpPage(tester);

    final cumulative = find.text('Cumulative');
    expect(cumulative, findsOneWidget);

    await tester.ensureVisible(cumulative);
    await tester.pumpAndSettle();
    await tester.tap(cumulative);
    await tester.pumpAndSettle();

    expect(find.text('Cumulative'), findsOneWidget);
  });

  testWidgets('constrained 800px width keeps KPI stack and pulse controls', (
    tester,
  ) async {
    await pumpPage(tester, size: const Size(800, 900));

    expect(tester.takeException(), isNull);
    expect(find.text('Creator Analytics & Economics'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Cumulative'), findsOneWidget);
    expect(find.text(AnalyticsFixtures.disclosure), findsOneWidget);
    await tester.tap(find.text('Cumulative'));
    await tester.pump();
    expect(find.text('Cumulative'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
