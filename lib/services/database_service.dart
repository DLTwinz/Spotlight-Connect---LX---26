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
}