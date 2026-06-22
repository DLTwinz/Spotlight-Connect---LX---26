import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:spotlight_connect/backend/backend_mode.dart';
import 'package:spotlight_connect/models/opportunity_application_model.dart';
import 'package:spotlight_connect/models/opportunity_model.dart';
import 'package:spotlight_connect/supabase/supabase_config.dart';
import 'package:spotlight_connect/storage/key_value_store.dart';

class OpportunityService extends ChangeNotifier {
  OpportunityService(this._store);

  static const _kSavedKey = 'spotlight_saved_opportunities_v1';
  final KeyValueStore _store;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _initialized = false;

  List<OpportunityModel> _opportunities = const [];
  List<OpportunityModel> get opportunities => _opportunities;

  OpportunityModel? getById(String id) {
    final idx = _opportunities.indexWhere((o) => o.opportunityId == id);
    if (idx == -1) return null;
    return _opportunities[idx];
  }

  Set<String> _saved = <String>{};
  bool isSaved(String id) => _saved.contains(id);
  bool isApplied(String id) => _applications.any((a) => a.opportunityId == id);

  List<OpportunityApplicationModel> _applications = const [];
  List<OpportunityApplicationModel> get applications => _applications;

  List<OpportunityApplicationModel> applicationsForOpportunity(String opportunityId) =>
      _applications.where((a) => a.opportunityId == opportunityId).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  OpportunityApplicationModel? applicationForUser(String opportunityId, String userId) {
    try {
      return _applications.firstWhere((a) => a.opportunityId == opportunityId && a.applicantUserId == userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    await _loadSaved();
    await refresh();
  }

  Future<void> _loadSaved() async {
    _isLoading = true;
    notifyListeners();
    try {
      final uid = _uid;

      // Launch-critical behavior: when running in Supabase mode, we never fall
      // back to local KeyValueStore persistence.
      if (_isSupabaseMode) {
        if (uid == null) {
          _saved = <String>{};
          return;
        }
        final rows = await SupabaseConfig.client.from('opportunity_saves').select('opportunity_id').eq('user_id', uid);
        _saved = (rows as List)
            .map((e) => (e is Map ? e['opportunity_id'] : null)?.toString())
            .whereType<String>()
            .toSet();
        return;
      }

      // Mock/local mode: prefer Supabase when authenticated.
      if (uid != null) {
        try {
          final rows = await SupabaseConfig.client.from('opportunity_saves').select('opportunity_id').eq('user_id', uid);
          _saved = (rows as List)
              .map((e) => (e is Map ? e['opportunity_id'] : null)?.toString())
              .whereType<String>()
              .toSet();
          return;
        } catch (e) {
          debugPrint('OpportunityService: failed to load saved from Supabase: $e');
        }
      }

      final rawSaved = await _store.getString(_kSavedKey);

      Set<String> decodeIdSet(String? raw) {
        if (raw == null || raw.trim().isEmpty) return <String>{};
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) return decoded.map((e) => e.toString()).where((e) => e.isNotEmpty).toSet();
        } catch (_) {
          // Backward compatibility for previously stored List.toString() format.
          final decoded = raw
              .replaceAll('[', '')
              .replaceAll(']', '')
              .split(',')
              .map((e) => e.trim().replaceAll('"', ''))
              .where((e) => e.isNotEmpty)
              .toSet();
          if (decoded.isNotEmpty) return decoded;
        }
        return <String>{};
      }

      _saved = decodeIdSet(rawSaved);
      await _persistSets();
    } catch (e) {
      debugPrint('OpportunityService: failed to load saved set: $e');
      _opportunities = const [];
      _saved = <String>{};
      _applications = const [];
      await _persistSets();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? get _uid => SupabaseConfig.client.auth.currentUser?.id;

  bool get _isSupabaseMode => BackendConfig.mode == BackendMode.supabase;

  /// Re-fetches opportunities and applications from Supabase.
  ///
  /// Note: business-side review of applications requires a policy that allows
  /// the opportunity owner to read applications. With current RLS, applicants
  /// (and admins) can read/write their own applications.
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      final uid = _uid;
      if (uid == null) {
        _opportunities = const [];
        _applications = const [];
        return;
      }

      final oppRows = await SupabaseConfig.client
          .from('opportunities')
          .select('id,business_user_id,title,description,category,location_type,compensation_type,status,created_at,updated_at')
          .order('created_at', ascending: false);

      final opps = <OpportunityModel>[];
      for (final row in oppRows) {
        final m = _opportunityFromRow(row.cast<String, dynamic>());
        if (m.opportunityId.isNotEmpty && m.title.isNotEmpty) opps.add(m);
      }
      _opportunities = opps;

      final appRows = await SupabaseConfig.client
          .from('opportunity_applications')
          .select('id,opportunity_id,applicant_user_id,pitch,portfolio_links,availability,business_note,status,created_at,updated_at')
          .eq('applicant_user_id', uid)
          .order('created_at', ascending: false);

      final apps = <OpportunityApplicationModel>[];
      for (final row in appRows) {
        final m = _applicationFromRow(row.cast<String, dynamic>());
        if (m.applicationId.isNotEmpty && m.opportunityId.isNotEmpty && m.applicantUserId.isNotEmpty) apps.add(m);
      }
      _applications = apps;
    } catch (e) {
      debugPrint('OpportunityService: refresh failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleSaved(String id) async {
    final uid = _uid;

    if (_isSupabaseMode) {
      if (uid == null) return;

      final already = _saved.contains(id);
      try {
        if (already) {
          await SupabaseConfig.client.from('opportunity_saves').delete().eq('user_id', uid).eq('opportunity_id', id);
          _saved.remove(id);
        } else {
          await SupabaseConfig.client.from('opportunity_saves').insert({'user_id': uid, 'opportunity_id': id});
          _saved.add(id);
        }
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('OpportunityService: toggleSaved Supabase failed: $e');
        return;
      }
    }

    if (uid != null) {
      final already = _saved.contains(id);
      try {
        if (already) {
          await SupabaseConfig.client.from('opportunity_saves').delete().eq('user_id', uid).eq('opportunity_id', id);
          _saved.remove(id);
        } else {
          await SupabaseConfig.client.from('opportunity_saves').insert({'user_id': uid, 'opportunity_id': id});
          _saved.add(id);
        }
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('OpportunityService: toggleSaved Supabase failed: $e');
      }
    }

    if (_saved.contains(id)) {
      _saved.remove(id);
    } else {
      _saved.add(id);
    }
    notifyListeners();
    await _persistSets();
  }

  Future<void> applyToOpportunity({
    required String opportunityId,
    required String applicantUserId,
    required String applicantEmail,
    required String applicantName,
    required String pitch,
    required List<String> portfolioLinks,
    required String availability,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    if (_applications.any((a) => a.opportunityId == opportunityId && a.applicantUserId == uid)) return;

    try {
      final inserted = await SupabaseConfig.client
          .from('opportunity_applications')
          .insert({
            'opportunity_id': opportunityId,
            'applicant_user_id': uid,
            'pitch': pitch.trim(),
            'portfolio_links': portfolioLinks.where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList(),
            'availability': availability.trim(),
            'business_note': '',
            'status': 'submitted',
          })
          .select('id,opportunity_id,applicant_user_id,pitch,portfolio_links,availability,business_note,status,created_at,updated_at')
          .single();

      final created = _applicationFromRow((inserted as Map).cast<String, dynamic>());
      _applications = [created, ..._applications];
      notifyListeners();
    } catch (e) {
      debugPrint('OpportunityService: apply failed: $e');
    }
  }

  Future<void> updateApplicationStatus({required String applicationId, required String status, String? businessNote}) async {
    final idx = _applications.indexWhere((a) => a.applicationId == applicationId);
    if (idx == -1) return;

    try {
      final updated = await SupabaseConfig.client
          .from('opportunity_applications')
          .update({
            'status': status,
            if (businessNote != null) 'business_note': businessNote,
          })
          .eq('id', applicationId)
          .select('id,opportunity_id,applicant_user_id,pitch,portfolio_links,availability,business_note,status,created_at,updated_at')
          .single();

      final next = _applicationFromRow((updated as Map).cast<String, dynamic>());
      _applications[idx] = next;
      notifyListeners();
    } catch (e) {
      // Most likely RLS: only applicant (or admin) can update.
      debugPrint('OpportunityService: updateApplicationStatus failed: $e');
    }
  }

  Future<void> requestMoreInfo({required String applicationId, required String note}) async {
    await updateApplicationStatus(applicationId: applicationId, status: 'needs_more_info', businessNote: note.trim());
  }

  Future<void> createOpportunity({
    required String postedByUserId,
    required String postedByEmail,
    required String postedByRole,
    required String title,
    required String company,
    required String location,
    required String type,
    required String compensation,
    required String description,
    required List<String> tags,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final inserted = await SupabaseConfig.client
          .from('opportunities')
          .insert({
            'business_user_id': uid,
            'title': title.trim(),
            'description': description.trim(),
            'category': type.trim(),
            'location_type': location.trim(),
            'compensation_type': compensation.trim(),
            'status': 'draft',
          })
          .select('id,business_user_id,title,description,category,location_type,compensation_type,status,created_at,updated_at')
          .single();

      final created = _opportunityFromRow((inserted as Map).cast<String, dynamic>());
      _opportunities = [created, ..._opportunities];
      notifyListeners();
    } catch (e) {
      debugPrint('OpportunityService: createOpportunity failed: $e');
    }
  }

  Future<void> _persistSets() async {
    if (_isSupabaseMode) return;
    try {
      await _store.setString(_kSavedKey, jsonEncode(_saved.toList()));
    } catch (e) {
      debugPrint('OpportunityService: failed to persist sets: $e');
    }
  }

  OpportunityModel _opportunityFromRow(Map<String, dynamic> row) {
    DateTime parseDate(dynamic v) {
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return OpportunityModel(
      opportunityId: (row['id'] ?? '').toString(),
      postedByUserId: (row['business_user_id'] ?? '').toString(),
      postedByEmail: '',
      postedByRole: 'business',
      title: (row['title'] ?? '').toString(),
      company: '',
      location: (row['location_type'] ?? '').toString(),
      type: (row['category'] ?? '').toString(),
      compensation: (row['compensation_type'] ?? '').toString(),
      description: (row['description'] ?? '').toString(),
      tags: const [],
      createdAt: parseDate(row['created_at']),
      updatedAt: parseDate(row['updated_at']),
    );
  }

  OpportunityApplicationModel _applicationFromRow(Map<String, dynamic> row) {
    DateTime parseDate(dynamic v) {
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final portfolio = <String>[];
    final rawPortfolio = row['portfolio_links'];
    if (rawPortfolio is List) {
      for (final item in rawPortfolio) {
        final s = item.toString().trim();
        if (s.isNotEmpty) portfolio.add(s);
      }
    }

    return OpportunityApplicationModel(
      applicationId: (row['id'] ?? '').toString(),
      opportunityId: (row['opportunity_id'] ?? '').toString(),
      applicantUserId: (row['applicant_user_id'] ?? '').toString(),
      applicantEmail: '',
      applicantName: '',
      pitch: (row['pitch'] ?? '').toString(),
      portfolioLinks: portfolio,
      availability: (row['availability'] ?? '').toString(),
      businessNote: (row['business_note'] ?? '').toString(),
      status: (row['status'] ?? '').toString(),
      createdAt: parseDate(row['created_at']),
      updatedAt: parseDate(row['updated_at']),
    );
  }
}
