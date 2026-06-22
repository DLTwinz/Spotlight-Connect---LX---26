import 'package:flutter/foundation.dart';

/// Server-authoritative feature policy for the progression system.
///
/// This is intentionally separate from [AppFeature]/[FeatureFlagProvider], which
/// is a local QA UI-gating helper and NOT a security boundary.
///
/// Policy rules:
/// - Frontend uses this to hide/disable UI modules.
/// - Backend RPCs/Edge Functions MUST re-check these flags.
@immutable
class ProgressionFeaturePolicy {
  const ProgressionFeaturePolicy({required this.flags, required this.loadedAt, required this.source});

  /// Key -> enabled.
  ///
  /// Keys are stable strings to match backend (e.g. `progression_enabled`).
  final Map<String, bool> flags;
  final DateTime loadedAt;

  /// Where the policy came from: `rpc`, `fallback`, etc.
  final String source;

  bool isEnabled(String key, {bool fallback = false}) => flags[key] ?? fallback;

  /// “Planned” toggles.
  bool get progressionEnabled => isEnabled('progression_enabled');
  bool get missionsEnabled => isEnabled('missions_enabled');
  bool get campaignsEnabled => isEnabled('campaigns_enabled');
  bool get redemptionsEnabled => isEnabled('redemptions_enabled');
  bool get profilesProgressionEnabled => isEnabled('profiles_progression_enabled');

  /// Subfeatures.
  bool get momentumEnabled => isEnabled('momentum_enabled');
  bool get badgesEnabled => isEnabled('badges_enabled');
  bool get storefrontEnabled => isEnabled('storefront_enabled');
  bool get missionClaimsEnabled => isEnabled('mission_claims_enabled');
  bool get rewardFulfillmentEnabled => isEnabled('reward_fulfillment_enabled');

  /// Role toggles.
  bool roleMissionsEnabled(String roleKey) => isEnabled('${roleKey}_missions_enabled');
  bool roleDashboardEnabled(String roleKey) => isEnabled('${roleKey}_dashboard_enabled');
  bool get publicProfileProgressionEnabled => isEnabled('public_profile_progression_enabled');
  bool get selfProfileProgressionEnabled => isEnabled('self_profile_progression_enabled');

  /// Kill switches (emergency).
  bool get killProgressionWritePaths => isEnabled('kill_progression_write_paths');
  bool get killMissionClaims => isEnabled('kill_mission_claims');
  bool get killRedemptions => isEnabled('kill_redemptions');
  bool get killBehaviorEventIngest => isEnabled('kill_behavior_event_ingest');
  bool get killCampaignJoins => isEnabled('kill_campaign_joins');
  bool get killStorefrontActions => isEnabled('kill_storefront_actions');

  /// A single place for the UI to decide if we should attempt *any* progression
  /// writes from the client.
  ///
  /// Important: backend still re-checks.
  bool get allowAnyWrite => progressionEnabled && !killProgressionWritePaths;

  /// Conservative “safe mode”: allow reading but block writes.
  static ProgressionFeaturePolicy safeFallback({String source = 'fallback'}) {
    return ProgressionFeaturePolicy(
      flags: const {
        // Read surfaces can render, but all sensitive actions are blocked.
        'progression_enabled': true,
        'missions_enabled': true,
        'campaigns_enabled': true,
        'redemptions_enabled': true,
        'profiles_progression_enabled': true,

        // Safe-mode kills writes until backend policy is confirmed.
        'kill_progression_write_paths': true,
        'kill_mission_claims': true,
        'kill_redemptions': true,
        'kill_behavior_event_ingest': true,
        'kill_campaign_joins': true,
        'kill_storefront_actions': true,

        // Default subfeature posture for UI: show modules only if explicitly
        // enabled by policy fetch.
        'momentum_enabled': false,
        'badges_enabled': false,
        'storefront_enabled': false,
        'mission_claims_enabled': false,
        'reward_fulfillment_enabled': false,
      },
      loadedAt: DateTime.now(),
      source: source,
    );
  }

  factory ProgressionFeaturePolicy.fromRpc(dynamic payload) {
    // Expected shape from Supabase RPC:
    // {
    //   "flags": {"progression_enabled": true, ...},
    //   "loaded_at": "2026-01-01T00:00:00Z",
    //   "source": "rpc"
    // }
    try {
      if (payload is Map) {
        final rawFlags = payload['flags'];
        final map = <String, bool>{};
        if (rawFlags is Map) {
          for (final e in rawFlags.entries) {
            final key = e.key.toString();
            final v = e.value;
            if (v is bool) map[key] = v;
            if (v is String) map[key] = v.toLowerCase() == 'true';
            if (v is num) map[key] = v != 0;
          }
        }
        final source = (payload['source'] ?? 'rpc').toString();
        final loadedAtRaw = (payload['loaded_at'] ?? payload['loadedAt'])?.toString();
        final loadedAt = loadedAtRaw == null ? DateTime.now() : (DateTime.tryParse(loadedAtRaw) ?? DateTime.now());
        if (map.isEmpty) return safeFallback(source: 'fallback_empty_policy');
        return ProgressionFeaturePolicy(flags: map, loadedAt: loadedAt, source: source);
      }
    } catch (_) {
      // Handled below.
    }
    return safeFallback(source: 'fallback_parse_error');
  }
}
