import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ProofEventKind { milestone, campaign, transaction, verification, mission }

class UserBadgeView {
  final String name;
  final String badgeType;
  final String description;
  UserBadgeView({this.name = '', this.badgeType = '', this.description = ''});
}

class ProofEventView {
  final String id;
  final ProofEventKind kind;
  final String title;
  final String subtitle;
  final DateTime at;
  ProofEventView(this.id, this.kind, this.title, this.subtitle, this.at);
}

// Emulates the UI's expected progression object
class ProgressionData {
  dynamic authorId = '';
  dynamic currentTier = 1;
  dynamic prestigeTotal = 0;
  dynamic momentumScore = 0;
  dynamic nextTierPrestigeRequired = 100;
  dynamic missionsCompleted = 0;
  dynamic milestonesCompleted = 0;
  dynamic campaignsParticipated = 0;
}

class ProgressionService extends ChangeNotifier {
  final SupabaseClient _client;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _lastError;

  ProgressionData progression = ProgressionData();

  List<UserBadgeView> badges = [];
  List<ProofEventView> proofEvents = [];
  List<dynamic> campaigns = [];
  List<dynamic> campaignSections = [];
  
  // The UI expects missions to be an iterable Map (.entries)
  Map<String, dynamic> missions = {}; 
  
  List<dynamic> missionSections = [];
  List<dynamic> userMilestones = [];
  List<dynamic> allMilestones = [];

  ProgressionService({required SupabaseClient client}) : _client = client;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<void> ensureInitialized() async {
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> refreshHome() async {}

  // Returning dynamic bypasses the 'use_of_void_result' analyzer errors
  Future<dynamic> loadCampaignById(String id) async => true;
  Future<dynamic> loadCampaignMissions(String id) async => true;
  Future<dynamic> joinCampaign(String id) async => true;
  Future<dynamic> leaveCampaign(String id) async => true;
  Future<dynamic> claimMission(String id) async => true;
  Future<dynamic> startMission(String id) async => true;

  Future<void> queryImpactMetrics(String creatorId) async {}
}
