import 'package:flutter/foundation.dart';
import 'package:spotlight_connect/backend/backend_mode.dart';
import 'package:spotlight_connect/models/message_model.dart';
import 'package:spotlight_connect/models/message_thread_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageService extends ChangeNotifier {
  MessageService();

  bool _initialized = false;
  bool _loading = false;
  List<MessageThreadModel> _threads = const [];
  List<MessageModel> _messages = const [];

  bool get isLoading => _loading;
  List<MessageThreadModel> get threads => _threads;

  SupabaseClient get _db => Supabase.instance.client;
  String? get _uid => _db.auth.currentUser?.id;
  bool get _useSupabase => BackendConfig.mode == BackendMode.supabase;

  List<MessageThreadModel> threadsForUser(String userId) {
    final list = _threads.where((t) => t.participantUserIds.contains(userId)).toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  List<MessageModel> messagesForThread(String threadId) {
    final list = _messages.where((m) => m.threadId == threadId).toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  int unreadCountForUser(String userId) {
    var total = 0;
    for (final t in _threads) {
      total += t.unreadCounts[userId] ?? 0;
    }
    return total;
  }

  Future<void> ensureInitialized() async {
    if (_initialized || _loading) return;
    _loading = true;
    notifyListeners();
    try {
      if (_useSupabase) await _refreshFromSupabase();
      _initialized = true;
    } catch (e) {
      debugPrint('MessageService init failed: $e');
      _threads = const [];
      _messages = const [];
      _initialized = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<MessageThreadModel> getOrCreateThread({
    required List<String> participantUserIds,
    required Map<String, String> participantNames,
    required Map<String, String> participantEmails,
    String? opportunityId,
  }) async {
    await ensureInitialized();
    final ids = [...participantUserIds]..sort();
    final key = '${opportunityId ?? 'direct'}::${ids.join('|')}';
    final existing = _threads.where((t) => t.threadId == key).toList();
    if (existing.isNotEmpty) return existing.first;

    final thread = MessageThreadModel(
      threadId: key,
      opportunityId: opportunityId,
      participantUserIds: ids,
      participantNames: participantNames,
      participantEmails: participantEmails,
      updatedAt: DateTime.now(),
      unreadCounts: {for (final id in ids) id: 0},
      lastReadAtByUserId: {for (final id in ids) id: DateTime.fromMillisecondsSinceEpoch(0)},
    );
    if (_uid == null) {
      debugPrint('MessageService: cannot create thread when logged out');
      return thread;
    }

    try {
      await _db.from('message_threads').upsert(_threadToRow(thread), onConflict: 'thread_id');
    } catch (e) {
      debugPrint('MessageService create thread failed: $e');
    }

    _threads = [thread, ..._threads];
    notifyListeners();
    return thread;
  }

  Future<void> sendMessage({
    required String threadId,
    required String senderUserId,
    required String senderName,
    required String body,
  }) async {
    await ensureInitialized();
    final text = body.trim();
    if (text.isEmpty) return;

    final msg = MessageModel(
      messageId: '${DateTime.now().microsecondsSinceEpoch}',
      threadId: threadId,
      senderUserId: senderUserId,
      senderName: senderName,
      body: text,
      createdAt: DateTime.now(),
    );

    if (_uid == null) {
      debugPrint('MessageService: cannot send message when logged out');
      return;
    }

    try {
      await _db.from('messages').insert({
        'thread_id': threadId,
        'sender_user_id': senderUserId,
        'sender_name': senderName,
        'body': msg.body,
      });
    } catch (e) {
      debugPrint('MessageService sendMessage insert failed: $e');
    }

    _messages = [..._messages, msg];

    final idx = _threads.indexWhere((t) => t.threadId == threadId);
    if (idx != -1) {
      final t = _threads[idx];
      final updatedCounts = Map<String, int>.from(t.unreadCounts);
      final reads = Map<String, DateTime>.from(t.lastReadAtByUserId);
      reads[senderUserId] = msg.createdAt;
      for (final uid in t.participantUserIds) {
        if (uid == senderUserId) continue;
        updatedCounts[uid] = (updatedCounts[uid] ?? 0) + 1;
      }
      final updated = t.copyWith(
        updatedAt: msg.createdAt,
        lastMessagePreview: msg.body.length > 90 ? '${msg.body.substring(0, 90)}…' : msg.body,
        lastSenderUserId: senderUserId,
        unreadCounts: updatedCounts,
        lastReadAtByUserId: reads,
      );
      _threads = [updated, ..._threads.where((e) => e.threadId != threadId)];

      if (_useSupabase) {
        try {
          await _db.from('message_threads').update({
            'updated_at': updated.updatedAt.toIso8601String(),
            'last_message_preview': updated.lastMessagePreview,
            'last_sender_user_id': updated.lastSenderUserId,
            'unread_counts': updated.unreadCounts,
            'last_read_at_by_user_id': updated.lastReadAtByUserId.map((k, v) => MapEntry(k, v.toIso8601String())),
          }).eq('thread_id', threadId);
        } catch (e) {
          debugPrint('MessageService sendMessage thread update failed: $e');
        }
      }
    }

    notifyListeners();
  }

  Future<void> markThreadRead({required String threadId, required String userId}) async {
    await ensureInitialized();
    final idx = _threads.indexWhere((t) => t.threadId == threadId);
    if (idx == -1) return;
    final t = _threads[idx];
    final updatedCounts = Map<String, int>.from(t.unreadCounts);
    updatedCounts[userId] = 0;
    final reads = Map<String, DateTime>.from(t.lastReadAtByUserId);
    reads[userId] = DateTime.now();
    final updated = t.copyWith(unreadCounts: updatedCounts, lastReadAtByUserId: reads);
    _threads = [updated, ..._threads.where((e) => e.threadId != threadId)];

    if (_useSupabase) {
      try {
        await _db.from('message_threads').update({
          'unread_counts': updated.unreadCounts,
          'last_read_at_by_user_id': updated.lastReadAtByUserId.map((k, v) => MapEntry(k, v.toIso8601String())),
        }).eq('thread_id', threadId);
      } catch (e) {
        debugPrint('MessageService markThreadRead failed: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _refreshFromSupabase() async {
    final uid = _uid;
    if (uid == null) {
      _threads = const [];
      _messages = const [];
      return;
    }
    try {
      final threadRows = await _db
          .from('message_threads')
          .select()
          .contains('participant_user_ids', [uid])
          .order('updated_at', ascending: false);
      _threads = (threadRows as List)
          .whereType<Map>()
          .map((e) => _threadFromRow(e.map((k, v) => MapEntry(k.toString(), v))))
          .toList();

      final threadIds = _threads.map((t) => t.threadId).toList();
      if (threadIds.isEmpty) {
        _messages = const [];
        return;
      }

      final messageRows = await _db
          .from('messages')
          .select()
          .inFilter('thread_id', threadIds)
          .order('created_at', ascending: true);
      _messages = (messageRows as List)
          .whereType<Map>()
          .map((e) => _messageFromRow(e.map((k, v) => MapEntry(k.toString(), v))))
          .toList();

    } catch (e) {
      debugPrint('MessageService refreshFromSupabase failed: $e');
      rethrow;
    }
  }

  MessageThreadModel _threadFromRow(Map<String, dynamic> row) {
    DateTime parseTs(dynamic v) => v is String ? (DateTime.tryParse(v) ?? DateTime.now()) : (v is DateTime ? v : DateTime.now());

    final participantIds = (row['participant_user_ids'] as List? ?? const []).map((e) => e.toString()).toList();
    final rawNames = (row['participant_names'] as Map? ?? const {}).map((k, v) => MapEntry(k.toString(), v.toString()));
    final rawEmails = (row['participant_emails'] as Map? ?? const {}).map((k, v) => MapEntry(k.toString(), v.toString()));

    final rawUnread = (row['unread_counts'] as Map? ?? const {}).map((k, v) {
      final n = (v is num) ? v.toInt() : int.tryParse(v.toString()) ?? 0;
      return MapEntry(k.toString(), n);
    });

    final rawReads = (row['last_read_at_by_user_id'] as Map? ?? const {});
    final reads = <String, DateTime>{
      for (final e in rawReads.entries)
        e.key.toString(): DateTime.tryParse(e.value.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
    };

    return MessageThreadModel(
      threadId: (row['thread_id'] ?? '').toString(),
      opportunityId: row['opportunity_id']?.toString(),
      participantUserIds: participantIds,
      participantNames: Map<String, String>.from(rawNames),
      participantEmails: Map<String, String>.from(rawEmails),
      updatedAt: parseTs(row['updated_at']),
      lastMessagePreview: row['last_message_preview']?.toString(),
      lastSenderUserId: row['last_sender_user_id']?.toString(),
      unreadCounts: Map<String, int>.from(rawUnread),
      lastReadAtByUserId: reads,
    );
  }

  Map<String, dynamic> _threadToRow(MessageThreadModel t) {
    return {
      'thread_id': t.threadId,
      'opportunity_id': t.opportunityId,
      'participant_user_ids': t.participantUserIds,
      'participant_names': t.participantNames,
      'participant_emails': t.participantEmails,
      'updated_at': t.updatedAt.toIso8601String(),
      'last_message_preview': t.lastMessagePreview,
      'last_sender_user_id': t.lastSenderUserId,
      'unread_counts': t.unreadCounts,
      'last_read_at_by_user_id': t.lastReadAtByUserId.map((k, v) => MapEntry(k, v.toIso8601String())),
    };
  }

  MessageModel _messageFromRow(Map<String, dynamic> row) {
    DateTime parseTs(dynamic v) => v is String ? (DateTime.tryParse(v) ?? DateTime.now()) : (v is DateTime ? v : DateTime.now());
    return MessageModel(
      messageId: (row['id'] ?? '').toString(),
      threadId: (row['thread_id'] ?? '').toString(),
      senderUserId: (row['sender_user_id'] ?? '').toString(),
      senderName: (row['sender_name'] ?? '').toString(),
      body: (row['body'] ?? '').toString(),
      createdAt: parseTs(row['created_at']),
    );
  }

}
