import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageService extends ChangeNotifier {
  final SupabaseClient _client;
  final bool _isLoading = false;

  MessageService({required SupabaseClient client}) : _client = client;

  bool get isLoading => _isLoading;
  List<dynamic> get threads => [];

  Future<void> ensureInitialized() async {}

  List<dynamic> threadsForUser(String userId) => [];
  
  Future<String> getOrCreateThread(String otherUserId) async => 'live_thread';

  Future<void> sendMessage(String threadId, String text) async {}
}
