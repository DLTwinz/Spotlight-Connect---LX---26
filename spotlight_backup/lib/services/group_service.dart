import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:spotlight_connect/backend/backend_mode.dart';
import 'package:spotlight_connect/models/group_model.dart';
import 'package:spotlight_connect/storage/key_value_store.dart';
import 'package:spotlight_connect/supabase/supabase_config.dart';

class GroupService extends ChangeNotifier {
  static const _groupsKey = 'spotlight_groups_v1';
  static const _membershipsKey = 'spotlight_group_memberships_v1';

  final KeyValueStore _store;
  bool _initialized = false;
  bool _isLoading = false;

  List<GroupModel> _groups = const [];
  List<GroupMembershipModel> _memberships = const [];
  final Map<String, int> _memberCounts = <String, int>{};

  GroupService({KeyValueStore? store}) : _store = store ?? createKeyValueStore();

  bool get isLoading => _isLoading;
  List<GroupModel> get groups => _groups;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    await _load();
  }

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

     if (BackendConfig.mode == BackendMode.supabase) {
       try {
         await _loadRemote();
       } catch (e) {
         debugPrint('GroupService failed to load from Supabase: $e');
         _groups = const [];
         _memberships = const [];
         _memberCounts.clear();
       } finally {
         _isLoading = false;
         notifyListeners();
       }
       return;
     }

    try {
      final rawGroups = await _store.getString(_groupsKey);
      final rawMemberships = await _store.getString(_membershipsKey);

      final parsedGroups = <GroupModel>[];
      if (rawGroups != null && rawGroups.trim().isNotEmpty) {
        final decoded = jsonDecode(rawGroups);
        if (decoded is List) {
          for (final item in decoded) {
            final g = GroupModel.tryFromJson(item);
            if (g != null) parsedGroups.add(g);
          }
        }
      }

      final parsedMemberships = <GroupMembershipModel>[];
      if (rawMemberships != null && rawMemberships.trim().isNotEmpty) {
        final decoded = jsonDecode(rawMemberships);
        if (decoded is List) {
          for (final item in decoded) {
            final m = GroupMembershipModel.tryFromJson(item);
            if (m != null) parsedMemberships.add(m);
          }
        }
      }

      if (parsedGroups.isEmpty) {
        final seed = _seedGroups();
        _groups = seed;
        _memberships = _seedMemberships(seed);
        await _persist();
      } else {
        _groups = parsedGroups..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        _memberships = parsedMemberships;
      }
    } catch (e) {
      debugPrint('GroupService failed to load: $e');
      final seed = _seedGroups();
      _groups = seed;
      _memberships = _seedMemberships(seed);
      try {
        await _persist();
      } catch (e) {
        debugPrint('GroupService failed to persist after load error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadRemote() async {
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) {
      _groups = const [];
      _memberships = const [];
      _memberCounts.clear();
      return;
    }

    // Fetch groups plus membership counts.
    final rows = await SupabaseConfig.client
        .from('groups')
        .select('id,name,description,created_by_user_id,visibility,created_at,updated_at, group_memberships(count)')
        .order('updated_at', ascending: false);

    final parsedGroups = <GroupModel>[];
    _memberCounts.clear();
    for (final raw in rows) {
      final model = GroupModel.fromSupabaseRow(raw);
      if (model == null) continue;
      parsedGroups.add(model);

      try {
        final rel = raw['group_memberships'];
        if (rel is List && rel.isNotEmpty) {
          final firstEntry = rel.first;
          if (firstEntry is Map<String, dynamic>) {
            final value = firstEntry['count'];
            if (value is num) {
              _memberCounts[model.groupId] = value.toInt();
            }
          }
        }
      } catch (_) {
        // ignore
      }
    }

    _groups = parsedGroups;

    // Fetch visible memberships (RLS will restrict rows).
    final mRows = await SupabaseConfig.client.from('group_memberships').select('group_id,user_id,role,joined_at');
    final parsedMemberships = <GroupMembershipModel>[];
    for (final raw in mRows) {
      final model = GroupMembershipModel.fromSupabaseRow(raw);
      if (model != null) parsedMemberships.add(model);
    }
      parsedMemberships.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
    _memberships = parsedMemberships;
  }

  Future<void> _persist() async {
    if (BackendConfig.mode == BackendMode.supabase) return;
    try {
      await _store.setString(_groupsKey, jsonEncode(_groups.map((e) => e.toJson()).toList()));
      await _store.setString(_membershipsKey, jsonEncode(_memberships.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('GroupService failed to persist: $e');
    }
  }

  int memberCount(String groupId) => _memberCounts[groupId] ?? _memberships.where((m) => m.groupId == groupId).length;

  bool isMember({required String groupId, required String userId}) {
    return _memberships.any((m) => m.groupId == groupId && m.userId == userId);
  }

  List<GroupModel> groupsForUser(String userId) {
    final joined = _memberships.where((m) => m.userId == userId).map((m) => m.groupId).toSet();
    return _groups.where((g) => joined.contains(g.groupId)).toList();
  }

  List<GroupMembershipModel> members(String groupId) {
    final list = _memberships.where((m) => m.groupId == groupId).toList();
    list.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
    return list;
  }

  Future<GroupModel> createGroup({
    required String name,
    required String description,
    required String createdByUserId,
    String visibility = 'public',
  }) async {
    if (BackendConfig.mode == BackendMode.supabase) {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) throw StateError('Must be authenticated to create a group');
      if (createdByUserId != uid) {
        debugPrint('GroupService.createGroup: createdByUserId mismatch; using auth uid');
      }

      final inserted = await SupabaseConfig.client
          .from('groups')
          .insert({
            'name': name.trim(),
            'description': description.trim(),
            'created_by_user_id': uid,
            'visibility': visibility,
          })
          .select()
          .single();

      final group = GroupModel.fromSupabaseRow(inserted);
      if (group == null) throw StateError('Failed to create group');

      // Ensure the creator is a member/owner.
      try {
        await SupabaseConfig.client.from('group_memberships').insert({
          'group_id': group.groupId,
          'user_id': uid,
          'role': 'owner',
        });
      } catch (e) {
        debugPrint('GroupService.createGroup: failed to create owner membership: $e');
      }

      await _loadRemote();
      notifyListeners();
      return group;
    }

    final now = DateTime.now();
    final id = 'grp_${now.microsecondsSinceEpoch}';
    final group = GroupModel(
      groupId: id,
      name: name.trim(),
      description: description.trim(),
      createdByUserId: createdByUserId,
      visibility: visibility,
      createdAt: now,
      updatedAt: now,
    );
    _groups = [group, ..._groups];
    _memberships = [GroupMembershipModel(groupId: id, userId: createdByUserId, role: 'owner', joinedAt: now), ..._memberships];
    await _persist();
    notifyListeners();
    return group;
  }

  Future<void> joinGroup({required String groupId, required String userId}) async {
    if (BackendConfig.mode == BackendMode.supabase) {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) throw StateError('Must be authenticated to join a group');
      if (userId != uid) {
        debugPrint('GroupService.joinGroup: userId mismatch; using auth uid');
      }
      await SupabaseConfig.client.from('group_memberships').insert({
        'group_id': groupId,
        'user_id': uid,
        'role': 'member',
      });
      await _loadRemote();
      notifyListeners();
      return;
    }

    if (isMember(groupId: groupId, userId: userId)) return;
    final now = DateTime.now();
    _memberships = [GroupMembershipModel(groupId: groupId, userId: userId, role: 'member', joinedAt: now), ..._memberships];
    _touch(groupId);
    await _persist();
    notifyListeners();
  }

  Future<void> leaveGroup({required String groupId, required String userId}) async {
    if (BackendConfig.mode == BackendMode.supabase) {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) throw StateError('Must be authenticated to leave a group');
      if (userId != uid) {
        debugPrint('GroupService.leaveGroup: userId mismatch; using auth uid');
      }
      await SupabaseConfig.client.from('group_memberships').delete().eq('group_id', groupId).eq('user_id', uid);
      await _loadRemote();
      notifyListeners();
      return;
    }

    final before = _memberships.length;
    _memberships = _memberships.where((m) => !(m.groupId == groupId && m.userId == userId)).toList();
    if (_memberships.length == before) return;
    _touch(groupId);
    await _persist();
    notifyListeners();
  }

  void _touch(String groupId) {
    final idx = _groups.indexWhere((g) => g.groupId == groupId);
    if (idx < 0) return;
    final g = _groups[idx];
    final updated = g.copyWith(updatedAt: DateTime.now());
    final copy = [..._groups];
    copy[idx] = updated;
    copy.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _groups = copy;
  }

  List<GroupModel> _seedGroups() {
    final now = DateTime.now();
    return [
      GroupModel(
        groupId: 'grp_spotlight_comedy',
        name: 'Spotlight Comedy Circle',
        description: 'Weekly prompts, open-mic links, and creator collabs.',
        createdByUserId: 'system',
        visibility: 'public',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(minutes: 12)),
      ),
      GroupModel(
        groupId: 'grp_music_makers',
        name: 'Neon Music Makers',
        description: 'Share demos, find producers, schedule live sessions.',
        createdByUserId: 'system',
        visibility: 'public',
        createdAt: now.subtract(const Duration(days: 18)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      GroupModel(
        groupId: 'grp_brand_builders',
        name: 'Brand Builders (Business)',
        description: 'Campaign strategy, creator briefs, and outreach playbooks.',
        createdByUserId: 'system',
        visibility: 'public',
        createdAt: now.subtract(const Duration(days: 22)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }

  List<GroupMembershipModel> _seedMemberships(List<GroupModel> seedGroups) {
    final now = DateTime.now();
    final all = <GroupMembershipModel>[];
    for (final g in seedGroups) {
      all.add(GroupMembershipModel(groupId: g.groupId, userId: 'system', role: 'owner', joinedAt: g.createdAt));
    }
    // Add a few demo members to make groups feel alive.
    all.add(GroupMembershipModel(groupId: seedGroups.first.groupId, userId: 'demo_talent_1', role: 'member', joinedAt: now.subtract(const Duration(days: 3))));
    all.add(GroupMembershipModel(groupId: seedGroups.first.groupId, userId: 'demo_audience_1', role: 'member', joinedAt: now.subtract(const Duration(days: 1))));
    all.add(GroupMembershipModel(groupId: seedGroups[1].groupId, userId: 'demo_talent_2', role: 'member', joinedAt: now.subtract(const Duration(days: 4))));
    return all;
  }
}
