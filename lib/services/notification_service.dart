import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService extends ChangeNotifier {
  final SupabaseClient _client;
  List<Map<String, dynamic>> _notifications = [];

  NotificationService({required SupabaseClient client}) : _client = client;

  List<Map<String, dynamic>> get notifications => _notifications;

  void startLiveNotificationStream(String userId) {
    _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .order('created_at', ascending: false)
        .listen((data) {
          _notifications = data;
          notifyListeners();
        }, onError: (err) {
          debugPrint('‼️ NOTIFICATION PIPELINE ERROR: $err');
        });
  }
}
