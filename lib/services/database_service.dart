import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/verified_report_model.dart';

class SpotlightDatabase {
  // Re-linking directly to your real backend client
  final _supabase = Supabase.instance.client;

  Stream<List<VerifiedReport>> getVerifiedAudienceStream() {
    return _supabase
        .from('verified_reports') // Assumes your table matches this snake_case name
        .stream(primaryKey: ['community_id'])
        .map((maps) => maps.map((map) {
              return VerifiedReport(
                communityId: map['community_id'] as String,
                communityName: map['community_name'] as String,
                totalVerifiedFans: map['total_verified_fans'] as int,
                verifiedActions30d: map['verified_actions_30d'] as int,
                repeatSupporterCount: map['repeat_supporter_count'] as int,
              );
            }).toList());
  }

  /// Invokes the secure 4-Pillar Edge Function to process an attribution event
  Future<Map<String, dynamic>?> createAttributionEntry({
    required String adminId,
    required String fanId,
    required String creatorId,
    required String brandId,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'create_attribution_entry',
        body: {
          'admin_id': adminId,
          'fan_id': fanId,
          'creator_id': creatorId,
          'brand_id': brandId,
        },
      );

      if (response.status != 200) {
        throw Exception('Edge Function Error (${response.status}): ${response.data}');
      }

      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Error creating attribution ledger entry: $e');
      rethrow;
    }
  }
}
