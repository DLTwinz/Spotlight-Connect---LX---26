import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotlight_connect/models/studio_session_model.dart';

class StudioService extends ChangeNotifier {
  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<StudioSessionModel> _sessions = [];
  List<StudioSessionModel> get sessions => _sessions;

  StudioSessionModel? get liveSession => null;

  Future<void> ensureInitialized() async {}

  Future<void> endSession(String sessionId) async {}

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

  Future<String?> createLiveKitToken({
    required String room,
    required String participant,
  }) async {
    return null;
  }

  // ignore: unused_element
  Future<List<StudioSessionModel>> _fetchRemoteSessions({int limit = 30}) async {
    try {
      final response = await Supabase.instance.client
          .from('live_sessions')
          .select()
          .limit(limit);
      return (response as List)
          .map((e) => StudioSessionModel.fromSupabaseRow(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to fetch remote sessions: $e');
      return [];
    }
  }
}
