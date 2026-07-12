import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/verified_report_model.dart';
import '../models/brand_attribution_summary_model.dart';
import '../models/creator_attribution_summary_model.dart';
import 'package:spotlight_connect/database_service.dart';

class SpotlightDatabase {
  final _supabase = Supabase.instance.client;

  Stream<List<VerifiedReport>> getVerifiedAudienceStream() {
    return _supabase
        .from('verified_reports')
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

  Future<BrandAttributionSummary?> getBrandAttribution({String? brandId}) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-brand-attribution',
        method: HttpMethod.get,
        queryParameters: brandId != null ? {'brand_id': brandId} : null,
      );

      if (response.status != 200) {
        throw Exception('Brand attribution error (${response.status}): ${response.data}');
      }

      final payload = response.data as Map<String, dynamic>?;

      if (payload == null || payload['ok'] != true) {
        return null;
      }

      final data = (payload['data'] as List<dynamic>? ?? []);
      if (data.isEmpty) return null;

      return BrandAttributionSummary.fromJson(
        Map<String, dynamic>.from(data.first as Map),
      );
    } catch (e) {
      print('Error fetching brand attribution: $e');
      rethrow;
    }
  }

  Future<CreatorAttributionSummary?> getCreatorAttribution({String? creatorId}) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-creator-attribution',
        method: HttpMethod.get,
        queryParameters: creatorId != null ? {'creator_id': creatorId} : null,
      );

      if (response.status != 200) {
        throw Exception('Creator attribution error (${response.status}): ${response.data}');
      }

      final payload = response.data as Map<String, dynamic>?;

      if (payload == null || payload['ok'] != true) {
        return null;
      }

      final data = (payload['data'] as List<dynamic>? ?? []);
      if (data.isEmpty) return null;

      return CreatorAttributionSummary.fromJson(
        Map<String, dynamic>.from(data.first as Map),
      );
    } catch (e) {
      print('Error fetching creator attribution: $e');
      rethrow;
    }
  }

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