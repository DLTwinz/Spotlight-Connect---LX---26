import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotlight_connect/models/studio_session_model.dart';

class StudioService extends ChangeNotifier {
  final SupabaseClient _client;
  final bool _isLoading = false;

  StudioService({required SupabaseClient client}) : _client = client;

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

  /// Obtain a LiveKit token for `participant` in `room`.
  ///
  /// Calls the Supabase Edge Function named "livekit_token" via the Functions API
  /// on the injected client and parses several common response shapes.
  Future<String?> createLiveKitToken({
    required String room,
    required String participant,
  }) async {
    try {
      final fnResp = await _client.functions.invoke(
        'livekit_token',
        body: {'room': room, 'participant': participant},
      );

      // The Functions API returns a FunctionResponse; its `.data` property
      // contains the function payload (could be String, Map, List, etc).
      final data = fnResp.data;
      if (data == null) {
        debugPrint('createLiveKitToken: function returned no data');
        return null;
      }

      // 1) Plain string token payload
      if (data is String) {
        final s = data.trim();
        if (s.isNotEmpty) return s;
      }

      // 2) Map with token key or data wrapper
      if (data is Map) {
        if (data.containsKey('token') && data['token'] != null)
          return data['token'].toString();
        if (data.containsKey('data')) {
          final inner = data['data'];
          if (inner is String) {
            final s = inner.trim();
            if (s.isNotEmpty) return s;
          }
          if (inner is Map &&
              inner.containsKey('token') &&
              inner['token'] != null) {
            return inner['token'].toString();
          }
        }
      }

      // 3) List with first element containing token
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map &&
            first.containsKey('token') &&
            first['token'] != null) {
          return first['token'].toString();
        }
      }

      debugPrint(
        'createLiveKitToken: unexpected function response shape: ${data.runtimeType}',
      );
    } catch (e, st) {
      debugPrint('createLiveKitToken failed: $e\n$st');
    }

    // Local/dev fallback — return null here if you prefer the UI to surface an error
    // when the function is not deployed.
    return 'dev_livekit_token';
  }

  // ignore: unused_element
  Future<List<StudioSessionModel>> _fetchRemoteSessions({
    int limit = 30,
  }) async {
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
