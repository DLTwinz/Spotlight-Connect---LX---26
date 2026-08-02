import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService extends ChangeNotifier {
  final SupabaseClient _client; // ignore: unused_field
  final dynamic _localCache; // ignore: unused_field
  List<Map<String, dynamic>> _joinedGroups = [];

  GroupService({required SupabaseClient client, required dynamic localCache})
    : _client = client,
      _localCache = localCache;

  List<Map<String, dynamic>> get joinedGroups => _joinedGroups;

  Future<void> fetchGroupsForUser(String userId) async {
    try {
      final data = await _client
          .from('group_members')
          .select('groups(*)')
          .eq('user_id', userId);
      _joinedGroups = List<Map<String, dynamic>>.from(data);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ GROUP RECOVERY FAILURE: $e');
    }
  }
}
