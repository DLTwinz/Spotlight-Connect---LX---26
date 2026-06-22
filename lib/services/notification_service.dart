import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:spotlight_connect/backend/backend_mode.dart';
import 'package:spotlight_connect/models/notification_model.dart';
import 'package:spotlight_connect/storage/key_value_store.dart';
import 'package:spotlight_connect/supabase/supabase_config.dart';

class NotificationService extends ChangeNotifier {
  NotificationService({KeyValueStore? store}) : _store = store ?? createKeyValueStore();

  final KeyValueStore _store;

  bool get _useSupabase => BackendConfig.mode == BackendMode.supabase;

  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  String? _currentEmail;
  String? get currentEmail => _currentEmail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<NotificationModel> _items = const [];
  List<NotificationModel> get items => _items;

  int get unreadCount => _items.where((n) => !n.read).length;

  String _keyFor(String email) => 'spotlight_notifications_${email.toLowerCase().trim()}_v1';

  Future<void> setCurrentUser({String? userId, String? email}) async {
    final normalizedEmail = email?.toLowerCase().trim();
    final nextUserId = userId?.trim();
    final same = _currentUserId == nextUserId && _currentEmail == normalizedEmail;
    if (same) return;

    _currentUserId = (nextUserId == null || nextUserId.isEmpty) ? null : nextUserId;
    _currentEmail = (normalizedEmail == null || normalizedEmail.isEmpty) ? null : normalizedEmail;
    _items = const [];
    notifyListeners();

    if (_useSupabase) {
      if (_currentUserId != null) await _loadRemote();
      return;
    }
    if (_currentEmail != null) await _loadLocal();
  }

  Future<void> setCurrentUserEmail(String? email) async {
    // Backwards-compatible API used by the dashboard shell.
    await setCurrentUser(userId: SupabaseConfig.auth.currentUser?.id, email: email);
  }

  Future<void> pushToUser({
    required String email,
    required String type,
    required String title,
    required String body,
    String? entityId,
  }) async {
    if (_useSupabase) {
      // Intentionally disabled: querying public.users by email from the client is a privacy/RLS risk.
      // In Supabase mode, send notifications via server-side logic (edge function / trigger) or target by user_id.
      debugPrint('NotificationService.pushToUser is disabled in Supabase mode. Use pushToUserId instead.');
      return;
    }

    final normalized = email.toLowerCase().trim();
    if (normalized.isEmpty) return;
    final now = DateTime.now();
    final n = NotificationModel(
      notificationId: 'n_${now.microsecondsSinceEpoch}',
      type: type,
      title: title,
      body: body,
      entityId: entityId,
      createdAt: now,
      read: false,
    );

    // Update stored list for that user.
    final existing = await _loadForEmail(normalized);
    final next = [n, ...existing];
    await _persistForEmail(normalized, next);

    // If it matches current user, update in-memory.
    if (_currentEmail == normalized) {
      _items = next;
      notifyListeners();
    }
  }

  Future<void> pushToUserId({
    required String userId,
    required String type,
    required String title,
    required String body,
    String? entityId,
  }) async {
    if (!_useSupabase) {
      debugPrint('NotificationService.pushToUserId is only supported in Supabase mode');
      return;
    }
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) return;
    try {
      final now = DateTime.now().toUtc();
      await SupabaseConfig.client.from('notifications').insert({
        'user_id': normalizedUserId,
        'type': type,
        'title': title,
        'body': body,
        'entity_id': entityId,
        'created_at': now.toIso8601String(),
        'read': false,
      });
      if (_currentUserId == normalizedUserId) {
        await _loadRemote();
      }
    } catch (e) {
      debugPrint('NotificationService.pushToUserId failed: $e');
    }
  }

  Future<void> markAllRead() async {
    if (_useSupabase) {
      final uid = _currentUserId;
      if (uid == null || uid.isEmpty) return;
      try {
        await SupabaseConfig.client.from('notifications').update({'read': true}).eq('user_id', uid).eq('read', false);
        await _loadRemote();
      } catch (e) {
        debugPrint('NotificationService.markAllRead failed: $e');
      }
      return;
    }

    if (_currentEmail == null || _currentEmail!.isEmpty) return;
    _items = _items.map((e) => e.read ? e : e.copyWith(read: true)).toList();
    notifyListeners();
    await _persistForEmail(_currentEmail!, _items);
  }

  Future<void> markRead(String id) async {
    if (_useSupabase) {
      final uid = _currentUserId;
      if (uid == null || uid.isEmpty) return;
      try {
        await SupabaseConfig.client.from('notifications').update({'read': true}).eq('user_id', uid).eq('id', id);
        await _loadRemote();
      } catch (e) {
        debugPrint('NotificationService.markRead failed: $e');
      }
      return;
    }

    if (_currentEmail == null || _currentEmail!.isEmpty) return;
    final idx = _items.indexWhere((e) => e.notificationId == id);
    if (idx == -1) return;
    _items[idx] = _items[idx].copyWith(read: true);
    notifyListeners();
    await _persistForEmail(_currentEmail!, _items);
  }

  Future<void> _loadLocal() async {
    if (_currentEmail == null || _currentEmail!.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _loadForEmail(_currentEmail!);
    } catch (e) {
      debugPrint('NotificationService: load failed: $e');
      _items = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadRemote() async {
    final uid = _currentUserId;
    if (uid == null || uid.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      final rows = (await SupabaseConfig.client
          .from('notifications')
          .select('id,type,title,body,entity_id,created_at,read')
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(200)) as List<dynamic>;
      final parsed = <NotificationModel>[];
      for (final raw in rows) {
        if (raw is! Map) continue;
        final map = raw.map((k, v) => MapEntry(k.toString(), v));
        parsed.add(
          NotificationModel(
            notificationId: (map['id'] ?? '').toString(),
            type: (map['type'] ?? '').toString(),
            title: (map['title'] ?? '').toString(),
            body: (map['body'] ?? '').toString(),
            entityId: (map['entity_id'] ?? '').toString().trim().isEmpty ? null : (map['entity_id'] ?? '').toString(),
            createdAt: DateTime.tryParse((map['created_at'] ?? '').toString())?.toLocal() ?? DateTime.now(),
            read: map['read'] == true,
          ),
        );
      }
      _items = parsed;
    } catch (e) {
      debugPrint('NotificationService: loadRemote failed: $e');
      _items = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<NotificationModel>> _loadForEmail(String email) async {
    try {
      final raw = await _store.getString(_keyFor(email));
      if (raw == null || raw.trim().isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final items = <NotificationModel>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final m = NotificationModel.fromJson(item);
          if (m.notificationId.isNotEmpty) items.add(m);
        } else if (item is Map) {
          final m = NotificationModel.fromJson(item.map((k, v) => MapEntry(k.toString(), v)));
          if (m.notificationId.isNotEmpty) items.add(m);
        }
      }
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    } catch (e) {
      debugPrint('NotificationService: loadForEmail failed: $e');
      return const [];
    }
  }

  Future<void> _persistForEmail(String email, List<NotificationModel> items) async {
    try {
      await _store.setString(_keyFor(email), jsonEncode(items.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('NotificationService: persist failed: $e');
    }
  }

  // No seed notifications. Notifications should come from real events.
}
