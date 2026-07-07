import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotlight_connect/models/studio_session_model.dart';

class StudioService extends ChangeNotifier {
  final SupabaseClient _client; // ignore: unused_field
  StudioService({required SupabaseClient client}) : _client = client;

  Future<Map<String, dynamic>> getAnalyticsSnapshot(String creatorId) async => {};

  Future<void> endSession(String roomId) async {}

  Future<void> scheduleSession({
    required String title,
    required DateTime scheduledFor,
  }) async {
    debugPrint("Scheduling $title for $scheduledFor");
  }

  Future<void> startExternalConsoleLive({
    required String title,
    required String url,
    required String? broadcasterUserId,
    required String? broadcasterDisplayName,
  }) async {
    debugPrint("Starting External Live: $title at $url");
  }

  Future<void> startRtmpLive({
    required String title,
    required String? broadcasterUserId,
    required String? broadcasterDisplayName,
  }) async {
    debugPrint("Starting RTMP: $title");
  }

  Future<StudioSessionModel?> startLiveKitLive({
    required String title,
    required String? broadcasterUserId,
    required String? broadcasterDisplayName,
    bool isAudioOnly = false,
  }) async {
    debugPrint("Starting LiveKit: $title (Audio Only: $isAudioOnly)");
    return null;
  }

  /// Obtain a LiveKit token for `participant` in `room`.
  ///
  /// This method attempts to call a Supabase RPC function named "livekit_token"
  /// that returns either a string token or an object containing a `token` field.
  /// If the RPC is not present (local/dev), this will return a small dev token
  /// placeholder string. Replace the RPC name and response parsing with your
  /// backend's contract if different.
  Future<String?> createLiveKitToken({
    required String room,
    required String participant,
  }) async {
    try {
      // If you have a Supabase Edge function or RPC that generates a LiveKit token,
      // call it here. The example uses rpc('livekit_token', params: {...}).
      final resp = await Supabase.instance.rpc('livekit_token', params: {
        'room': room,
        'participant': participant,
      });

      // Adapt the extraction depending on how your RPC returns the token:
      // - If it returns a map with {'token': '...'}
      if (resp is Map && resp['token'] != null) {
        return resp['token']?.toString();
      }

      // - If it returns a plain string token
      if (resp is String && resp.trim().isNotEmpty) {
        return resp;
      }

      // - Some Supabase RPCs return a List with a single map
      if (resp is List && resp.isNotEmpty) {
        final first = resp.first;
        if (first is Map && first['token'] != null) return first['token']?.toString();
      }

      debugPrint('createLiveKitToken: RPC returned unexpected shape: $resp');
    } catch (e) {
      debugPrint('createLiveKitToken failed: $e');
    }

    // Fallback for local/dev environments where the RPC isn't deployed.
    // Replace or remove this as soon as a real token backend exists.
    return 'dev_livekit_token';
  }

  // ignore: unused_element
  Future<List<StudioSessionModel>> _fetchRemoteSessions({int limit = 30}) async {
    try {
      final response = await Supabase.instance.client.from('live_sessions').select().limit(limit);
      return (response as List)
          .map((e) => StudioSessionModel.fromSupabaseRow(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to fetch remote sessions: $e');
      return [];
    }
  }
}