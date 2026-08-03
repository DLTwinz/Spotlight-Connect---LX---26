import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Writes first-party graph events (identity densification path).
class GraphEventService {
  GraphEventService(this._client);
  final SupabaseClient _client;

  /// Resolve profiles.id for the current auth user.
  Future<String?> currentProfileId() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client
        .from('profiles')
        .select('id')
        .eq('user_id', uid)
        .maybeSingle();
    return row == null ? null : row['id']?.toString();
  }

  /// Record a graph event. Returns event id or null on failure.
  Future<String?> record({
    required String eventType,
    String? objectType,
    String? objectId,
    String? roleContext,
    num weight = 0,
    Map<String, dynamic>? metadata,
  }) async {
    final profileId = await currentProfileId();
    if (profileId == null) {
      debugPrint('GraphEventService: no profile for current user');
      return null;
    }
    try {
      final row = await _client
          .from('graph_events')
          .insert({
            'profile_id': profileId,
            'event_type': eventType,
            'object_type': objectType,
            'object_id': objectId,
            'role_context': roleContext,
            'weight': weight,
            'metadata': metadata ?? <String, dynamic>{},
          })
          .select('id')
          .single();
      return row['id']?.toString();
    } catch (e) {
      debugPrint('GraphEventService.record failed: $e');
      return null;
    }
  }

  /// Upsert a relationship edge via SECURITY DEFINER RPC.
  Future<void> upsertEdge({
    required String subjectProfileId,
    required String objectProfileId,
    required String edgeType,
    num strengthDelta = 1,
  }) async {
    if (subjectProfileId == objectProfileId) return;
    try {
      await _client.rpc('graph_upsert_edge', params: {
        'p_subject': subjectProfileId,
        'p_object': objectProfileId,
        'p_edge_type': edgeType,
        'p_strength_delta': strengthDelta,
      });
    } catch (e) {
      debugPrint('GraphEventService.upsertEdge failed: $e');
    }
  }

  /// Count events for current profile (optional type filter).
  Future<int> countMyEvents({String? eventType}) async {
    final profileId = await currentProfileId();
    if (profileId == null) return 0;
    try {
      var q = _client
          .from('graph_events')
          .select('id')
          .eq('profile_id', profileId);
      if (eventType != null) {
        q = q.eq('event_type', eventType);
      }
      final rows = await q;
      return (rows as List).length;
    } catch (e) {
      debugPrint('GraphEventService.countMyEvents failed: $e');
      return 0;
    }
  }

  /// Append support ledger entry. Returns new balance or null.
  Future<num?> appendSupport({
    required num delta,
    required String reason,
    String? eventId,
  }) async {
    try {
      final result = await _client.rpc('support_ledger_append', params: {
        'p_delta': delta,
        'p_reason': reason,
        'p_event_id': eventId,
      });
      return result is num ? result : num.tryParse(result?.toString() ?? '');
    } catch (e) {
      debugPrint('GraphEventService.appendSupport failed: $e');
      return null;
    }
  }

  /// Gated claim stub — high-signal event + ledger (no pass table required yet).
  /// Claim a gated pass via SECURITY DEFINER RPC (event + ledger + edge + scores).
  Future<String?> claimGatedPass({
    required String passId,
    String roleContext = 'audience',
  }) async {
    try {
      final result = await _client.rpc('claim_gated_pass', params: {
        'p_pass_id': passId,
      });
      return result?.toString();
    } catch (e) {
      debugPrint('claimGatedPass failed: $e');
      return null;
    }
  }

  /// Highest pairwise fandom_strength for current profile.
  Future<num> myTopFandomStrength() async {
    final profileId = await currentProfileId();
    if (profileId == null) return 0;
    try {
      final row = await _client
          .from('graph_scores')
          .select('score_value')
          .eq('profile_id', profileId)
          .eq('score_type', 'fandom_strength')
          .order('score_value', ascending: false)
          .limit(1)
          .maybeSingle();
      if (row == null) return 0;
      final v = row['score_value'];
      if (v is num) return v;
      return num.tryParse(v?.toString() ?? '') ?? 0;
    } catch (e) {
      debugPrint('myTopFandomStrength failed: $e');
      return 0;
    }
  }


  Future<num> mySupportBalance() async {
    final profileId = await currentProfileId();
    if (profileId == null) return 0;
    try {
      final row = await _client
          .from('support_ledger')
          .select('balance_after')
          .eq('profile_id', profileId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (row == null) return 0;
      final v = row['balance_after'];
      if (v is num) return v;
      return num.tryParse(v?.toString() ?? '') ?? 0;
    } catch (e) {
      debugPrint('GraphEventService.mySupportBalance failed: $e');
      return 0;
    }
  }

  Future<num?> recomputeSupportImpact() async {
    try {
      final result = await _client.rpc('recompute_support_impact');
      if (result is num) return result;
      return num.tryParse(result?.toString() ?? '');
    } catch (e) {
      debugPrint('recomputeSupportImpact failed: $e');
      return null;
    }
  }

  Future<num> mySupportImpactScore() async {
    final profileId = await currentProfileId();
    if (profileId == null) return 0;
    try {
      final row = await _client
          .from('graph_scores')
          .select('score_value')
          .eq('profile_id', profileId)
          .eq('score_type', 'support_impact')
          .maybeSingle();
      if (row == null) return 0;
      final v = row['score_value'];
      if (v is num) return v;
      return num.tryParse(v?.toString() ?? '') ?? 0;
    } catch (e) {
      debugPrint('mySupportImpactScore failed: $e');
      return 0;
    }
  }
}
