import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotlight_connect/core/access/role_capabilities.dart';
import 'package:spotlight_connect/core/routing/app_routes.dart';
import 'package:spotlight_connect/core/routing/studio_route_contract.dart';
import 'package:spotlight_connect/models/user_model.dart';
import 'package:spotlight_connect/pages/dashboards/creator_identity_control_page.dart';
import 'package:spotlight_connect/pages/dashboards/fixtures/identity_fixtures.dart';

UserModel _user({required String active, required List<String> approved}) {
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
    applicationStatusSummary: 'approved',
    requestedRolePending: null,
    approved: true,
    isAdminFlag: false,
    adminRoleEditEnabled: false,
  );
}

void main() {
  Future<void> pumpPage(WidgetTester tester, {Size size = const Size(1280, 900)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CreatorIdentityControlPage())));
    await tester.pump();
  }

  test('approved talent can access identity route', () {
    final caps = RoleCapabilities(_user(active: 'talent', approved: ['audience', 'talent']));
    expect(caps.canAccessRoute(AppRoutes.studioIdentity), isTrue);
    expect(StudioRouteContract.isUnknownStudioChild(AppRoutes.studioIdentity), isFalse);
    expect(StudioRouteContract.isUnknownStudioChild('${AppRoutes.studio}/unknown'), isTrue);
  });

  test('audience and business cannot access identity', () {
    expect(RoleCapabilities(_user(active: 'audience', approved: ['audience'])).canAccessRoute(AppRoutes.studioIdentity), isFalse);
    expect(RoleCapabilities(_user(active: 'business', approved: ['audience', 'business'])).canAccessRoute(AppRoutes.studioIdentity), isFalse);
  });

  testWidgets('renders Aria identity fixture structure', (tester) async {
    await pumpPage(tester);
    expect(find.text('Creator Identity & Control Center'), findsOneWidget);
    expect(find.textContaining('Aria Voss'), findsWidgets);
    expect(find.text('Identity & positioning'), findsOneWidget);
    expect(find.text('Verification & proof'), findsOneWidget);
    expect(find.text('Connected accounts'), findsOneWidget);
    expect(find.text('Visibility & contact rules'), findsOneWidget);
    expect(find.text('Availability & booking'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Privacy & data'), findsOneWidget);
    expect(find.text(IdentityFixtures.disclosure), findsOneWidget);
    expect(find.text('Not connected'), findsWidgets);
    expect(find.textContaining('not a live platform connection'), findsWidgets);
    expect(find.textContaining('Not an identity-verification result'), findsWidgets);
    expect(find.text('Connected'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing then save and discard stay local', (tester) async {
    await pumpPage(tester);
    expect(find.text('No local changes'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Aria Preview');
    await tester.pump();
    expect(find.text('Unsaved local preview changes'), findsOneWidget);
    await tester.tap(find.text('Save changes'));
    await tester.pump();
    expect(find.text('No local changes'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Temporary name');
    await tester.pump();
    await tester.tap(find.text('Discard'));
    await tester.pump();
    expect(find.text('No local changes'), findsOneWidget);
    expect(find.text(IdentityFixtures.creatorName), findsWidgets);
  });

  testWidgets('constrained 800px identity layout does not overflow', (tester) async {
    await pumpPage(tester, size: const Size(800, 900));
    expect(find.text('Creator Identity & Control Center'), findsOneWidget);
    expect(find.text('Daily'), findsNothing);
    expect(find.text(IdentityFixtures.disclosure), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
