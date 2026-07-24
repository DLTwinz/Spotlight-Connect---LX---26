import 'package:flutter/foundation.dart';

@immutable
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.planId,
    required this.title,
    required this.subtitle,
    required this.priceUsdMonthly,
    required this.featureBullets,
    required this.createdAt,
    required this.updatedAt,
  });

  final String planId;
  final String title;
  final String subtitle;
  final double priceUsdMonthly;
  final List<String> featureBullets;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlan copyWith({
    String? title,
    String? subtitle,
    double? priceUsdMonthly,
    List<String>? featureBullets,
    DateTime? updatedAt,
  }) {
    return SubscriptionPlan(
      planId: planId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      priceUsdMonthly: priceUsdMonthly ?? this.priceUsdMonthly,
      featureBullets: featureBullets ?? this.featureBullets,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'title': title,
      'subtitle': subtitle,
      'priceUsdMonthly': priceUsdMonthly,
      'featureBullets': featureBullets,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    DateTime dt(dynamic v) {
      if (v is DateTime) return v;
      if (v is String)
        return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final bulletsRaw = json['featureBullets'];
    final bullets = bulletsRaw is List
        ? bulletsRaw.map((e) => e.toString()).toList()
        : <String>[];
    return SubscriptionPlan(
      planId: (json['planId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      priceUsdMonthly: (json['priceUsdMonthly'] is num)
          ? (json['priceUsdMonthly'] as num).toDouble()
          : 0,
      featureBullets: bullets,
      createdAt: dt(json['createdAt']),
      updatedAt: dt(json['updatedAt']),
    );
  }
}

@immutable
class MonetizationTransaction {
  const MonetizationTransaction({
    required this.transactionId,
    required this.type,
    required this.fromUserId,
    required this.toUserId,
    required this.amountUsd,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// type: 'tip' | 'subscription_start' | 'subscription_cancel'
  final String type;
  final String transactionId;
  final String fromUserId;
  final String toUserId;
  final double amountUsd;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  MonetizationTransaction copyWith({
    String? type,
    String? fromUserId,
    String? toUserId,
    double? amountUsd,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) {
    return MonetizationTransaction(
      transactionId: transactionId,
      type: type ?? this.type,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      amountUsd: amountUsd ?? this.amountUsd,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'type': type,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amountUsd': amountUsd,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MonetizationTransaction.fromJson(Map<String, dynamic> json) {
    DateTime dt(dynamic v) {
      if (v is DateTime) return v;
      if (v is String)
        return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    Map<String, dynamic>? meta;
    final raw = json['metadata'];
    if (raw is Map<String, dynamic>) meta = raw;
    if (raw is Map) meta = raw.map((k, v) => MapEntry(k.toString(), v));

    return MonetizationTransaction(
      transactionId: (json['transactionId'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      fromUserId: (json['fromUserId'] ?? '').toString(),
      toUserId: (json['toUserId'] ?? '').toString(),
      amountUsd: (json['amountUsd'] is num)
          ? (json['amountUsd'] as num).toDouble()
          : 0,
      metadata: meta,
      createdAt: dt(json['createdAt']),
      updatedAt: dt(json['updatedAt']),
    );
  }
}

@immutable
class CreatorPayoutProfile {
  const CreatorPayoutProfile({
    required this.userId,
    required this.displayName,
    required this.payoutMethod,
    required this.payoutHandle,
    required this.createdAt,
    required this.updatedAt,
  });

  /// payoutMethod: 'none' | 'paypal' | 'cashapp' | 'bank'
  final String payoutMethod;
  final String payoutHandle;

  final String userId;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  CreatorPayoutProfile copyWith({
    String? displayName,
    String? payoutMethod,
    String? payoutHandle,
    DateTime? updatedAt,
  }) {
    return CreatorPayoutProfile(
      userId: userId,
      displayName: displayName ?? this.displayName,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      payoutHandle: payoutHandle ?? this.payoutHandle,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'payoutMethod': payoutMethod,
      'payoutHandle': payoutHandle,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CreatorPayoutProfile.fromJson(Map<String, dynamic> json) {
    DateTime dt(dynamic v) {
      if (v is DateTime) return v;
      if (v is String)
        return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return CreatorPayoutProfile(
      userId: (json['userId'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      payoutMethod: (json['payoutMethod'] ?? 'none').toString(),
      payoutHandle: (json['payoutHandle'] ?? '').toString(),
      createdAt: dt(json['createdAt']),
      updatedAt: dt(json['updatedAt']),
    );
  }
}
