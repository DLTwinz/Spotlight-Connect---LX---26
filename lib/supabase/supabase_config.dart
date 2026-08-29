import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _defaultUrl = 'https://mdwvokenmehdfybgujpa.supabase.co';

  /// Public client key only. Never a service-role or secret key.
  static const String _defaultPublishableKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kd3Zva2VubWVoZGZ5Ymd1anBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyODAzMzUsImV4cCI6MjA5MTg1NjMzNX0.tds2VeVEl05jd3cbaC4vutxnLRtTF6i2d5MMAJS3KJk';

  static const String _envUrl = String.fromEnvironment('SUPABASE_URL');

  static const String _envPublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static String get url => _envUrl.isNotEmpty ? _envUrl : _defaultUrl;

  /// Retained as a compatibility alias for existing call sites.
  static String get anonKey => publishableKey;

  static String get publishableKey {
    final fromEnv = _envPublishableKey.trim();
    if (fromEnv.isNotEmpty) return fromEnv;
    return _defaultPublishableKey;
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => Supabase.instance.client.auth;

  static Future<void> initialize() async {
    final key = publishableKey;
    _assertSafeClientKey(key);

    if (kDebugMode) {
      final prefix = key.length > 12 ? key.substring(0, 12) : key;
      debugPrint('Supabase public client key prefix: $prefix...');
    }

    await Supabase.initialize(url: url, publishableKey: key);
  }

  static void _assertSafeClientKey(String key) {
    if (key.isEmpty) {
      throw StateError(
        'Missing Supabase publishable key. '
        'Set SUPABASE_PUBLISHABLE_KEY or configure the default public key.',
      );
    }

    if (key.startsWith('sb_secret_')) {
      throw StateError(
        'A Supabase secret key must never be included in a Flutter client.',
      );
    }
  }

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
