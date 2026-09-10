import 'package:flutter_test/flutter_test.dart';
import 'package:spotlight_connect/core/access/role_capabilities.dart';
import 'package:spotlight_connect/core/routing/app_routes.dart';
import 'package:spotlight_connect/models/user_model.dart';

UserModel user({
  required String active,
  required List<String> approved,
  String status = 'approved',
  bool admin = false,
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
    isAdminFlag: admin,
    adminRoleEditEnabled: false,
  );
}

void main() {
  test('approved talent can access studio and legacy talent paths', () {
    final caps = RoleCapabilities(
      user(active: 'talent', approved: ['audience', 'talent']),
    );
    expect(caps.canAccessRoute(AppRoutes.studio), isTrue);
    expect(caps.canAccessRoute(AppRoutes.studioAnalytics), isTrue);
    expect(caps.canAccessRoute(AppRoutes.talent), isTrue);
    expect(caps.canAccessRoute(AppRoutes.talentDashboard), isTrue);
    expect(caps.defaultDashboardRoute, AppRoutes.studio);
  });

  test('audience cannot access studio', () {
    final caps = RoleCapabilities(
      user(active: 'audience', approved: ['audience']),
    );
    expect(caps.canAccessRoute(AppRoutes.studio), isFalse);
    expect(caps.canAccessRoute(AppRoutes.studioAnalytics), isFalse);
    expect(caps.defaultDashboardRoute, AppRoutes.audience);
  });

  test('business cannot access studio', () {
    final caps = RoleCapabilities(
      user(active: 'business', approved: ['audience', 'business']),
    );
    expect(caps.canAccessRoute(AppRoutes.studio), isFalse);
    expect(caps.defaultDashboardRoute, AppRoutes.business);
  });

  test('studio helper classifies studio locations', () {
    expect(AppRoutes.isStudioLocation('/studio'), isTrue);
    expect(AppRoutes.isStudioLocation('/studio/analytics'), isTrue);
    expect(AppRoutes.isStudioLocation('/talent'), isFalse);
    expect(AppRoutes.isLegacyTalentLocation('/talent'), isTrue);
    expect(AppRoutes.isLegacyTalentLocation('/talent/dashboard'), isTrue);
  });
}
