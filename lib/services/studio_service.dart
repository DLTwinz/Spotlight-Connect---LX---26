import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudioService extends ChangeNotifier {
  StudioService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  bool _isLoading = false;

  SupabaseClient get client => _client;
  bool get isLoading => _isLoading;

  /// Creates a LiveKit token for [room] and [participant] via an Edge Function.
  ///
  /// Returns the JWT token string on success.
  Future<String> createLiveKitToken({
    required String room,
    required String participant,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _client.functions.invoke(
        'create_livekit_token',
        body: {'room': room, 'participant': participant},
      );
      if (res.status != 200) {
        throw StateError(
            'create_livekit_token failed (status ${res.status}): ${res.data}');
      }
      final data = res.data as Map<String, dynamic>;
      return data['token'] as String? ?? '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
