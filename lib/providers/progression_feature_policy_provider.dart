import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:spotlight_connect/models/progression_feature_policy_model.dart';
import 'package:spotlight_connect/models/user_model.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/supabase/supabase_config.dart';

/// Loads and exposes the server-authoritative progression feature policy
/// (toggles + kill switches).
///
/// This provider is designed to be safe-by-default:
/// - If the policy cannot be loaded, it falls back to a conservative policy
///   where progression reads can render but all writes are blocked.
class ProgressionFeaturePolicyProvider extends ChangeNotifier {
  ProgressionFeaturePolicyProvider({required AppAuthProvider authProvider})
    : _auth = authProvider {
    _authListener = () {
      final uid = _auth.currentUser?.userId;
      final roleKey = _roleKeyFromUser(_auth.currentUser);
      if (uid != _lastUserId || roleKey != _lastRoleKey) {
        _lastUserId = uid;
        _lastRoleKey = roleKey;
        unawaited(refresh());
      }
    };
    _auth.addListener(_authListener!);
    // Initial load.
    unawaited(refresh());
  }

  final AppAuthProvider _auth;
  VoidCallback? _authListener;

  bool _isLoading = false;
  String? _lastError;
  ProgressionFeaturePolicy _policy = ProgressionFeaturePolicy.safeFallback(
    source: 'startup',
  );

  String? _lastUserId;
  String _lastRoleKey = 'unknown';

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  ProgressionFeaturePolicy get policy => _policy;

  /// Convenience: current user role key expected by backend policy.
  String get roleKey => _roleKeyFromUser(_auth.currentUser);

  @override
  void dispose() {
    if (_authListener != null) _auth.removeListener(_authListener!);
    super.dispose();
  }

  static String _roleKeyFromUser(UserModel? user) {
    final role = user?.parsedActiveRole ?? UserRole.unknown;
    switch (role) {
      case UserRole.audience:
        return 'audience';
      case UserRole.talent:
        return 'talent';
      case UserRole.business:
        return 'business';
      case UserRole.admin:
        // Admins may need to preview other roles, but their own policy should
        // allow admin tools.
        return 'admin';
      case UserRole.unknown:
        return 'unknown';
    }
  }

  Future<void> refresh() async {
    // If logged out, keep a safe fallback policy.
    if (!_auth.isLoggedIn) {
      _policy = ProgressionFeaturePolicy.safeFallback(source: 'logged_out');
      _lastError = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      // RPC-first, then fallback to direct-table reads.
      final payload = await SupabaseConfig.fetchProgressionFeaturePolicy(
        roleKey: roleKey,
      );
      _policy = ProgressionFeaturePolicy.fromRpc(payload);
      _lastError = null;
    } catch (e, st) {
      debugPrint('ProgressionFeaturePolicyProvider.refresh failed: $e');
      debugPrint('$st');
      _lastError = e.toString();
      _policy = ProgressionFeaturePolicy.safeFallback(
        source: 'fallback_provider_error',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
