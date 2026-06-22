class UserMissionModel {
  final String id;
  final String userId;
  final String missionId;
  final int currentProgress;
  final String status;
  final DateTime? completedAt;

  UserMissionModel({
    required this.id,
    required this.userId,
    required this.missionId,
    required this.currentProgress,
    required this.status,
    this.completedAt,
  });

  factory UserMissionModel.fromJson(Map<String, dynamic> json) {
    return UserMissionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      missionId: json['mission_id'] ?? '',
      currentProgress: json['current_progress'] ?? 0,
      status: json['status'] ?? 'active',
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }
}
