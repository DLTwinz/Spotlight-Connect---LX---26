import 'package:spotlight_connect/models/mission_list_item_model.dart';
import 'package:spotlight_connect/models/user_mission_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:spotlight_connect/models/mission_model.dart';
import 'package:spotlight_connect/models/campaign_model.dart';
import 'package:spotlight_connect/models/milestone_model.dart';
import 'package:spotlight_connect/models/user_progression_model.dart';

class ProgressionService extends ChangeNotifier {
  ProgressionService();

  SupabaseClient get _client => Supabase.instance.client;

  bool _initialized = false;
  bool get isInitialized => _initialized;
  bool _isLoading = false;
  String? _lastError;

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  UserProgressionModel? _progression;
  UserProgressionModel? get progression => _progression;

  List<UserMilestoneModel> _userMilestones = const [];
  List<UserMilestoneModel> get userMilestones => _userMilestones;

  List<MilestoneModel> _allMilestones = const [];
  List<MilestoneModel> get allMilestones => _allMilestones;

  MissionListItemModel? _primaryMission;
  MissionListItemModel? get primaryMission => _primaryMission;

  CampaignModel? _primaryCampaign;
  CampaignModel? get primaryCampaign => _primaryCampaign;

  List<MissionListItemModel> _missions = const [];
  List<MissionListItemModel> get missions => _missions;

  List<CampaignListItemModel> _campaigns = const [];
  List<CampaignListItemModel> get campaigns => _campaigns;

  Map<String, List<MissionListItemModel>> _missionSections = const {};
  Map<String, List<MissionListItemModel>> get missionSections => _missionSections;

  Map<String, List<CampaignListItemModel>> _campaignSections = const {};
  Map<String, List<CampaignListItemModel>> get campaignSections => _campaignSections;

  List<UserBadgeView> _badges = const [];
  List<UserBadgeView> get badges => _badges;

