import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lightweight data class returned by [MessageService.getOrCreateThread].
class MessageThread {
  const MessageThread({
    required this.threadId,
    required this.participantUserIds,
  });

  final String threadId;
  final List<String> participantUserIds;
}

class MessageService extends ChangeNotifier {
  MessageService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  bool _isLoading = false;
  final List<MessageThread> _threads = [];

  bool get isLoading => _isLoading;

  List<MessageThread> get threads => List.unmodifiable(_threads);

  SupabaseClient get client => _client;

  Future<void> ensureInitialized() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final me = _client.auth.currentUser;
      if (me == null) return;
      final rows = await _client
          .from('message_threads')
          .select('id, participant_user_ids')
          .contains('participant_user_ids', [me.id])
          .order('updated_at', ascending: false)
          .limit(50);
      _threads
        ..clear()
        ..addAll(
          (rows as List).map(
            (r) => MessageThread(
              threadId: r['id'] as String,
              participantUserIds: List<String>.from(
                  r['participant_user_ids'] as List? ?? []),
            ),
          ),
        );
    } catch (_) {
      // Surface errors to QA harness via rethrow if needed.
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<MessageThread> threadsForUser(String userId) =>
      _threads.where((t) => t.participantUserIds.contains(userId)).toList();

  /// Creates or retrieves an existing thread for the given participants.
  ///
  /// [participantUserIds] – ordered list of user UUID strings.
  /// [participantNames]   – display names keyed by user id (informational).
  /// [participantEmails]  – emails keyed by user id (informational).
  /// [opportunityId]      – optional opportunity context for the thread.
  Future<MessageThread> getOrCreateThread({
    required List<String> participantUserIds,
    Map<String, String> participantNames = const {},
    Map<String, String> participantEmails = const {},
    String? opportunityId,
  }) async {
    // Look for an existing thread with exactly this set of participants.
    final sorted = [...participantUserIds]..sort();
    for (final t in _threads) {
      final ts = [...t.participantUserIds]..sort();
      if (ts.join(',') == sorted.join(',')) return t;
    }

    // Create a new thread row.
    final insertPayload = <String, dynamic>{
      'participant_user_ids': participantUserIds,
      if (opportunityId != null) 'opportunity_id': opportunityId,
    };
    final row = await _client
        .from('message_threads')
        .insert(insertPayload)
        .select('id, participant_user_ids')
        .single();

    final thread = MessageThread(
      threadId: row['id'] as String,
      participantUserIds:
          List<String>.from(row['participant_user_ids'] as List? ?? []),
    );
    _threads.insert(0, thread);
    notifyListeners();
    return thread;
  }

  /// Sends a message into an existing thread.
  ///
  /// [threadId]      – UUID of the target [MessageThread].
  /// [senderUserId]  – UUID of the authenticated sender.
  /// [senderName]    – display name for the sender (stored on the row).
  /// [body]          – message body text.
  Future<void> sendMessage({
    required String threadId,
    required String senderUserId,
    required String senderName,
    required String body,
  }) async {
    await _client.from('messages').insert({
      'thread_id': threadId,
      'sender_user_id': senderUserId,
      'sender_name': senderName,
      'body': body,
    });
  }
}
