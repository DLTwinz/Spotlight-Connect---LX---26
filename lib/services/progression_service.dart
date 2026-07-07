import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.prestigeReward,
    required this.status,
    required this.tags,
  });

  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final int prestigeReward;
  final String status;
  final List<String> tags;

  double get progressFraction =>
      targetValue == 0 ? 0.0 : (currentValue / targetValue).clamp(0.0, 1.0);

  factory Mission.fromMap(Map<String, dynamic> m) => Mission(
        id: m['id']?.toString() ?? '',
        title: m['title']?.toString() ?? '',
        description: m['description']?.toString() ?? '',
        targetValue: _parseInt(m['target_value']),
        currentValue: _parseInt(m['current_value']),
        prestigeReward: _parseInt(m['prestige_reward']),
        status: m['status']?.toString() ?? 'active',
        tags: List<String>.from(m['tags'] as List? ?? []),
      );

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}

class Campaign {
  const Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.prestigeReward,
    required this.status,
    required this.endsAt,
  });

  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final int prestigeReward;
  final String status;
  final DateTime? endsAt;

  double get progressFraction =>
      targetValue == 0 ? 0.0 : (currentValue / targetValue).clamp(0.0, 1.0);

  factory Campaign.fromMap(Map<String, dynamic> m) => Campaign(
        id: m['id']?.toString() ?? '',
        title: m['title']?.toString() ?? '',
        description: m['description']?.toString() ?? '',
        targetValue: Mission._parseInt(m['target_value']),
        currentValue: Mission._parseInt(m['current_value']),
        prestigeReward: Mission._parseInt(m['prestige_reward']),
        status: m['status']?.toString() ?? 'active',
        endsAt: m['ends_at'] == null
            ? null
            : DateTime.tryParse(m['ends_at'].toString()),
      );
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class ProgressionService extends ChangeNotifier {
  ProgressionService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  bool _isLoading = false;
  final List<Mission> _missions = [];
  final List<Campaign> _campaigns = [];

  SupabaseClient get client => _client;
  bool get isLoading => _isLoading;
  List<Mission> get missions => List.unmodifiable(_missions);
  List<Campaign> get campaigns => List.unmodifiable(_campaigns);

  Future<void> ensureInitialized() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([_loadMissions(), _loadCampaigns()]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMissions() async {
    final rows = await _client
        .from('missions')
        .select('*')
        .order('created_at', ascending: false)
        .limit(100);
    _missions
      ..clear()
      ..addAll((rows as List).map((r) => Mission.fromMap(r as Map<String, dynamic>)));
  }

  Future<void> _loadCampaigns() async {
    final rows = await _client
        .from('campaigns')
        .select('*')
        .order('created_at', ascending: false)
        .limit(100);
    _campaigns
      ..clear()
      ..addAll((rows as List).map((r) => Campaign.fromMap(r as Map<String, dynamic>)));
  }

  Mission? missionById(String id) =>
      _missions.where((m) => m.id == id).firstOrNull;

  Campaign? campaignById(String id) =>
      _campaigns.where((c) => c.id == id).firstOrNull;
}
