import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Supabase configuration for Spotlight Connect.
class SupabaseConfig {
  // Use the Project Ref from your key to form the correct URL
  static const String supabaseUrl = 'https://mdwvokenmehdfybgujpa.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kd3Zva2VubWVoZGZ5Ymd1anBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyODAzMzUsImV4cCI6MjA5MTg1NjMzNX0.tds2VeVEl05jd3cbaC4vutxnLRtTF6i2d5MMAJS3KJk';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: anonKey,
      debug: kDebugMode,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;

  /// Fetch the server-authoritative progression feature policy.
  static Future<Map<String, dynamic>> fetchProgressionFeaturePolicy({required String roleKey}) async {
    // 1) Try RPC (Remote Procedure Call) first.
    try {
      final res = await client.rpc('get_feature_policy', params: {'role': roleKey});
      if (res is Map) {
        final asMap = Map<String, dynamic>.from(res);
        asMap['source'] = (asMap['source'] ?? 'rpc').toString();
        asMap['loaded_at'] = (asMap['loaded_at'] ?? DateTime.now().toUtc().toIso8601String()).toString();
        return asMap;
      }
    } catch (e) {
      debugPrint('RPC failed: $e. Falling back to table read.');
    }

    // 2) Direct-table fallback.
    try {
      final flags = <String, bool>{};

      final policyRow = await client
          .from('feature_policies')
          .select('policy,is_enabled')
          .eq('role_key', roleKey)
          .maybeSingle();

      final policyEnabled = (policyRow?['is_enabled'] as bool?) ?? true;
      final rawPolicy = policyRow?['policy'];
      
      if (policyEnabled && rawPolicy is Map) {
        for (final entry in rawPolicy.entries) {
          final key = entry.key.toString();
          final v = entry.value;
          if (v is bool) flags[key] = v;
          if (v is String) flags[key] = v.toLowerCase() == 'true';
          if (v is num) flags[key] = v != 0;
        }
      }

      // Default flags if tables are empty
      if (policyRow == null || flags.isEmpty) {
        flags.addAll({
          'progression_enabled': true,
          'missions_enabled': true,
          'campaigns_enabled': true,
          'redemptions_enabled': true,
          'profiles_progression_enabled': true,
        });
      }

      final killRows = await client.from('kill_switches').select('key,is_enabled');
      for (final row in killRows) {
        final key = row['key']?.toString();
        if (key == null || key.isEmpty) continue;
        flags[key] = (row['is_enabled'] as bool?) ?? false;
            }
    
      return {
        'flags': flags,
        'loaded_at': DateTime.now().toUtc().toIso8601String(),
        'source': 'tables',
      };
    } catch (e) {
      debugPrint('Table fallback failed: $e');
      return {
        'flags': <String, dynamic>{},
        'loaded_at': DateTime.now().toUtc().toIso8601String(),
        'source': 'error',
      };
    }
  }

  static const bool enableCustomDomainRedirects = false;
  static const String customDomainOrigin = 'https://spotlightconnect.org';
  static String get authRedirectOrigin => enableCustomDomainRedirects ? customDomainOrigin : Uri.base.origin;
}

/// Generic database service for CRUD operations
class SupabaseService {
  static Future<List<Map<String, dynamic>>> select(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).select(select ?? '*');
      if (filters != null) filters.forEach((k, v) => query = query.eq(k, v));
      if (orderBy != null) query = query.order(orderBy, ascending: ascending);
      if (limit != null) query = query.limit(limit);
      return await query;
    } catch (e) {
      throw _handleError('select', table, e);
    }
  }

  static Future<Map<String, dynamic>?> selectSingle(
    String table, {
    String? select,
    required Map<String, dynamic> filters,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).select(select ?? '*');
      filters.forEach((k, v) => query = query.eq(k, v));
      return await query.maybeSingle();
    } catch (e) {
      throw _handleError('selectSingle', table, e);
    }
  }

  static Future<List<Map<String, dynamic>>> insert(String table, Map<String, dynamic> data) async {
    try {
      return await SupabaseConfig.client.from(table).insert(data).select();
    } catch (e) {
      throw _handleError('insert', table, e);
    }
  }

  static Future<List<Map<String, dynamic>>> update(
    String table, 
    Map<String, dynamic> data, {
    required Map<String, dynamic> filters,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).update(data);
      filters.forEach((k, v) => query = query.eq(k, v));
      return await query.select();
    } catch (e) {
      throw _handleError('update', table, e);
    }
  }

  static Future<void> delete(String table, {required Map<String, dynamic> filters}) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).delete();
      filters.forEach((k, v) => query = query.eq(k, v));
      await query;
    } catch (e) {
      throw _handleError('delete', table, e);
    }
  }

  static String _handleError(String op, String table, dynamic e) {
    final msg = e is PostgrestException ? e.message : e.toString();
    return 'Failed to $op from $table: $msg';
  }
}

// Global variable for easier access
final supabase = SupabaseConfig.client;