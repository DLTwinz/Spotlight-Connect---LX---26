import 'package:supabase_flutter/supabase_flutter.dart';

class MissionComposerService {
  final SupabaseClient _client;
  MissionComposerService({required SupabaseClient client}) : _client = client;

  Future<void> submitComposedMission(
    Map<String, dynamic> missionPayload,
  ) async {
    await _client.from('missions').insert(missionPayload);
  }
}
