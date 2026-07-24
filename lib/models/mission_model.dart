class MissionModel {
  final String id;
  final String title;
  final String description; // Added for UI
  final String shortLabel; // Added for UI
  final String actionType;
  final int targetValue;
  final int prestigeReward;
  final String status;
  final String? campaignId;
  final String? timeWindow;

  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.shortLabel,
    required this.actionType,
    required this.targetValue,
    required this.prestigeReward,
    required this.status,
    this.campaignId,
    this.timeWindow,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled Mission',
      description: json['description'] ?? '',
      shortLabel: json['short_label'] ?? '',
      actionType: json['action_type'] ?? 'none',
      targetValue: json['target_value'] ?? 0,
      prestigeReward: json['prestige_reward'] ?? 0,
      status: json['status'] ?? 'inactive',
      campaignId: json['campaign_id'],
      timeWindow: json['time_window'],
    );
  }
}
