import 'package:flutter/foundation.dart';
import 'package:spotlight_connect/models/early_access_request_model.dart';
import 'package:spotlight_connect/supabase/supabase_config.dart';

class EarlyAccessService {
  static const String table = 'early_access_requests';

  Future<EarlyAccessRequestModel?> fetchLatestForEmail(String email) async {
    // IMPORTANT: Early access status lookup is intentionally disabled.
    // We do not disclose approval status to clients (anon or authed).
    //
    // Keep this method for API compatibility, but always fail closed.
    final normalized = email.toLowerCase().trim();
    if (normalized.isEmpty) return null;
    return null;
  }

  Future<EarlyAccessRequestModel> submitRequest({
    required String email,
    required String name,
    required String desiredRole,
    String? note,
  }) async {
    final normalized = email.toLowerCase().trim();
    try {
      final payload = {
        'email': normalized,
        'name': name.trim(),
        'desired_role': desiredRole,
        'status': 'pending',
        'note': note?.trim().isEmpty == true ? null : note?.trim(),
      };
      final rows = await SupabaseConfig.client.from(table).insert(payload).select();
      if (rows.isEmpty) throw 'Insert returned no rows';
      return EarlyAccessRequestModel.fromSupabase(rows.first);
    } catch (e) {
      debugPrint('EarlyAccessService.submitRequest failed: $e');
      rethrow;
    }
  }
}
