class VerifiedReport {
  final String communityId;
  final String communityName;
  final int totalVerifiedFans;
  final int verifiedActions30d;
  final int repeatSupporterCount;

  VerifiedReport({
    required this.communityId,
    required this.communityName,
    required this.totalVerifiedFans,
    required this.verifiedActions30d,
    required this.repeatSupporterCount,
  });

  // This converts the SQL Map into a real Dart Object
  factory VerifiedReport.fromMap(Map<String, dynamic> map) {
    return VerifiedReport(
      communityId: map['community_id'] ?? '',
      communityName: map['community_name'] ?? 'Unknown Community',
      totalVerifiedFans: map['total_verified_fans'] ?? 0,
      verifiedActions30d: map['verified_actions_30d'] ?? 0,
      repeatSupporterCount: map['repeat_supporter_count'] ?? 0,
    );
  }
}