import 'package:supabase_flutter/supabase_flutter.dart';

class VerifiedFandomClient {
  // Access the singleton client directly from the Supabase package
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> addStamp({
    required String stampId,
    required String userId,
  }) async {
    try {
      await _supabase.from('verified_stamps').insert({
        'stamp_id': stampId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to record stamp: $e');
    }
  }
}