  List<ProofEventView> _proofEvents = const [];
  List<ProofEventView> get proofEvents => _proofEvents;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    await refreshHome();
  }

  Future<void> refreshHome() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await Future.wait([
        _loadProgression(),
        _loadMilestones(),
        _loadPrimaryMissionAndMissionIndex(),
        _loadPrimaryCampaignAndCampaignIndex(),
        _loadBadgesAndProof(),
      ]);
    } catch (e) {
      debugPrint('ProgressionService refreshHome failed: $e');
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProgression() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      _progression = null;
      return;
    }

    try {
      final row = await _client.from('user_progression').select('*').eq('user_id', uid).maybeSingle();
      if (row == null) {
        _progression = UserProgressionModel(
          userId: uid,
          currentTier: 'Starter',
          prestigeTotal: 0,
          prestigeThisSeason: 0,
          momentumScore: 0,
          missionsCompleted: 0,
          milestonesCompleted: 0,
          campaignsParticipated: 0,
          nextTierPrestigeRequired: null,
          nextTierMissionRequirements: null,
          createdAt: null,
          updatedAt: null,
        );
      } else {
        _progression = UserProgressionModel.fromJson(Map<String, dynamic>.from(row));
      }
    } catch (e) {
      debugPrint('ProgressionService: failed to load user_progression: $e');
      rethrow;
    }
  }

  Future<void> _loadMilestones() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      _userMilestones = const [];
      _allMilestones = const [];
      return;
    }
    try {
      final rows = await _client
          .from('user_milestones')
          .select('*')
          .eq('user_id', uid)
          .order('achieved_at', ascending: false)
          .limit(200);
      _userMilestones = (rows as List).whereType<Map>().map((e) => UserMilestoneModel.fromJson(Map<String, dynamic>.from(e))).toList();

      final allRows = await _client.from('milestones').select('*').eq('active', true).order('created_at', ascending: true).limit(400);
      _allMilestones = (allRows as List).whereType<Map>().map((e) => MilestoneModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      debugPrint('ProgressionService: failed to load milestones: $e');
      // Don’t rethrow; progress page can degrade gracefully.
      _userMilestones = const [];
      _allMilestones = const [];
    }
  }

  Future<void> _loadPrimaryMissionAndMissionIndex() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      _primaryMission = null;
      _missions = const [];
      _missionSections = const {};
      return;
    }

    // Preferred read path: stable edge DTO.
    try {
      final resp = await _client.functions.invoke('missions_list', body: {'limit': 80});
      final data = resp.data;
      if (data is Map && data['items'] is List) {
        final items = <MissionListItemModel>[];
        for (final raw in (data['items'] as List).whereType<Map>()) {
          final missionRaw = raw['mission'] is Map ? Map<String, dynamic>.from(raw['mission'] as Map) : null;
          if (missionRaw == null) continue;
          final mission = MissionModel.fromJson(missionRaw);
          final umRaw = raw['user_mission'] is Map ? Map<String, dynamic>.from(raw['user_mission'] as Map) : null;
          final um = umRaw == null ? null : UserMissionModel.fromJson(umRaw);
          items.add(MissionListItemModel(mission: mission, userMission: um));
        }
        _missions = items;
      } else {
        debugPrint('missions_list returned unexpected shape: ${data.runtimeType}');
        _missions = const [];
      }
    } catch (e) {
      // Fallback to legacy table joins.
      debugPrint('ProgressionService: missions_list failed, falling back to tables: $e');
      final primaryRows = await _client
          .from('user_missions')
          .select('*, missions(*)')
          .eq('user_id', uid)
          // DB uses server/status terms; avoid UI-only values like 'in_progress'.
          .inFilter('status', ['available', 'active', 'claimable', 'claimed', 'locked'])
          .order('updated_at', ascending: false)
          .limit(60);

      final missionItems = <MissionListItemModel>[];
      for (final r in (primaryRows as List).whereType<Map>()) {
        final row = Map<String, dynamic>.from(r);
        if (row['missions'] is! Map) continue;
        final mission = MissionModel.fromJson(Map<String, dynamic>.from(row['missions'] as Map));
        final um = UserMissionModel.fromJson(row);
        missionItems.add(MissionListItemModel(mission: mission, userMission: um));
      }
      _missions = missionItems;
    }

    final missionItems = _missions;

    MissionListItemModel? primary;
    for (final m in missionItems) {
      final s = (m.userMission?.status ?? '').toLowerCase();
      if (s == 'available' || s == 'in_progress') {
        primary = m;
        break;
      }
    }
    _primaryMission = primary ?? (missionItems.isEmpty ? null : missionItems.first);

    // Build sections for /missions.
    final today = <MissionListItemModel>[];
    final campaign = <MissionListItemModel>[];
    final alwaysOn = <MissionListItemModel>[];

    for (final item in missionItems) {
      final tw = (item.mission.timeWindow ?? '').toLowerCase();
      final status = item.computedStatus;
      final isActive = status == 'available' || status == 'in_progress' || status == 'completed';
      if (!isActive) continue;

      if (tw == 'daily' || tw == 'weekly') {
        today.add(item);
      } else if (item.mission.campaignId != null || tw == 'campaign') {
        campaign.add(item);
      } else {
        // lifetime or everything else.
        if (status != 'claimed') alwaysOn.add(item);
      }
    }

    _missionSections = {
      'Today’s priorities': today,
      'Campaign missions': campaign,
      'Always-on missions': alwaysOn,
    };
  }

  Future<void> _loadPrimaryCampaignAndCampaignIndex() async {
    final uid = _client.auth.currentUser?.id;
    List<CampaignListItemModel> items;
    try {
      final resp = await _client.functions.invoke('campaigns_list', body: {'limit': 60});
      final data = resp.data;
      if (data is Map && data['items'] is List) {
        items = [];
        for (final raw in (data['items'] as List).whereType<Map>()) {
          final cRaw = raw['campaign'] is Map ? Map<String, dynamic>.from(raw['campaign'] as Map) : null;
          if (cRaw == null) continue;
          final c = CampaignModel.fromJson(cRaw);
          final meRaw = raw['me'] is Map ? Map<String, dynamic>.from(raw['me'] as Map) : null;
          final status = (meRaw?['status'] ?? '').toString().toLowerCase();
          final joined = meRaw != null && status != 'left';
          items.add(CampaignListItemModel(campaign: c, isJoined: joined));
        }
      } else {
        debugPrint('campaigns_list returned unexpected shape: ${data.runtimeType}');
        items = const [];
      }
    } catch (e) {
      debugPrint('ProgressionService: campaigns_list failed, falling back to tables: $e');
      final rows = await _client
          .from('campaigns')
          .select('*')
          .eq('visibility', 'public')
          .inFilter('status', ['active', 'scheduled', 'draft', 'ended'])
          .order('priority', ascending: false)
          .limit(80);
      final all = (rows as List).whereType<Map>().map((e) => CampaignModel.fromJson(Map<String, dynamic>.from(e))).toList();

      final joinedCampaignIds = <String>{};
      if (uid != null && uid.isNotEmpty) {
        try {
          final joinedRows = await _client.from('user_missions').select('campaign_id').eq('user_id', uid).not('campaign_id', 'is', null).limit(400);
          for (final r in (joinedRows as List).whereType<Map>()) {
            final id = (r['campaign_id'] ?? '').toString();
            if (id.isNotEmpty) joinedCampaignIds.add(id);
          }
        } catch (e) {
          debugPrint('ProgressionService: failed to load joined campaign ids: $e');
        }
      }
      items = all.map((c) => CampaignListItemModel(campaign: c, isJoined: joinedCampaignIds.contains(c.id))).toList();
    }

    _campaigns = items;

    CampaignModel? primaryCampaign;
    for (final c in items.map((e) => e.campaign)) {
      if (c.status.toLowerCase() == 'active' && c.visibility.toLowerCase() == 'public') {
        primaryCampaign = c;
        break;
      }
    }
    _primaryCampaign = primaryCampaign ?? (items.isEmpty ? null : items.first.campaign);

    // Sections for /campaigns.
    final active = <CampaignListItemModel>[];
    final joined = <CampaignListItemModel>[];
    for (final i in items) {
      if (i.isJoined) joined.add(i);
      if (i.campaign.status.toLowerCase() == 'active') active.add(i);
    }
    _campaignSections = {
      'Active campaigns': active,
      'Your participation': joined,
    };
  }

  Future<UserMissionModel?> startMission(String missionId) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null || uid.isEmpty) return null;

      // Preferred: server-authoritative start (enforces policy + validates window).
      final resp = await _client.functions.invoke('mission_start', body: {'mission_id': missionId});
      final data = resp.data;
      if (data is Map && data['user_mission'] is Map) {
        await refreshHome();
        return UserMissionModel.fromJson(Map<String, dynamic>.from(data['user_mission'] as Map));
      }

      debugPrint('mission_start returned unexpected shape: ${data.runtimeType}');
      return null;
    } catch (e) {
      debugPrint('ProgressionService startMission failed: $e');
      _lastError = e.toString();
      notifyListeners();
    }
    return null;
  }

  Future<bool> claimMission(String userMissionId) async {
    try {
      // Preferred path: secure RPC that validates completion and grants prestige.
      try {
        await _client.rpc('fn_claim_mission_reward', params: {'user_mission_id': userMissionId});
      } catch (e) {
        // Back-compat: edge function from previous iteration.
        debugPrint('fn_claim_mission_reward failed, falling back to edge function: $e');
        await _client.functions.invoke('mission_claim', body: {'user_mission_id': userMissionId});
      }
      await refreshHome();
      return true;
    } catch (e) {
      debugPrint('ProgressionService claimMission failed: $e');
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinCampaign(String campaignId) async {
    try {
      // Recommended: server-side join to create starter user_missions rows.
      // We call the edge function created for this app.
      await _client.functions.invoke('campaign_join', body: {'campaign_id': campaignId});
      await refreshHome();
      return true;
    } catch (e) {
      debugPrint('ProgressionService joinCampaign failed: $e');
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> leaveCampaign(String campaignId) async {
    try {
      await _client.functions.invoke('campaign_leave', body: {'campaign_id': campaignId});
      await refreshHome();
      return true;
    } catch (e) {
      debugPrint('ProgressionService leaveCampaign failed: $e');
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<CampaignModel?> loadCampaignById(String campaignId) async {
    try {
      final row = await _client.from('campaigns').select('*').eq('id', campaignId).maybeSingle();
      if (row == null) return null;
      return CampaignModel.fromJson(Map<String, dynamic>.from(row));
    } catch (e) {
      debugPrint('ProgressionService loadCampaignById failed: $e');
      _lastError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<MissionListItemModel>> loadCampaignMissions(String campaignId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return const [];
    try {
      final rows = await _client
          .from('missions')
          .select('*, user_missions!left(*)')
          .eq('campaign_id', campaignId)
          .eq('status', 'active')
          .order('created_at', ascending: true)
          .limit(200);

      final out = <MissionListItemModel>[];
      for (final r in (rows as List).whereType<Map>()) {
        final row = Map<String, dynamic>.from(r);
        final mission = MissionModel.fromJson(row);
        // PostgREST join returns list for left join; we only want the current user's row.
        UserMissionModel? um;
        final umRaw = row['user_missions'];
        if (umRaw is List) {
          final forMe = umRaw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).where((e) => (e['user_id'] ?? '').toString() == uid).toList();
          if (forMe.isNotEmpty) um = UserMissionModel.fromJson(forMe.first);
        }
        out.add(MissionListItemModel(mission: mission, userMission: um));
      }
      return out;
    } catch (e) {
      debugPrint('ProgressionService loadCampaignMissions failed: $e');
      _lastError = e.toString();
      notifyListeners();
      return const [];
    }
  }

  Future<void> _loadBadgesAndProof() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      _badges = const [];
      _proofEvents = const [];
      return;
    }

    try {
      final badgeRows = await _client
          .from('user_badges')
          .select('id, awarded_at, reward_badges ( id, name, badge_type, description, image_url )')
          .eq('user_id', uid)
          .order('awarded_at', ascending: false)
          .limit(50);

      final badges = <UserBadgeView>[];
      for (final r in (badgeRows as List).whereType<Map>()) {
        final row = Map<String, dynamic>.from(r);
        final bRaw = row['reward_badges'];
        if (bRaw is! Map) continue;
        badges.add(
          UserBadgeView(
            id: (row['id'] ?? '').toString(),
            badgeId: (bRaw['id'] ?? '').toString(),
            name: (bRaw['name'] ?? '').toString(),
            badgeType: (bRaw['badge_type'] ?? '').toString(),
            description: (bRaw['description'] ?? '').toString().trim().isEmpty ? null : (bRaw['description'] ?? '').toString(),
            imageUrl: (bRaw['image_url'] ?? '').toString().trim().isEmpty ? null : (bRaw['image_url'] ?? '').toString(),
            awardedAt: DateTime.tryParse((row['awarded_at'] ?? '').toString()),
          ),
        );
      }
      _badges = badges;
    } catch (e) {
      debugPrint('ProgressionService: failed to load user_badges: $e');
      _badges = const [];
    }

    try {
      final missionRows = await _client
          .from('user_missions')
          .select('id, status, claimed_at, completed_at, updated_at, prestige_earned, missions ( id, title, prestige_reward, badge_reward_code, campaign_id )')
          .eq('user_id', uid)
          .order('updated_at', ascending: false)
          .limit(40);

      final events = <ProofEventView>[];
      for (final r in (missionRows as List).whereType<Map>()) {
        final row = Map<String, dynamic>.from(r);
        final mRaw = row['missions'];
        if (mRaw is! Map) continue;
        final title = (mRaw['title'] ?? '').toString();
        if (title.trim().isEmpty) continue;

        final status = (row['status'] ?? '').toString().toLowerCase();
        final claimedAt = DateTime.tryParse((row['claimed_at'] ?? '').toString());
        final completedAt = DateTime.tryParse((row['completed_at'] ?? '').toString());
        final updatedAt = DateTime.tryParse((row['updated_at'] ?? '').toString());

        final when = claimedAt ?? completedAt ?? updatedAt;
        if (when == null) continue;

        // Only treat completed/claimed missions as proof events.
        final isProof = status == 'claimed' || status == 'completed' || status == 'claimable';
        if (!isProof) continue;

        final prestigeEarned = _asInt(row['prestige_earned']);
        final badgeCode = (mRaw['badge_reward_code'] ?? '').toString().trim().isEmpty ? null : (mRaw['badge_reward_code'] ?? '').toString();
        final subtitleParts = <String>[];
        if (prestigeEarned > 0) subtitleParts.add('+$prestigeEarned Prestige');
        if (badgeCode != null) subtitleParts.add('Badge unlocked');
        final subtitle = subtitleParts.isEmpty ? 'Completed mission' : subtitleParts.join(' • ');

        events.add(
          ProofEventView(
            kind: ProofEventKind.mission,
            title: title,
            subtitle: subtitle,
            at: when,
            prestigeDelta: prestigeEarned,
          ),
        );
      }

      // Campaign participation proof: membership join events.
      try {
        final campRows = await _client
            .from('user_campaign_memberships')
            .select('id, joined_at, campaigns ( id, title, status )')
            .eq('user_id', uid)
            .order('joined_at', ascending: false)
            .limit(30);
        for (final r in (campRows as List).whereType<Map>()) {
          final row = Map<String, dynamic>.from(r);
          final cRaw = row['campaigns'];
          if (cRaw is! Map) continue;
          final title = (cRaw['title'] ?? '').toString();
          if (title.trim().isEmpty) continue;
          final joinedAt = DateTime.tryParse((row['joined_at'] ?? '').toString());
          if (joinedAt == null) continue;
          events.add(
            ProofEventView(
              kind: ProofEventKind.campaign,
              title: title,
              subtitle: 'Joined campaign',
              at: joinedAt,
              prestigeDelta: 0,
            ),
          );
        }
      } catch (e) {
        debugPrint('ProgressionService: failed to load user_campaign_memberships: $e');
      }

      events.sort((a, b) => b.at.compareTo(a.at));
      _proofEvents = events.take(60).toList(growable: false);
    } catch (e) {
      debugPrint('ProgressionService: failed to load proof events: $e');
      _proofEvents = const [];
    }
  }

  static int _asInt(Object? v) => v is int ? v : int.tryParse('$v') ?? 0;
}

enum ProofEventKind { mission, campaign }

@immutable
class UserBadgeView {
  const UserBadgeView({
    required this.id,
    required this.badgeId,
    required this.name,
    required this.badgeType,
    required this.description,
    required this.imageUrl,
    required this.awardedAt,
  });

  final String id;
  final String badgeId;
  final String name;
  final String badgeType;
  final String? description;
  final String? imageUrl;
  final DateTime? awardedAt;
}

@immutable
class ProofEventView {
  const ProofEventView({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.at,
    required this.prestigeDelta,
  });

  final ProofEventKind kind;
  final String title;
  final String subtitle;
  final DateTime at;
  final int prestigeDelta;
}
