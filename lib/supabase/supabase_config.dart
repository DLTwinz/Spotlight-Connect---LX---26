import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _defaultUrl = 'https://mdwvokenmehdfybgujpa.supabase.co';

  /// Classic JWT anon — verified against Auth API for this project.
  static const String _defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kd3Zva2VubWVoZGZ5Ymd1anBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyODAzMzUsImV4cCI6MjA5MTg1NjMzNX0.tds2VeVEl05jd3cbaC4vutxnLRtTF6i2d5MMAJS3KJk';

  static const String _envUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static String get url => _envUrl.isNotEmpty ? _envUrl : _defaultUrl;

  /// Public client key only (anon / publishable). Never service_role.
  static String get anonKey {
    final fromEnv = _envAnonKey.trim();
    if (fromEnv.isEmpty) return _defaultAnonKey;
    return fromEnv;
  }

  /// Alias for older call sites / docs.
  static String get publishableKey => anonKey;

  static const String authRedirectOrigin =
      'io.supabase.spotlight://login-callback';

  static void _assertSafeClientKey(String key) {
    final k = key.trim();
    if (k.isEmpty) {
      throw Exception('Supabase anon key is empty.');
    }
    if (k.contains('PASTE_') ||
        k.contains('YOUR_ANON') ||
        k.contains('YOUR_SUPABASE')) {
      throw Exception(
        'Supabase key is still a placeholder. Use Dashboard anon public JWT (role=anon).',
      );
    }
    if (k.startsWith('sb_secret_')) {
      throw Exception('Refusing secret key in the Flutter client.');
    }
    if (k.startsWith('eyJ')) {
      try {
        final parts = k.split('.');
        if (parts.length >= 2) {
          var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
          final mod = payload.length % 4;
          if (mod > 0) payload += '=' * (4 - mod);
          final bytes = _base64Decode(payload);
          final json = String.fromCharCodes(bytes);
          if (json.contains('service_role')) {
            throw Exception(
              'Refusing service_role key in the Flutter client. Use anon public only.',
            );
          }
        }
      } catch (e) {
        if (e is Exception && e.toString().contains('service_role')) rethrow;
      }
    }
  }

  static List<int> _base64Decode(String input) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final cleaned = input.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
    final out = <int>[];
    var buf = 0;
    var bits = 0;
    for (final c in cleaned.codeUnits) {
      if (c == 61) break;
      final v = chars.codeUnits.indexOf(c);
      if (v < 0) continue;
      buf = (buf << 6) | v;
      bits += 6;
      if (bits >= 8) {
        bits -= 8;
        out.add((buf >> bits) & 0xff);
      }
    }
    return out;
  }

  static Future<void> initialize() async {
    final key = anonKey;
    _assertSafeClientKey(key);

    if (kDebugMode) {
      final prefix = key.length > 12 ? key.substring(0, 12) : key;
      debugPrint('SupabaseConfig: url=$url keyPrefix=$prefix…');
    }

    await Supabase.initialize(
      url: url,
      anonKey: key,
      publishableKey: key,
    );
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
