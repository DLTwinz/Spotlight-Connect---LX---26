import 'mission_model.dart';
import 'user_mission_model.dart';

class MissionListItemModel {
  final MissionModel mission;
  final UserMissionModel? userMission;

  MissionListItemModel({required this.mission, this.userMission});

  String get computedStatus {
    if (userMission == null) return 'available';
    return userMission!.status;
  }

  // UI Helpers for progress bars and buttons
  double get progressValue => (userMission?.currentProgress ?? 0).toDouble();
  double get progressTarget => mission.targetValue.toDouble();
  double get progressPct => progressTarget > 0
      ? (progressValue / progressTarget).clamp(0.0, 1.0)
      : 0.0;

  String get cta {
    if (computedStatus == 'completed') return 'Mission Completed';
    if (computedStatus == 'in_progress') return 'Continue Mission';
    return 'Start Mission';
  }
}
