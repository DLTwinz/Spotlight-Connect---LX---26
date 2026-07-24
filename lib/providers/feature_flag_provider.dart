import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:spotlight_connect/storage/key_value_store.dart';

/// App feature flags for QA/beta gating.
///
/// Notes:
/// - Backed by [KeyValueStore] so it persists across reloads.
/// - Intended for UI gating and progressive rollout during beta.
/// - Not a security boundary.
enum AppFeature {
  roleBasedAccess,
  messaging,
  opportunities,
  liveRooms,
  studios,
  portfolios,
  monetization,
  notifications,
  clips,
  streams,
  projects,
  analytics,
  verification,
  settings,
  landingMarketing,

  /// Admin-only: shows the early-access status checker UI on the waitlist page.
  earlyAccessStatusChecker,

  /// Allows non-admin QA/dev access to the in-app QA harness route (`/__qa`).
  ///
  /// Note: This is still blocked in release builds (defense-in-depth).
  qaHarness,
}

@immutable
class AppFeatureDescriptor {
  const AppFeatureDescriptor({
    required this.feature,
    required this.title,
    required this.description,
    required this.defaultEnabled,
    this.betaTag,
    this.adminOnlyEdit = false,
  });

  final AppFeature feature;
  final String title;
  final String description;
  final bool defaultEnabled;
  final String? betaTag;

  /// If true, only admins can toggle this flag in the feature flags UI.
  final bool adminOnlyEdit;
}

class FeatureFlagProvider extends ChangeNotifier {
  FeatureFlagProvider({required KeyValueStore store}) : _store = store;

  static const _kFlagsKey = 'spotlight_feature_flags_v1';
  static const _kUnlockedKey = 'spotlight_feature_flags_unlocked_v1';

  final KeyValueStore _store;

  bool _initialized = false;
  bool _isLoading = false;
  String? _lastError;

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get isInitialized => _initialized;

  final Map<AppFeature, bool> _flags = {};
  bool _editingUnlocked = false;

  /// Whether this device/session is allowed to toggle flags.
  ///
  /// Important: we intentionally do NOT auto-unlock in debug builds.
  /// The goal is that the default local state resembles production: features are
  /// either enabled by default, or explicitly unlocked/toggled during QA.
  bool get editingUnlocked => _editingUnlocked;

