class CreatorAttributionSummary {
  final String creatorName;
  final num totalEarnings;
  final num pipelineValue;
  final num completionRatePct;
  final String? summaryGeneratedAt;

  const CreatorAttributionSummary({
    required this.creatorName,
    required this.totalEarnings,
    required this.pipelineValue,
    required this.completionRatePct,
    this.summaryGeneratedAt,
  });

  factory CreatorAttributionSummary.fromJson(Map<String, dynamic> json) {
    num toNum(dynamic v) => v is num ? v : num.tryParse('${v ?? 0}') ?? 0;

    return CreatorAttributionSummary(
      creatorName: (json['creator_name'] ?? json['creatorName'] ?? '')
          .toString(),
      totalEarnings: toNum(json['total_earnings'] ?? json['totalEarnings']),
      pipelineValue: toNum(json['pipeline_value'] ?? json['pipelineValue']),
      completionRatePct: toNum(
        json['completion_rate_pct'] ?? json['completionRatePct'],
      ),
      summaryGeneratedAt:
          (json['summary_generated_at'] ?? json['summaryGeneratedAt'])
              ?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'creator_name': creatorName,
    'total_earnings': totalEarnings,
    'pipeline_value': pipelineValue,
    'completion_rate_pct': completionRatePct,
    'summary_generated_at': summaryGeneratedAt,
  };
}
