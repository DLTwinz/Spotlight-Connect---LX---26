import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudioService extends ChangeNotifier {
  final SupabaseClient _client; // ignore: unused_field
  StudioService({required SupabaseClient client}) : _client = client;

  Future<Map<String, dynamic>> getAnalyticsSnapshot(String creatorId) async => {};
  
  Future<String> createLiveKitToken(String roomId) async => 'livekit_token';
  Future<void> endSession(String roomId) async {}
}
