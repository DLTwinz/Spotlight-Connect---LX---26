class BrandAttributionSummary {
  final String brandName;
  final num totalSpend;
  final num avgDealValue;
  final num completionRatePct;
  final String? summaryGeneratedAt;

  const BrandAttributionSummary({
    required this.brandName,
    required this.totalSpend,
    required this.avgDealValue,
    required this.completionRatePct,
    this.summaryGeneratedAt,
  });

  factory BrandAttributionSummary.fromJson(Map<String, dynamic> json) {
    num toNum(dynamic v) => v is num ? v : num.tryParse('${v ?? 0}') ?? 0;

    return BrandAttributionSummary(
      brandName: (json['brand_name'] ?? json['brandName'] ?? '').toString(),
      totalSpend: toNum(json['total_spend'] ?? json['totalSpend']),
      avgDealValue: toNum(json['avg_deal_value'] ?? json['avgDealValue']),
      completionRatePct: toNum(
        json['completion_rate_pct'] ?? json['completionRatePct'],
      ),
      summaryGeneratedAt:
          (json['summary_generated_at'] ?? json['summaryGeneratedAt'])
              ?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'brand_name': brandName,
    'total_spend': totalSpend,
    'avg_deal_value': avgDealValue,
    'completion_rate_pct': completionRatePct,
    'summary_generated_at': summaryGeneratedAt,
  };
}
