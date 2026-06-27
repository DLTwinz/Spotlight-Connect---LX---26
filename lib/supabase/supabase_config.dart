import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://mdwvokenmehdfybgujpa.supabase.co';
  static const String publishableKey =
      'sb_publishable_7ZMEpOxAswhuGle_wkqJWw_gYJRmmKq';

  /// Routing boundary origin for third-party OAuth and handshake redirects
  static const String authRedirectOrigin =
      'io.supabase.spotlight://login-callback';

  /// Core initialization layer called during application startup sequence
  static Future<void> initialize() async {
    await Supabase.initialize(url: 'https://mdwvokenmehdfybgujpa.supabase.co', publishableKey: 'YOUR_ANON_KEY_HERE');
  }

  /// Global telemetry client routing layer used across active operational services
  static SupabaseClient get client => Supabase.instance.client;

  /// Global session identity and token management broker
  static GoTrueClient get auth => Supabase.instance.client.auth;

  /// Telemetry hook to pull progression policy mappings directly from the database layer
  static Future<dynamic> fetchProgressionFeaturePolicy({
    dynamic roleKey,
  }) async {
    try {
      final query = client.from('progression_feature_policies').select();
      if (roleKey != null) {
        return await query.eq('role_key', roleKey).maybeSingle();
      }
      return await query.maybeSingle();
    } catch (_) {
      return null;
    }
  }
}
