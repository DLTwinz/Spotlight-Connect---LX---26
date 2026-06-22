import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:spotlight_connect/backend/backend_mode.dart';
import 'package:spotlight_connect/models/portfolio_model.dart';
import 'package:spotlight_connect/storage/key_value_store.dart';
import 'package:spotlight_connect/supabase/supabase_config.dart';

class PortfolioService extends ChangeNotifier {
  static const _keyPortfolios = 'spotlight_portfolios_v1';

  final KeyValueStore _store;
  final Map<String, PortfolioModel> _byUserId = {};
  bool _loaded = false;

  PortfolioService({KeyValueStore? store}) : _store = store ?? createKeyValueStore();

  bool get _useSupabase => BackendConfig.mode == BackendMode.supabase;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    if (_useSupabase) {
      try {
        await _loadRemote();
      } catch (e) {
        debugPrint('PortfolioService.ensureLoaded remote failed: $e');
      } finally {
        _loaded = true;
        notifyListeners();
      }
      return;
    }
    try {
      final raw = await _store.getString(_keyPortfolios);
      if (raw == null || raw.trim().isEmpty) {
        _byUserId.clear();
      } else {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          _byUserId.clear();
          for (final entry in decoded.entries) {
            final userId = entry.key.toString();
            final value = entry.value;
            if (value is Map) {
              _byUserId[userId] = PortfolioModel.fromJson(value.map((k, v) => MapEntry(k.toString(), v)));
            }
          }
        } else {
          _byUserId.clear();
        }
      }
    } catch (e) {
      debugPrint('PortfolioService.ensureLoaded failed: $e');
      _byUserId.clear();
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _loadRemote() async {
    final rows = (await SupabaseConfig.client
        .from('portfolios')
        .select('user_id,role,headline,location,genres,skills,day_rate_usd,links,media,credits,created_at,updated_at')
        .limit(200)) as List<dynamic>;
    _byUserId.clear();
    for (final raw in rows) {
      if (raw is! Map) continue;
      final map = raw.map((k, v) => MapEntry(k.toString(), v));
      final userId = (map['user_id'] ?? '').toString();
      if (userId.isEmpty) continue;
      _byUserId[userId] = _portfolioFromSupabaseRow(map);
    }
  }

  PortfolioModel _portfolioFromSupabaseRow(Map<String, dynamic> row) {
    final roleStr = (row['role'] ?? 'talent').toString();
    final genres = (row['genres'] is List) ? (row['genres'] as List).map((e) => e.toString()).toList() : <String>[];
    final skills = (row['skills'] is List) ? (row['skills'] as List).map((e) => e.toString()).toList() : <String>[];
    final media = (row['media'] is List) ? (row['media'] as List).map((e) => e.toString()).toList() : <String>[];
    final linksRaw = row['links'];
    final links = linksRaw is Map ? linksRaw.map((k, v) => MapEntry(k.toString(), v.toString())) : <String, String>{};
    final creditsRaw = row['credits'];
    final credits = <PortfolioCredit>[];
    if (creditsRaw is List) {
      for (final item in creditsRaw) {
        if (item is Map) credits.add(PortfolioCredit.fromJson(item.map((k, v) => MapEntry(k.toString(), v))));
      }
    }
    final createdAt = DateTime.tryParse((row['created_at'] ?? '').toString())?.toLocal() ?? DateTime.now();
    final updatedAt = DateTime.tryParse((row['updated_at'] ?? '').toString())?.toLocal() ?? createdAt;
    return PortfolioModel(
      userId: (row['user_id'] ?? '').toString(),
      role: roleStr == 'business' ? PortfolioRole.business : PortfolioRole.talent,
      headline: (row['headline'] ?? '').toString(),
      location: (row['location'] ?? '').toString(),
      genres: genres,
      skills: skills,
      dayRateUsd: (row['day_rate_usd'] is num) ? (row['day_rate_usd'] as num).toInt() : int.tryParse((row['day_rate_usd'] ?? '').toString()),
      links: links,
      media: media,
      credits: credits,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  PortfolioModel? getForUser(String userId) => _byUserId[userId];

  PortfolioModel getOrCreateTalent(String userId, {bool notify = true}) {
    final existing = _byUserId[userId];
    if (existing != null) return existing;
    final now = DateTime.now();
    final created = PortfolioModel(
      userId: userId,
      role: PortfolioRole.talent,
      headline: '',
      location: '',
      genres: const [],
      skills: const [],
      dayRateUsd: null,
      links: const {},
      media: const [],
      credits: const [],
      createdAt: now,
      updatedAt: now,
    );
    _byUserId[userId] = created;
    unawaited(_useSupabase ? _upsertRemote(created) : _persist());
    if (notify) notifyListeners();
    return created;
  }

  Future<void> upsert(PortfolioModel portfolio) async {
    _byUserId[portfolio.userId] = portfolio.copyWith(updatedAt: DateTime.now());
    if (_useSupabase) {
      await _upsertRemote(_byUserId[portfolio.userId]!);
    } else {
      await _persist();
    }
    notifyListeners();
  }

  Future<void> addCredit(String userId, PortfolioCredit credit) async {
    final current = _byUserId[userId] ?? getOrCreateTalent(userId);
    final updated = current.copyWith(credits: [credit, ...current.credits]);
    await upsert(updated);
  }

  Future<void> removeCredit(String userId, String creditId) async {
    final current = _byUserId[userId];
    if (current == null) return;
    final updated = current.copyWith(credits: current.credits.where((c) => c.id != creditId).toList());
    await upsert(updated);
  }

  Future<void> _persist() async {
    if (_useSupabase) return;
    final map = <String, dynamic>{};
    for (final entry in _byUserId.entries) {
      map[entry.key] = entry.value.toJson();
    }
    await _store.setString(_keyPortfolios, jsonEncode(map));
  }

  Future<void> _upsertRemote(PortfolioModel model) async {
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) throw StateError('Must be authenticated to update portfolio');
    if (model.userId != uid) {
      debugPrint('PortfolioService._upsertRemote: userId mismatch; using auth uid');
    }
    try {
      await SupabaseConfig.client.from('portfolios').upsert({
        'user_id': uid,
        'role': model.role.name,
        'headline': model.headline,
        'location': model.location,
        'genres': model.genres,
        'skills': model.skills,
        'day_rate_usd': model.dayRateUsd,
        'links': model.links,
        'media': model.media,
        'credits': model.credits.map((c) => c.toJson()).toList(),
        'created_at': model.createdAt.toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id');
    } catch (e) {
      debugPrint('PortfolioService._upsertRemote failed: $e');
      rethrow;
    }
  }
}
