class CreatorAttributionSummary {
  final String? creatorId;
  final String? creatorName;
  final num? totalEarnings;
  final num? pipelineValue;
  final num? completionRatePct;
  final String? summaryGeneratedAt;

  const CreatorAttributionSummary({
    this.creatorId,
    this.creatorName,
    this.totalEarnings,
    this.pipelineValue,
    this.completionRatePct,
    this.summaryGeneratedAt,
  });

  factory CreatorAttributionSummary.fromJson(Map<String, dynamic> json) {
    return CreatorAttributionSummary(
      creatorId: json['creator_id']?.toString(),
      creatorName: json['creator_name']?.toString(),
      totalEarnings: json['total_earnings'] as num?,
      pipelineValue: json['pipeline_value'] as num?,
      completionRatePct: json['completion_rate_pct'] as num?,
      summaryGeneratedAt: json['summary_generated_at']?.toString(),
    );
  }
}