import 'package:flutter/foundation.dart';

@immutable
class MilestoneModel {
  const MilestoneModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.category,
    required this.prestigeReward,
    required this.badgeRewardCode,
    required this.tierUnlock,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String title;
  final String description;
  final String? category;
  final int prestigeReward;
  final String? badgeRewardCode;
  final String? tierUnlock;
  final bool active;
  final DateTime? createdAt;

  static int _asInt(Object? v) => v is int ? v : int.tryParse('$v') ?? 0;
  static bool _asBool(Object? v) => v is bool ? v : (v?.toString().toLowerCase() == 'true');

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      id: (json['id'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString().trim().isEmpty ? null : (json['category'] ?? '').toString(),
      prestigeReward: _asInt(json['prestige_reward']),
      badgeRewardCode: (json['badge_reward_code'] ?? '').toString().trim().isEmpty ? null : (json['badge_reward_code'] ?? '').toString(),
      tierUnlock: (json['tier_unlock'] ?? '').toString().trim().isEmpty ? null : (json['tier_unlock'] ?? '').toString(),
      active: _asBool(json['active']),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }
}

@immutable
class UserMilestoneModel {
  const UserMilestoneModel({
    required this.id,
    required this.milestoneId,
    required this.userId,
    required this.achievedAt,
    required this.prestigeEarned,
    required this.sourceEventId,
    required this.visibleOnProfile,
  });

  final String id;
  final String milestoneId;
  final String userId;
  final DateTime? achievedAt;
  final int prestigeEarned;
  final String? sourceEventId;
  final bool visibleOnProfile;

  static int _asInt(Object? v) => v is int ? v : int.tryParse('$v') ?? 0;
  static bool _asBool(Object? v) => v is bool ? v : (v?.toString().toLowerCase() == 'true');

  factory UserMilestoneModel.fromJson(Map<String, dynamic> json) {
    return UserMilestoneModel(
      id: (json['id'] ?? '').toString(),
      milestoneId: (json['milestone_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      achievedAt: DateTime.tryParse((json['achieved_at'] ?? '').toString()),
      prestigeEarned: _asInt(json['prestige_earned']),
      sourceEventId: (json['source_event_id'] ?? '').toString().trim().isEmpty ? null : (json['source_event_id'] ?? '').toString(),
      visibleOnProfile: _asBool(json['visible_on_profile']),
    );
  }
}
