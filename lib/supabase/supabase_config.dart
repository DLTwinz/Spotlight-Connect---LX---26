import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _defaultUrl = 'https://mdwvokenmehdfybgujpa.supabase.co';
  // Classic JWT anon — required until project confirms publishable keys.
  static const String _defaultPublishableKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kd3Zva2VubWVoZGZ5Ymd1anBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyODAzMzUsImV4cCI6MjA5MTg1NjMzNX0.tds2VeVEl05jd3cbaC4vutxnLRtTF6i2d5MMAJS3KJk';

  static const String _envUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _envPublishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static String get url => _envUrl.isNotEmpty ? _envUrl : _defaultUrl;
  static String get publishableKey => _envPublishableKey.isNotEmpty
      ? _envPublishableKey
      : _defaultPublishableKey;

  static const String authRedirectOrigin =
      'io.supabase.spotlight://login-callback';

  static Future<void> initialize() async {
    if (url.isEmpty || publishableKey.isEmpty) {
      throw Exception(
        'Supabase configuration missing. Provide SUPABASE_URL/SUPABASE_ANON_KEY or set checked-in defaults.',
      );
    }

    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => Supabase.instance.client.auth;

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
