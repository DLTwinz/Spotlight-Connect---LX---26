import 'package:flutter_test/flutter_test.dart';
import 'package:spotlight_connect/core/routing/app_routes.dart';
import 'package:spotlight_connect/core/routing/studio_route_contract.dart';

void main() {
  test('strips auth material from talent compatibility redirects', () {
    final target = StudioRouteContract.talentCompatibilityTarget({
      'ref': 'campaign',
      'code': 'pkce-code',
      'access_token': 'secret',
      'type': 'recovery',
    });
    expect(target.startsWith(AppRoutes.studio), isTrue);
    expect(target.contains('ref=campaign'), isTrue);
    expect(target.contains('code='), isFalse);
    expect(target.contains('access_token='), isFalse);
    expect(target.contains('type='), isFalse);
  });

  test('does not treat analytics as an unknown studio child', () {
    expect(StudioRouteContract.isUnknownStudioChild(AppRoutes.studio), isFalse);
    expect(
      StudioRouteContract.isUnknownStudioChild(AppRoutes.studioAnalytics),
      isFalse,
    );
    expect(
      StudioRouteContract.isUnknownStudioChild('${AppRoutes.studio}/identity'),
      isTrue,
    );
  });

  test('legacy talent paths are distinct from studio analytics', () {
    expect(AppRoutes.isLegacyTalentLocation(AppRoutes.talent), isTrue);
    expect(AppRoutes.isLegacyTalentLocation(AppRoutes.talentDashboard), isTrue);
    expect(AppRoutes.isLegacyTalentLocation(AppRoutes.studio), isFalse);
    expect(AppRoutes.isStudioLocation(AppRoutes.studioAnalytics), isTrue);
  });
}
