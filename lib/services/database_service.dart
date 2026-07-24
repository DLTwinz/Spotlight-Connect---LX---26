import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotlight_connect/models/verified_report_model.dart';
import 'package:spotlight_connect/models/brand_attribution_summary_model.dart';
import 'package:spotlight_connect/models/creator_attribution_summary_model.dart';

class SpotlightDatabase {
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<VerifiedReport>> getVerifiedAudienceStream() {
    return supabase
        .from('verifiedreports')
        .stream(primaryKey: ['communityid'])
        .map(
          (maps) => maps.map((map) {
            return VerifiedReport(
              communityId: map['communityid'] as String,
              communityName: map['communityname'] as String,
              totalVerifiedFans: map['totalverifiedfans'] as int,
              verifiedActions30d: map['verifiedactions30d'] as int,
              repeatSupporterCount: map['repeatsupportercount'] as int,
            );
          }).toList(),
        );
  }

  Future<BrandAttributionSummary?> getBrandAttribution({
    String? brandId,
  }) async {
    final response = await supabase.functions.invoke(
      'get-brand-attribution',
      body: brandId != null ? {'brand_id': brandId} : {},
    );

    if (response.data == null) {
      return null;
    }

    final data = response.data as Map<String, dynamic>;
    final rows = (data['data'] as List?) ?? const [];

    if (rows.isEmpty) {
      return null;
    }

    final row = Map<String, dynamic>.from(rows.first as Map);

    return BrandAttributionSummary.fromJson(row);
  }

  Future<CreatorAttributionSummary?> getCreatorAttribution({
    String? creatorId,
  }) async {
    final response = await supabase.functions.invoke(
      'get-creator-attribution',
      body: creatorId != null ? {'creator_id': creatorId} : {},
    );

    if (response.data == null) {
      return null;
    }

    final data = response.data as Map<String, dynamic>;
    final rows = (data['data'] as List?) ?? const [];

    if (rows.isEmpty) {
      return null;
    }

    final row = Map<String, dynamic>.from(rows.first as Map);

    return CreatorAttributionSummary.fromJson(row);
  }

  Future<Map<String, dynamic>> createAttributionEntry({
    required String brandId,
    required String creatorId,
    required num amount,
    String? campaignId,
    String? notes,
  }) async {
    final response = await supabase.functions.invoke(
      'create_attribution_entry',
      body: {
        'brand_id': brandId,
        'creator_id': creatorId,
        'amount': amount,
        if (campaignId != null && campaignId.isNotEmpty)
          'campaign_id': campaignId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }
}
