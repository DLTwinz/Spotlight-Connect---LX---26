import 'package:supabase_flutter/supabase_flutter.dart';

class PendingApproval {
  const PendingApproval({
    required this.profileId,
    required this.userId,
    required this.displayName,
    required this.username,
    required this.requestedRole,
    required this.createdAt,
    this.avatarUrl,
  });

  final String profileId;
  final String userId;
  final String displayName;
  final String username;
  final String requestedRole;
  final DateTime createdAt;
  final String? avatarUrl;

  String get typeLabel {
    final r = requestedRole.toLowerCase();
    if (r.contains('business') || r.contains('brand')) return 'Business';
    if (r.contains('talent') || r.contains('creator')) return 'Creator';
    return requestedRole.isEmpty ? 'Creator' : requestedRole;
  }
}

class AdminApprovalsService {
  AdminApprovalsService({SupabaseClient? client})
      : _db = client ?? Supabase.instance.client;

  final SupabaseClient _db;

  Future<List<PendingApproval>> fetchPending() async {
    final rows = await _db
        .from('profiles')
        .select(
          'id, user_id, display_name, username, avatar_url, '
          'requested_role_pending, application_status_summary, created_at',
        )
        .or('application_status_summary.eq.pending,requested_role_pending.not.is.null')
        .order('created_at', ascending: false);

    final list = <PendingApproval>[];
    for (final raw in (rows as List)) {
      final row = Map<String, dynamic>.from(raw as Map);
      final pending = (row['requested_role_pending'] ?? '').toString().trim();
      final status = (row['application_status_summary'] ?? '').toString();
      if (pending.isEmpty && status != 'pending') continue;

      list.add(
        PendingApproval(
          profileId: (row['id'] ?? '').toString(),
          userId: (row['user_id'] ?? '').toString(),
          displayName: (row['display_name'] ?? 'Unknown').toString(),
          username: (row['username'] ?? '').toString(),
          requestedRole: pending.isNotEmpty ? pending : 'creator',
          createdAt: DateTime.tryParse((row['created_at'] ?? '').toString()) ??
              DateTime.now(),
          avatarUrl: row['avatar_url']?.toString(),
        ),
      );
    }
    return list;
  }

  Future<void> approve({
    required PendingApproval item,
    required String reviewerUserId,
  }) async {
    // Read current approved_roles
    final existing = await _db
        .from('profiles')
        .select('approved_roles, active_role')
        .eq('id', item.profileId)
        .maybeSingle();

    final roles = <String>['audience'];
    if (existing != null) {
      final raw = existing['approved_roles'];
      if (raw is List) {
        for (final r in raw) {
          final s = r.toString();
          if (s.isNotEmpty && !roles.contains(s)) roles.add(s);
        }
      }
    }
    final newRole = item.requestedRole.toLowerCase();
    if (newRole.isNotEmpty && !roles.contains(newRole)) {
      roles.add(newRole);
    }

    await _db.from('profiles').update({
      'requested_role_pending': null,
      'application_status_summary': 'approved',
      'approved': true,
      'approved_roles': roles,
      'active_role': newRole.isNotEmpty ? newRole : (existing?['active_role'] ?? 'audience'),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', item.profileId);

    await _db.from('approvals').insert({
      'user_id': item.userId,
      'requested_role': item.requestedRole,
      'decision': 'approved',
      'reviewed_by_user_id': reviewerUserId,
    });
  }

  Future<void> reject({
    required PendingApproval item,
    required String reviewerUserId,
    String? reason,
  }) async {
    await _db.from('profiles').update({
      'requested_role_pending': null,
      'application_status_summary': 'rejected',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', item.profileId);

    await _db.from('approvals').insert({
      'user_id': item.userId,
      'requested_role': item.requestedRole,
      'decision': 'rejected',
      'reason': reason,
      'reviewed_by_user_id': reviewerUserId,
    });
  }
}
