import 'package:supabase_flutter/supabase_flutter.dart';

class ContentReport {
  const ContentReport({
    required this.id,
    required this.reason,
    required this.severity,
    required this.status,
    required this.createdAt,
    this.body,
    this.targetUserId,
    this.reporterUserId,
  });

  final String id;
  final String reason;
  final String severity;
  final String status;
  final DateTime createdAt;
  final String? body;
  final String? targetUserId;
  final String? reporterUserId;

  factory ContentReport.fromMap(Map<String, dynamic> row) {
    return ContentReport(
      id: (row['id'] ?? '').toString(),
      reason: (row['reason'] ?? 'other').toString(),
      severity: (row['severity'] ?? 'medium').toString(),
      status: (row['status'] ?? 'open').toString(),
      body: row['body']?.toString(),
      targetUserId: row['target_user_id']?.toString(),
      reporterUserId: row['reporter_user_id']?.toString(),
      createdAt: DateTime.tryParse((row['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  String get typeLabel {
    final r = reason.toLowerCase();
    if (r.contains('spam')) return 'Spam / Promo';
    if (r.contains('misinfo')) return 'Misinfo';
    if (r.contains('harass')) return 'Harassment';
    return reason.isEmpty ? 'Report' : reason;
  }
}

class AdminModerationService {
  AdminModerationService({SupabaseClient? client})
      : _db = client ?? Supabase.instance.client;

  final SupabaseClient _db;

  Future<List<ContentReport>> fetchOpen() async {
    final rows = await _db
        .from('content_reports')
        .select()
        .inFilter('status', ['open', 'reviewing'])
        .order('created_at', ascending: false)
        .limit(50);

    return (rows as List)
        .map((raw) =>
            ContentReport.fromMap(Map<String, dynamic>.from(raw as Map)))
        .toList();
  }

  Future<void> removeReport({
    required ContentReport item,
    required String resolverUserId,
  }) async {
    await _db.from('content_reports').update({
      'status': 'removed',
      'resolved_at': DateTime.now().toUtc().toIso8601String(),
      'resolver_user_id': resolverUserId.isEmpty ? null : resolverUserId,
    }).eq('id', item.id);
  }

  Future<void> dismissReport({
    required ContentReport item,
    required String resolverUserId,
  }) async {
    await _db.from('content_reports').update({
      'status': 'dismissed',
      'resolved_at': DateTime.now().toUtc().toIso8601String(),
      'resolver_user_id': resolverUserId.isEmpty ? null : resolverUserId,
    }).eq('id', item.id);
  }
}
