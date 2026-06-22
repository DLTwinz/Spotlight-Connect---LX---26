import 'package:spotlight_connect/features/verified_fandom/providers/verified_fandom_providers.dart';

class MissionComposerService {
  // ... rest of your code ...

  /// Determines if a fan is authorized to view or accept a specific mission
  bool isMissionUnlocked({
    required TrustLabel fanStatus,
    required TrustLabel requiredStatus,
  }) {
    // If the mission requires no special status, it's open to all verified fans
    if (requiredStatus == TrustLabel.verified) return true;

    // The Ecosystem Hierarchy: Captains > Ambassadors > Candidates > Repeat > Verified
    switch (requiredStatus) {
      case TrustLabel.captain:
        return fanStatus == TrustLabel.captain;
      case TrustLabel.ambassador:
        return fanStatus == TrustLabel.captain || 
               fanStatus == TrustLabel.ambassador;
      case TrustLabel.ambassadorCandidate:
        return fanStatus == TrustLabel.captain || 
               fanStatus == TrustLabel.ambassador || 
               fanStatus == TrustLabel.ambassadorCandidate;
      case TrustLabel.repeatSupporter:
        return fanStatus != TrustLabel.verified && 
               fanStatus != TrustLabel.riskFlagged;
      default:
        return false;
    }
  }

  /// Evaluates an entire campaign list and returns only the authorized missions
  List<Map<String, dynamic>> filterAvailableMissions(
    List<Map<String, dynamic>> allMissions, 
    TrustLabel currentFanStatus
  ) {
    return allMissions.where((mission) {
      // Defaults to 'verified' if the brand didn't set a restriction
      final requiredLevel = mission['required_trust_label'] ?? TrustLabel.verified;
      
      return isMissionUnlocked(
        fanStatus: currentFanStatus, 
        requiredStatus: requiredLevel
      );
    }).toList();
  }
}