  static const List<AppFeatureDescriptor> descriptors = [
    AppFeatureDescriptor(
      feature: AppFeature.roleBasedAccess,
      title: 'Role-based access',
      description:
          'Audience / Talent / Business / Admin dashboards with approval gates.',
      defaultEnabled: true,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.messaging,
      title: 'Messaging',
      description: 'Direct threads + basic inbox UI.',
      defaultEnabled: true,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.opportunities,
      title: 'Opportunities & campaigns',
      description:
          'Business opportunities + applications (currently partially local).',
      defaultEnabled: true,
      betaTag: kDebugMode ? 'Beta' : null,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.liveRooms,
      title: 'Live rooms',
      description: 'Scaffolded live room experience (not finalized).',
      defaultEnabled: false,
      betaTag: kDebugMode ? 'Scaffold' : null,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.studios,
      title: 'Studios',
      description: 'Studio sessions & scheduling surfaces.',
      // Launch policy: studio scheduling + external streaming links are part of MVP.
      defaultEnabled: true,
      betaTag: kDebugMode ? 'WIP' : null,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.portfolios,
      title: 'Portfolios',
      description: 'Creator portfolio pages (local-only right now).',
      defaultEnabled: false,
      betaTag: kDebugMode ? 'WIP' : null,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.monetization,
      title: 'Monetization',
      description: 'Plans + subscriptions (local-only right now).',
      defaultEnabled: false,
      betaTag: kDebugMode ? 'WIP' : null,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.notifications,
      title: 'Notifications',
      description: 'In-app activity & system notifications.',
      defaultEnabled: true,
      betaTag: kDebugMode ? 'Beta' : null,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.clips,
      title: 'Clips',
      description:
          'Short-form clips and media uploads (requires moderation + storage).',
      defaultEnabled: false,
      betaTag: kDebugMode ? 'Planned' : null,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.streams,
      title: 'Streams',
      description: 'Live streaming / session hosting tools.',
      // This flag gates optional broadcast modes (e.g., RTMP/LiveKit) but the
      // core Studio UI can still work with external links.
      defaultEnabled: true,
      betaTag: kDebugMode ? 'Planned' : null,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.projects,
      title: 'Projects',
      description: 'Collaboration projects and task tracking.',
      defaultEnabled: false,
      betaTag: kDebugMode ? 'Planned' : null,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.analytics,
      title: 'Analytics',
      description: 'Performance dashboards and insights.',
      defaultEnabled: false,
      betaTag: kDebugMode ? 'Planned' : null,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.verification,
      title: 'Verification',
      description: 'Identity / eligibility verification surfaces (Phase 3).',
      defaultEnabled: false,
      betaTag: kDebugMode ? 'Planned' : null,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.settings,
      title: 'Settings',
      description: 'Preferences, privacy, and account controls.',
      defaultEnabled: false,
      betaTag: kDebugMode ? 'Planned' : null,
    ),
    AppFeatureDescriptor(
      feature: AppFeature.landingMarketing,
      title: 'Landing / marketing pages',
      description: 'Public marketing surfaces and docs hub.',
      defaultEnabled: false,
      betaTag: kDebugMode ? 'Planned' : null,
    ),

    AppFeatureDescriptor(
      feature: AppFeature.earlyAccessStatusChecker,
      title: 'Early access status checker',
      description:
          'Shows the waitlist status lookup UI on the early-access page (admin-only).',
      defaultEnabled: false,
      betaTag: kDebugMode ? 'Internal' : null,
      adminOnlyEdit: true,
    ),

    AppFeatureDescriptor(
      feature: AppFeature.qaHarness,
      title: 'QA Harness route',
      description:
          'Allows opening /__qa without admin role (non-release builds only).',
      defaultEnabled: false,
      betaTag: kDebugMode ? 'Internal' : null,
    ),
  ];

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final raw = await _store.getString(_kFlagsKey);
      final decoded = raw == null || raw.trim().isEmpty
          ? null
          : jsonDecode(raw);
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          final key = entry.key.toString();
          final value = entry.value;
          final parsed = AppFeature.values.where((f) => f.name == key).toList();
          if (parsed.isEmpty) continue;
          if (value is bool) _flags[parsed.first] = value;
          if (value is String)
            _flags[parsed.first] = value.toLowerCase() == 'true';
        }
      }

      // Apply defaults for missing flags.
      for (final d in descriptors) {
        _flags.putIfAbsent(d.feature, () => d.defaultEnabled);
      }

      final unlockedRaw = await _store.getString(_kUnlockedKey);
      _editingUnlocked = unlockedRaw == 'true';

      // Persist sanitized state so future loads are stable.
      await _persist();
      _initialized = true;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('FeatureFlagProvider.ensureInitialized failed: $e');
      // Fall back to defaults (do not persist unlocked state).
      _flags
        ..clear()
        ..addEntries(
          descriptors.map((d) => MapEntry(d.feature, d.defaultEnabled)),
        );
      _initialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isEnabled(AppFeature feature) {
    final d = descriptors.where((x) => x.feature == feature).toList();
    final fallback = d.isEmpty ? true : d.first.defaultEnabled;
    return _flags[feature] ?? fallback;
  }

  Future<void> setEnabled(AppFeature feature, bool enabled) async {
    _flags[feature] = enabled;
    notifyListeners();
    try {
      await _persist();
    } catch (e) {
      debugPrint('FeatureFlagProvider.setEnabled persist failed: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> setAllEnabled(bool enabled) async {
    for (final d in descriptors) {
      _flags[d.feature] = enabled;
    }
    notifyListeners();
    try {
      await _persist();
    } catch (e) {
      debugPrint('FeatureFlagProvider.setAllEnabled persist failed: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> resetToDefaults() async {
    for (final d in descriptors) {
      _flags[d.feature] = d.defaultEnabled;
    }
    notifyListeners();
    try {
      await _persist();
    } catch (e) {
      debugPrint('FeatureFlagProvider.resetToDefaults persist failed: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  Future<bool> unlockEditing(String code) async {
    // Lightweight guard. This is not security-sensitive.
    final normalized = code.trim();
    if (normalized != 'SPOTLIGHT') return false;
    _editingUnlocked = true;
    notifyListeners();
    try {
      await _store.setString(_kUnlockedKey, 'true');
    } catch (e) {
      debugPrint('FeatureFlagProvider.unlockEditing persist failed: $e');
    }
    return true;
  }

  Future<void> lockEditing() async {
    _editingUnlocked = false;
    notifyListeners();
    try {
      await _store.remove(_kUnlockedKey);
    } catch (e) {
      debugPrint('FeatureFlagProvider.lockEditing persist failed: $e');
    }
  }

  Future<void> _persist() async {
    final map = <String, bool>{
      for (final e in _flags.entries) e.key.name: e.value,
    };
    await _store.setString(_kFlagsKey, jsonEncode(map));
  }
}
