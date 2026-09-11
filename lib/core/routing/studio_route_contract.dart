import 'package:spotlight_connect/core/routing/app_routes.dart';

/// Compatibility redirect helpers for Creator Studio.
/// Auth callback / PKCE / recovery handling stays in `lib/nav.dart` and
/// always runs before these helpers.
class StudioRouteContract {
  const StudioRouteContract._();

  static const List<String> authQueryKeys = <String>[
    'code',
    'error',
    'error_code',
    'error_description',
    'type',
    'access_token',
    'refresh_token',
    'provider_token',
    'provider_refresh_token',
    'token_hash',
    'state',
  ];

  static const List<String> knownStudioChildren = <String>[
    AppRoutes.studioAnalytics,
    AppRoutes.studioIdentity,
    AppRoutes.studioCommunity,
  ];

  static Map<String, String> safeQuery(Map<String, String> raw) {
    final cleaned = Map<String, String>.from(raw);
    for (final key in authQueryKeys) {
      cleaned.remove(key);
    }
    return cleaned;
  }

  static String talentCompatibilityTarget(Map<String, String> query) {
    final safe = safeQuery(query);
    return Uri(
      path: AppRoutes.studio,
      queryParameters: safe.isEmpty ? null : safe,
    ).toString();
  }

  static bool isUnknownStudioChild(String location) {
    return AppRoutes.isStudioLocation(location) &&
        location != AppRoutes.studio &&
        !knownStudioChildren.contains(location);
  }
}
