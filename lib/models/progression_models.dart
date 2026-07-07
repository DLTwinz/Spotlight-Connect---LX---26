// Minimal temporary compatibility shims for compilation.
// Replace with the full, authoritative models when available.

class UserBadgeView {
  final String name;
  // Back-compat fields used in some places
  final String? id;
  final String? badgeId;
  final String? badgeType;
  final String? description;
  final String? imageUrl;
  final DateTime? awardedAt;

  UserBadgeView({required this.name, this.id, this.badgeId, this.badgeType, this.description, this.imageUrl, this.awardedAt});

  factory UserBadgeView.fromJson(Map<String, dynamic> json) => UserBadgeView(name: json['name']?.toString() ?? '');
}

enum ProofEventKind { mission, campaign, purchase, subscription, tip, attendance, milestone }

class ProofEventView {
  final ProofEventKind kind;
  final DateTime at;
  final String title;
  final String subtitle;
  final int prestigeDelta;

  ProofEventView({required this.kind, required this.at, required this.title, required this.subtitle, required this.prestigeDelta});

  factory ProofEventView.fromJson(Map<String, dynamic> json) => ProofEventView(
        kind: ProofEventKind.values.firstWhere((e) => e.toString().split('.').last == (json['kind']?.toString() ?? ''), orElse: () => ProofEventKind.mission),
        at: DateTime.tryParse(json['at']?.toString() ?? '') ?? DateTime.now(),
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        prestigeDelta: int.tryParse((json['prestigeDelta'] ?? json['prestige_delta'])?.toString() ?? '') ?? 0,
      );
}

class PostModel {
  final String id;
  final String title;
  PostModel({required this.id, required this.title});
  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(id: json['id']?.toString() ?? '', title: json['title']?.toString() ?? '');
}

// Progression-related minimal models (placeholders)
class UserProgressionModel {
  final String? userId;
  final String? currentTier;
  final int? prestigeTotal;
  final int? prestigeThisSeason;
  final int? momentumScore;
  final int? missionsCompleted;
  final int? milestonesCompleted;
  final int? campaignsParticipated;

  UserProgressionModel({this.userId, this.currentTier, this.prestigeTotal, this.prestigeThisSeason, this.momentumScore, this.missionsCompleted, this.milestonesCompleted, this.campaignsParticipated});

  factory UserProgressionModel.fromJson(Map<String, dynamic> json) => UserProgressionModel(
        userId: json['user_id']?.toString(),
        currentTier: json['current_tier']?.toString(),
        prestigeTotal: int.tryParse((json['prestige_total'] ?? '').toString()) ?? 0,
        prestigeThisSeason: int.tryParse((json['prestige_this_season'] ?? '').toString()) ?? 0,
        momentumScore: int.tryParse((json['momentum_score'] ?? '').toString()) ?? 0,
        missionsCompleted: int.tryParse((json['missions_completed'] ?? '').toString()) ?? 0,
        milestonesCompleted: int.tryParse((json['milestones_completed'] ?? '').toString()) ?? 0,
        campaignsParticipated: int.tryParse((json['campaigns_participated'] ?? '').toString()) ?? 0,
      );
}

class MissionModel {
  final String id;
  final String title;
  final String? campaignId;
  final String? timeWindow;
  final String? status;
  final int? prestigeReward;
  final String? badgeRewardCode;

  MissionModel({required this.id, required this.title, this.campaignId, this.timeWindow, this.status, this.prestigeReward, this.badgeRewardCode});

  factory MissionModel.fromJson(Map<String, dynamic> json) => MissionModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        campaignId: json['campaign_id']?.toString(),
        timeWindow: json['time_window']?.toString(),
        status: json['status']?.toString(),
        prestigeReward: int.tryParse((json['prestige_reward'] ?? '').toString()) ?? 0,
        badgeRewardCode: json['badge_reward_code']?.toString(),
      );
}

class UserMissionModel {
  final String id;
  final String? userId;
  final String? status;

  UserMissionModel({required this.id, this.userId, this.status});

  factory UserMissionModel.fromJson(Map<String, dynamic> json) => UserMissionModel(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString(),
        status: json['status']?.toString(),
      );
}

class MissionListItemModel {
  final MissionModel mission;
  final UserMissionModel? userMission;
  MissionListItemModel({required this.mission, this.userMission});
}

class CampaignModel {
  final String id;
  final String title;
  final String status;
  final String visibility;
  CampaignModel({required this.id, required this.title, this.status = 'active', this.visibility = 'public'});

  factory CampaignModel.fromJson(Map<String, dynamic> json) => CampaignModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        status: json['status']?.toString() ?? 'active',
        visibility: json['visibility']?.toString() ?? 'public',
      );
}

class CampaignListItemModel {
  final CampaignModel campaign;
  final bool isJoined;
  CampaignListItemModel({required this.campaign, this.isJoined = false});
}

class MilestoneModel {
  final String id;
  final String title;
  MilestoneModel({required this.id, required this.title});
  factory MilestoneModel.fromJson(Map<String, dynamic> json) => MilestoneModel(id: json['id']?.toString() ?? '', title: json['title']?.toString() ?? '');
}

class UserMilestoneModel {
  final String id;
  final String? userId;
  UserMilestoneModel({required this.id, this.userId});
  factory UserMilestoneModel.fromJson(Map<String, dynamic> json) => UserMilestoneModel(id: json['id']?.toString() ?? '', userId: json['user_id']?.toString());
}
