import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotlight_connect/models/studio_session_model.dart';

class StudioService extends ChangeNotifier {
  final SupabaseClient _client;
  StudioService({required SupabaseClient client}) : _client = client;

  Future<Map<String, dynamic>> getAnalyticsSnapshot(String creatorId) async {
    throw UnimplementedError(
      'Studio analytics snapshot is not implemented yet.',
    );
  }

  Future<void> endSession(String roomId) async {
    throw UnimplementedError('Ending studio sessions is not implemented yet.');
  }

  Future<void> scheduleSession({
    required String title,
    required DateTime scheduledFor,
  }) async {
    throw UnimplementedError(
      'Studio session scheduling is not implemented yet.',
    );
  }

  Future<void> startExternalConsoleLive({
    required String title,
    required String url,
    required String? broadcasterUserId,
    required String? broadcasterDisplayName,
  }) async {
    throw UnimplementedError(
      'External console live start is not implemented yet.',
    );
  }

  Future<void> startRtmpLive({
    required String title,
    required String? broadcasterUserId,
    required String? broadcasterDisplayName,
  }) async {
    throw UnimplementedError('RTMP live start is not implemented yet.');
  }

  Future<StudioSessionModel?> startLiveKitLive({
    required String title,
    required String? broadcasterUserId,
    required String? broadcasterDisplayName,
    bool isAudioOnly = false,
  }) async {
    throw UnimplementedError(
      'LiveKit live session start is not implemented yet.',
    );
  }

  Future<String?> createLiveKitToken({
    required String room,
    required String participant,
  }) async {
    try {
      final resp = await _client.rpc(
        'livekit_token',
        params: {'room': room, 'participant': participant},
      );

      if (resp is Map && resp['token'] != null) {
        return resp['token']?.toString();
      }

      if (resp is String && resp.trim().isNotEmpty) {
        return resp;
      }

      if (resp is List && resp.isNotEmpty) {
        final first = resp.first;
        if (first is Map && first['token'] != null) {
          return first['token']?.toString();
        }
      }

      debugPrint('createLiveKitToken: RPC returned unexpected shape: $resp');
      return null;
    } catch (e) {
      debugPrint('createLiveKitToken failed: $e');
      return null;
    }
  }

  Future<List<StudioSessionModel>> fetchRemoteSessions({int limit = 30}) async {
    try {
      final response = await _client
          .from('live_sessions')
          .select()
          .limit(limit);
      return (response as List)
          .map(
            (e) =>
                StudioSessionModel.fromSupabaseRow(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('Failed to fetch remote sessions: $e');
      return [];
    }
  }
}
