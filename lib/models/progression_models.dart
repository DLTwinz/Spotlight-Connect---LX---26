// Minimal temporary compatibility shims for compilation.
// Replace with the full, authoritative models when available.

class UserBadgeView {
  final String id;
  final String name;
  final String? badgeType;
  final String? description;
  final String? imageUrl;
  final DateTime? awardedAt;

  UserBadgeView({required this.id, required this.name, this.badgeType, this.description, this.imageUrl, this.awardedAt});

  factory UserBadgeView.fromJson(Map<String, dynamic> json) => UserBadgeView(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        badgeType: json['badge_type']?.toString(),
        description: json['description']?.toString(),
        imageUrl: json['image_url']?.toString(),
        awardedAt: json['awarded_at'] == null ? null : DateTime.tryParse(json['awarded_at'].toString()),
      );
}

enum ProofEventKind { mission, campaign, purchase, subscription, tip, attendance, milestone }

class ProofEventView {
  final ProofEventKind kind;
  final DateTime at;
  final String title;
  final String subtitle;
  final int prestigeDelta;

  ProofEventView({required this.kind, required this.at, required this.title, required this.subtitle, required this.prestigeDelta});

  factory ProofEventView.fromJson(Map<String, dynamic> json) {
    final kindStr = (json['kind'] ?? json['event_kind'])?.toString() ?? '';
    final kind = ProofEventKind.values.firstWhere((e) => e.toString().split('.').last == kindStr, orElse: () => ProofEventKind.mission);
    return ProofEventView(
      kind: kind,
      at: DateTime.tryParse(json['at']?.toString() ?? '') ?? DateTime.now(),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      prestigeDelta: int.tryParse((json['prestige_delta'] ?? json['prestigeDelta'] ?? '0').toString()) ?? 0,
    );
  }
}

class UserProgressionModel {
  final String? userId;
  final String? currentTier;
  final int prestigeTotal;
  final int prestigeThisSeason;
  final int momentumScore;
  final int missionsCompleted;
  final int milestonesCompleted;
  final int campaignsParticipated;
  final int? nextTierPrestigeRequired;

  UserProgressionModel({
    this.userId,
    this.currentTier,
    this.prestigeTotal = 0,
    this.prestigeThisSeason = 0,
    this.momentumScore = 0,
    this.missionsCompleted = 0,
    this.milestonesCompleted = 0,
    this.campaignsParticipated = 0,
    this.nextTierPrestigeRequired,
  });

  factory UserProgressionModel.fromJson(Map<String, dynamic> json) => UserProgressionModel(
        userId: json['user_id']?.toString(),
        currentTier: json['current_tier']?.toString(),
        prestigeTotal: int.tryParse((json['prestige_total'] ?? '0').toString()) ?? 0,
        prestigeThisSeason: int.tryParse((json['prestige_this_season'] ?? '0').toString()) ?? 0,
        momentumScore: int.tryParse((json['momentum_score'] ?? '0').toString()) ?? 0,
        missionsCompleted: int.tryParse((json['missions_completed'] ?? '0').toString()) ?? 0,
        milestonesCompleted: int.tryParse((json['milestones_completed'] ?? '0').toString()) ?? 0,
        campaignsParticipated: int.tryParse((json['campaigns_participated'] ?? '0').toString()) ?? 0,
        nextTierPrestigeRequired: json['next_tier_prestige_required'] == null ? null : int.tryParse(json['next_tier_prestige_required'].toString()),
      );
}

class MissionModel {
  final String id;
  final String title;
  final String? campaignId;
  final String? timeWindow;
  final String? status;
  final int prestigeReward;
  final String? badgeRewardCode;

  MissionModel({required this.id, required this.title, this.campaignId, this.timeWindow, this.status, this.prestigeReward = 0, this.badgeRewardCode});

  factory MissionModel.fromJson(Map<String, dynamic> json) => MissionModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        campaignId: json['campaign_id']?.toString(),
        timeWindow: json['time_window']?.toString(),
        status: json['status']?.toString(),
        prestigeReward: int.tryParse((json['prestige_reward'] ?? '0').toString()) ?? 0,
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
