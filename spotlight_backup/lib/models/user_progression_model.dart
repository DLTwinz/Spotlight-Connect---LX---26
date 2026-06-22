import 'package:flutter/foundation.dart';

@immutable
class UserProgressionModel {
  const UserProgressionModel({
    required this.userId,
    required this.currentTier,
    required this.prestigeTotal,
    required this.prestigeThisSeason,
    required this.momentumScore,
    required this.missionsCompleted,
    required this.milestonesCompleted,
    required this.campaignsParticipated,
    required this.nextTierPrestigeRequired,
    required this.nextTierMissionRequirements,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String currentTier;
  final int prestigeTotal;
  final int prestigeThisSeason;
  final int momentumScore;
  final int missionsCompleted;
  final int milestonesCompleted;
  final int campaignsParticipated;
  final int? nextTierPrestigeRequired;
  final Map<String, dynamic>? nextTierMissionRequirements;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static int _asInt(Object? v) => v is int ? v : int.tryParse('$v') ?? 0;

  factory UserProgressionModel.fromJson(Map<String, dynamic> json) {
    return UserProgressionModel(
      userId: (json['user_id'] ?? '').toString(),
      currentTier: (json['current_tier'] ?? 'Starter').toString(),
      prestigeTotal: _asInt(json['prestige_total']),
      prestigeThisSeason: _asInt(json['prestige_this_season']),
      momentumScore: _asInt(json['momentum_score']),
      missionsCompleted: _asInt(json['missions_completed']),
      milestonesCompleted: _asInt(json['milestones_completed']),
      campaignsParticipated: _asInt(json['campaigns_participated']),
      nextTierPrestigeRequired: json['next_tier_prestige_required'] == null ? null : _asInt(json['next_tier_prestige_required']),
      nextTierMissionRequirements: json['next_tier_mission_requirements'] is Map ? Map<String, dynamic>.from(json['next_tier_mission_requirements'] as Map) : null,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'current_tier': currentTier,
      'prestige_total': prestigeTotal,
      'prestige_this_season': prestigeThisSeason,
      'momentum_score': momentumScore,
      'missions_completed': missionsCompleted,
      'milestones_completed': milestonesCompleted,
      'campaigns_participated': campaignsParticipated,
      'next_tier_prestige_required': nextTierPrestigeRequired,
      'next_tier_mission_requirements': nextTierMissionRequirements,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserProgressionModel copyWith({
    String? userId,
    String? currentTier,
    int? prestigeTotal,
    int? prestigeThisSeason,
    int? momentumScore,
    int? missionsCompleted,
    int? milestonesCompleted,
    int? campaignsParticipated,
    int? nextTierPrestigeRequired,
    Map<String, dynamic>? nextTierMissionRequirements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProgressionModel(
      userId: userId ?? this.userId,
      currentTier: currentTier ?? this.currentTier,
      prestigeTotal: prestigeTotal ?? this.prestigeTotal,
      prestigeThisSeason: prestigeThisSeason ?? this.prestigeThisSeason,
      momentumScore: momentumScore ?? this.momentumScore,
      missionsCompleted: missionsCompleted ?? this.missionsCompleted,
      milestonesCompleted: milestonesCompleted ?? this.milestonesCompleted,
      campaignsParticipated: campaignsParticipated ?? this.campaignsParticipated,
      nextTierPrestigeRequired: nextTierPrestigeRequired ?? this.nextTierPrestigeRequired,
      nextTierMissionRequirements: nextTierMissionRequirements ?? this.nextTierMissionRequirements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
