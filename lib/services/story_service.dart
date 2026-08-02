import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryService extends ChangeNotifier {
  final SupabaseClient _client; // ignore: unused_field
  final dynamic _localCache; // ignore: unused_field
  List<Map<String, dynamic>> _activeStories = [];

  StoryService({required SupabaseClient client, required dynamic localCache})
    : _client = client,
      _localCache = localCache;

  List<Map<String, dynamic>> get activeStories => _activeStories;

  Future<void> syncActiveStories() async {
    try {
      final data = await _client
          .from('stories')
          .select('*, profiles(username)')
          .gt('expires_at', DateTime.now().toIso8601String());
      _activeStories = List<Map<String, dynamic>>.from(data);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ STORIES ENGINE SYNC ERROR: $e');
    }
  }
}
