class BrandAttributionSummary {
  final String? brandId;
  final String? brandName;
  final num? totalSpend;
  final num? avgDealValue;
  final num? completionRatePct;
  final String? summaryGeneratedAt;

  const BrandAttributionSummary({
    this.brandId,
    this.brandName,
    this.totalSpend,
    this.avgDealValue,
    this.completionRatePct,
    this.summaryGeneratedAt,
  });

  factory BrandAttributionSummary.fromJson(Map<String, dynamic> json) {
    return BrandAttributionSummary(
      brandId: json['brand_id']?.toString(),
      brandName: json['brand_name']?.toString(),
      totalSpend: json['total_spend'] as num?,
      avgDealValue: json['avg_deal_value'] as num?,
      completionRatePct: json['completion_rate_pct'] as num?,
      summaryGeneratedAt: json['summary_generated_at']?.toString(),
    );
  }
}