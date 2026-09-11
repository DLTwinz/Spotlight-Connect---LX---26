import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotlight_connect/core/access/role_capabilities.dart';
import 'package:spotlight_connect/core/routing/app_routes.dart';
import 'package:spotlight_connect/core/routing/studio_route_contract.dart';
import 'package:spotlight_connect/models/user_model.dart';
import 'package:spotlight_connect/pages/dashboards/creator_community_page.dart';
import 'package:spotlight_connect/pages/dashboards/fixtures/community_fixtures.dart';

UserModel _user({
  required String active,
  required List<String> approved,
  String status = 'approved',
}) {
  return UserModel(
    userId: 'user-1',
    email: 'user@example.com',
    displayName: 'Test User',
    username: 'test',
    profilePhoto: null,
    coverPhoto: null,
    baseRole: 'audience',
    approvedRoles: approved,
    activeRole: active,
    onboardingComplete: true,
    applicationStatusSummary: status,
    requestedRolePending: null,
    approved: status == 'approved',
    isAdminFlag: false,
    adminRoleEditEnabled: false,
  );
}

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    Size size = const Size(1280, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CreatorCommunityPage())),
    );
    await tester.pump();
  }

  test('approved talent can access community route', () {
    final caps = RoleCapabilities(
      _user(active: 'talent', approved: ['audience', 'talent']),
    );
    expect(caps.canAccessRoute(AppRoutes.studioCommunity), isTrue);
    expect(
      StudioRouteContract.isUnknownStudioChild(AppRoutes.studioCommunity),
      isFalse,
    );
    expect(
      StudioRouteContract.isUnknownStudioChild('${AppRoutes.studio}/unknown'),
      isTrue,
    );
  });

  test('audience and business cannot access community', () {
    expect(
      RoleCapabilities(
        _user(active: 'audience', approved: ['audience']),
      ).canAccessRoute(AppRoutes.studioCommunity),
      isFalse,
    );
    expect(
      RoleCapabilities(
        _user(active: 'business', approved: ['audience', 'business']),
      ).canAccessRoute(AppRoutes.studioCommunity),
      isFalse,
    );
  });

  testWidgets('renders Avery community fixture structure', (tester) async {
    await pumpPage(tester);
    expect(find.text('Your people, in motion'), findsOneWidget);
    expect(find.textContaining('Avery Nova'), findsWidgets);
    expect(find.text('Community activity'), findsOneWidget);
    expect(find.text('Your circles'), findsOneWidget);
    expect(find.text('Upcoming access & events'), findsOneWidget);
    expect(find.text('Messages that need you'), findsOneWidget);
    expect(find.text('Supporter Pulse'), findsOneWidget);
    expect(find.text('Relationship alerts'), findsOneWidget);
    expect(find.text('Recognition queue'), findsOneWidget);
    expect(find.text('How your community feels'), findsOneWidget);
    expect(find.text(CommunityFixtures.disclosure), findsOneWidget);
    expect(find.textContaining('live members'), findsWidgets);
    expect(find.text('Share an update'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('local filter and disabled actions stay fixture-safe', (
    tester,
  ) async {
    await pumpPage(tester);
    final comments = find.text('Comments');
    await tester.ensureVisible(comments);
    await tester.pumpAndSettle();
    await tester.tap(comments);
    await tester.pumpAndSettle();
    expect(find.textContaining('Jordan Ellis'), findsWidgets);

    final createEvent = find.text('Create an event');
    await tester.ensureVisible(createEvent);
    await tester.pumpAndSettle();
    await tester.tap(createEvent);
    await tester.pumpAndSettle();
    expect(find.textContaining('unavailable in this build'), findsWidgets);

    final share = find.text('Share an update');
    await tester.ensureVisible(share);
    await tester.pumpAndSettle();
    await tester.tap(share);
    await tester.pumpAndSettle();
    expect(find.text('Local update preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('constrained 800px community layout does not overflow', (
    tester,
  ) async {
    await pumpPage(tester, size: const Size(800, 900));
    expect(find.text('Your people, in motion'), findsOneWidget);
    expect(find.text(CommunityFixtures.disclosure), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
