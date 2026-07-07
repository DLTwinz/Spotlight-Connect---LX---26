import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryService extends ChangeNotifier {
  StoryService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  final List<Map<String, dynamic>> _localCache = [];

  SupabaseClient get client => _client;
  List<Map<String, dynamic>> get stories => List.unmodifiable(_localCache);

  Future<void> ensureInitialized() async {
    final me = _client.auth.currentUser;
    if (me == null) return;
    final rows = await _client
        .from('stories')
        .select('*')
        .order('created_at', ascending: false)
        .limit(50);
    _localCache
      ..clear()
      ..addAll(List<Map<String, dynamic>>.from(rows as List));
    notifyListeners();
  }
}
