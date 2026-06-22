import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:spotlight_connect/backend/backend_mode.dart';
import 'package:spotlight_connect/models/story_model.dart';
import 'package:spotlight_connect/storage/key_value_store.dart';
import 'package:spotlight_connect/supabase/supabase_config.dart';

class StoryService extends ChangeNotifier {
  static const _storiesKey = 'spotlight_stories_v1';
  static const _seenKey = 'spotlight_story_seen_v1';

  final KeyValueStore _store;
  bool _initialized = false;
  bool _isLoading = false;
  List<StoryModel> _stories = const <StoryModel>[];
  final Map<String, Set<String>> _seenByUserId = <String, Set<String>>{};

  StoryService({KeyValueStore? store}) : _store = store ?? createKeyValueStore();

  bool get isLoading => _isLoading;
  List<StoryModel> get stories => _stories.where((s) => !s.isExpired).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    await _load();
  }

  bool isSeen({required String userId, required String storyId}) => _seenByUserId[userId]?.contains(storyId) ?? false;

  int unseenCountForAuthor({required String userId, required String authorId}) {
    final items = stories.where((s) => s.authorId == authorId).toList();
    if (items.isEmpty) return 0;
    final seen = _seenByUserId[userId] ?? const <String>{};
    return items.where((s) => !seen.contains(s.storyId)).length;
  }

  Future<void> markSeen({required String userId, required String storyId}) async {
    final set = _seenByUserId.putIfAbsent(userId, () => <String>{});
    if (!set.add(storyId)) return;
    notifyListeners();
    if (BackendConfig.mode == BackendMode.supabase) {
      await _markSeenRemote(userId: userId, storyId: storyId);
      return;
    }
    await _persistSeen();
  }

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (BackendConfig.mode == BackendMode.supabase) {
        await _loadSeenRemote();
        await _loadRemoteStories();
        return;
      }

      await _loadSeen();

      final raw = await _store.getString(_storiesKey);
      if (raw == null || raw.trim().isEmpty) {
        _stories = _seedStories();
        await _persistStories();
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _stories = _seedStories();
        await _persistStories();
        return;
      }

      final parsed = <StoryModel>[];
      for (final item in decoded) {
        final story = StoryModel.tryFromJson(item);
        if (story != null) parsed.add(story);
      }

      if (parsed.isEmpty) {
        _stories = _seedStories();
        await _persistStories();
      } else {
        _stories = parsed;
        if (parsed.length != decoded.length) await _persistStories();
      }
    } catch (e) {
      debugPrint('StoryService failed to load: $e');
      if (BackendConfig.mode == BackendMode.supabase) {
        _stories = const <StoryModel>[];
      } else {
        _stories = _seedStories();
        try {
          await _persistStories();
        } catch (e) {
          debugPrint('StoryService failed to persist seed stories: $e');
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadRemoteStories() async {
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) {
      _stories = const <StoryModel>[];
      return;
    }

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final rows = await SupabaseConfig.client
        .from('stories')
        .select('id,author_id,author_display_name,author_primary_role,caption,background_seed,created_at,expires_at')
        .gt('expires_at', nowIso)
        .order('created_at', ascending: false)
        .limit(100);

    final parsed = <StoryModel>[];
    for (final raw in rows) {
      final story = StoryModel.fromSupabaseRow(raw);
      if (story != null && !story.isExpired) parsed.add(story);
    }
      _stories = parsed;
  }

  Future<void> _loadSeenRemote() async {
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) {
      _seenByUserId.clear();
      return;
    }
    try {
      final rows = await SupabaseConfig.client.from('story_seen').select('user_id,story_id').eq('user_id', uid).limit(2000);
      final set = <String>{};
      for (final raw in rows) {
        final m = raw.map((k, v) => MapEntry(k.toString(), v));
        final storyId = (m['story_id'] ?? '').toString();
        if (storyId.isNotEmpty) set.add(storyId);
      }
          _seenByUserId
        ..clear()
        ..[uid] = set;
    } catch (e) {
      debugPrint('StoryService failed to load remote seen state: $e');
      _seenByUserId.clear();
    }
  }

  Future<void> _markSeenRemote({required String userId, required String storyId}) async {
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) return;
    if (uid != userId) {
      debugPrint('StoryService.markSeen remote: userId mismatch; using auth uid');
    }
    try {
      await SupabaseConfig.client.from('story_seen').upsert({
        'user_id': uid,
        'story_id': storyId,
        'seen_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,story_id');
    } catch (e) {
      debugPrint('StoryService failed to mark remote seen: $e');
    }
  }

  Future<void> _loadSeen() async {
    if (BackendConfig.mode == BackendMode.supabase) return;
    try {
      final raw = await _store.getString(_seenKey);
      if (raw == null || raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      _seenByUserId.clear();
      for (final entry in decoded.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is! String || value is! List) continue;
        _seenByUserId[key] = value.whereType<String>().toSet();
      }
    } catch (e) {
      debugPrint('StoryService failed to load seen state: $e');
      _seenByUserId.clear();
    }
  }

  Future<void> _persistSeen() async {
    if (BackendConfig.mode == BackendMode.supabase) return;
    try {
      final encoded = <String, List<String>>{};
      for (final entry in _seenByUserId.entries) {
        encoded[entry.key] = entry.value.toList();
      }
      await _store.setString(_seenKey, jsonEncode(encoded));
    } catch (e) {
      debugPrint('StoryService failed to persist seen state: $e');
    }
  }

  Future<void> _persistStories() async {
    if (BackendConfig.mode == BackendMode.supabase) return;
    try {
      await _store.setString(_storiesKey, jsonEncode(_stories.map((s) => s.toJson()).toList()));
    } catch (e) {
      debugPrint('StoryService failed to persist stories: $e');
    }
  }

  List<StoryModel> _seedStories() {
    final now = DateTime.now();
    final expires = now.add(const Duration(hours: 18));
    return [
      StoryModel(
        storyId: 'story_${now.subtract(const Duration(minutes: 40)).microsecondsSinceEpoch}',
        authorId: 'talent_001',
        authorDisplayName: 'Nova K.',
        authorPrimaryRole: 'talent',
        caption: 'Soundcheck. New lighting rig is insane.',
        createdAt: now.subtract(const Duration(minutes: 40)),
        expiresAt: expires,
        backgroundSeed: 11,
      ),
      StoryModel(
        storyId: 'story_${now.subtract(const Duration(hours: 3)).microsecondsSinceEpoch}',
        authorId: 'biz_011',
        authorDisplayName: 'Lumen Brands',
        authorPrimaryRole: 'business',
        caption: 'Campaign moodboard drop — clean, chrome, midnight neon.',
        createdAt: now.subtract(const Duration(hours: 3)),
        expiresAt: expires,
        backgroundSeed: 22,
      ),
      StoryModel(
        storyId: 'story_${now.subtract(const Duration(hours: 5)).microsecondsSinceEpoch}',
        authorId: 'aud_105',
        authorDisplayName: 'Ari',
        authorPrimaryRole: 'audience',
        caption: 'Tonight’s watch list: three creators I found on SPOTLIGHT.',
        createdAt: now.subtract(const Duration(hours: 5)),
        expiresAt: expires,
        backgroundSeed: 33,
      ),
    ];
  }
}
