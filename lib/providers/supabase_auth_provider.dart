import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'app_auth_provider.dart';

class SupabaseAuthProvider extends AppAuthProvider {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _lastError;
  StreamSubscription<AuthState>? _authSubscription;
  /// Serializes concurrent refreshProfile calls (login + onAuthStateChange).
  int _refreshGen = 0;

  static const _profileColumns =
      'id, user_id, display_name, username, avatar_url, '
      'active_role, approved, approved_roles, onboarding_complete, '
      'application_status_summary, requested_role_pending, '
      'is_admin, admin_role_edit_enabled';

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isLoggedIn => Supabase.instance.client.auth.currentSession != null;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  @override
  bool get launchEnabled => true;

  @override
  bool isEarlyAccessApproved() => true;

  String? get lastError => _lastError;

  SupabaseAuthProvider() {
    _initializeAuthListener();
  }

  @override
  Future<void> ensureInitialized() async {
    await refreshCurrentUser();
  }

  void _initializeAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      final session = data.session;
      if (session == null) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return;
      }
      await refreshProfile(session.user.id, session.user.email);
    });
  }

  String? _pendingRoleValue(String selectedRole) {
    final normalized = selectedRole.trim().toLowerCase();
    if (normalized == 'talent' || normalized == 'business') return normalized;
    return null;
  }

  UserModel _fallbackUser(String uid, String? email) {
    return UserModel.fromJson({
      'user_id': uid,
      'email': email ?? '',
      'display_name': 'User',
      'username': '',
      'onboarding_complete': false,
      'approved_roles': ['audience'],
      'active_role': 'audience',
      'application_status_summary': 'none',
      'requested_role_pending': null,
      'approved': false,
      'is_admin': false,
      'admin_role_edit_enabled': false,
    });
  }

  Future<void> refreshProfile(String uid, String? email) async {
    // IMPORTANT: do not early-return when _isLoading is true.
    // login()/signup() set loading then call refresh — that race left the
    // spinner up for hours with a live session and null currentUser.
    final gen = ++_refreshGen;
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select(_profileColumns)
          .eq('user_id', uid)
          .maybeSingle()
          .timeout(const Duration(seconds: 12));

      if (gen != _refreshGen) return;

      if (response == null) {
        _currentUser = _fallbackUser(uid, email);
      } else {
        final hydrated = Map<String, dynamic>.from(response);
        hydrated['email'] = email ?? '';
        hydrated['user_id'] = hydrated['user_id'] ?? uid;
        hydrated['approved_roles'] = hydrated['approved_roles'] ?? ['audience'];
        hydrated['active_role'] = hydrated['active_role'] ?? 'audience';
        hydrated['application_status_summary'] =
            hydrated['application_status_summary'] ?? 'none';
        hydrated['requested_role_pending'] = hydrated['requested_role_pending'];
        hydrated['approved'] = hydrated['approved'] ?? false;
        hydrated['is_admin'] = hydrated['is_admin'] ?? false;
        hydrated['admin_role_edit_enabled'] =
            hydrated['admin_role_edit_enabled'] ?? false;
        hydrated['onboarding_complete'] =
            hydrated['onboarding_complete'] ?? false;
        _currentUser = UserModel.fromJson(hydrated);
      }
    } catch (e, stackTrace) {
      if (gen != _refreshGen) return;
      _lastError = e.toString();
      debugPrint('SupabaseAuthProvider.refreshProfile error: $e\n$stackTrace');
      // Unblock router: session is live — never leave currentUser null forever.
      _currentUser = _fallbackUser(uid, email);
    } finally {
      if (gen == _refreshGen) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  Future<void> refreshCurrentUser() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return;
    }
    await refreshProfile(session.user.id, session.user.email);
  }

  @override
  Future<void> login(String email, String password, {String? extra}) async {
    _lastError = null;
    _isLoading = true;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Auth listener also refreshes; generation counter dedupes.
      await refreshCurrentUser();
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> signup(String email, String password, {String? extra}) async {
    _lastError = null;
    _isLoading = true;
    notifyListeners();
    try {
      final result = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final uid = result.user?.id;
      if (uid != null) {
        try {
          await Supabase.instance.client.from('profiles').upsert({
            'user_id': uid,
            'display_name': 'User',
            'username': null,
            'active_role': 'audience',
            'approved': false,
            'approved_roles': ['audience'],
            'requested_role_pending': null,
            'onboarding_complete': false,
            'application_status_summary': 'none',
            'is_admin': false,
            'admin_role_edit_enabled': false,
          }, onConflict: 'user_id');
        } catch (e) {
          debugPrint('signup profile upsert: $e');
        }
      }
      await refreshCurrentUser();
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> completeOnboarding([
    String? username,
    String? requestedRole,
  ]) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('No active session.');
    }
    final selectedRole = (requestedRole ?? '').trim().toLowerCase();
    final pendingRole = _pendingRoleValue(selectedRole);
    await Supabase.instance.client.rpc(
      'complete_onboarding',
      params: {
        'p_username': (username ?? '').trim(),
        'p_requested_role': pendingRole,
      },
    );
    await refreshCurrentUser();
  }

  @override
  Future<void> setActiveRole(String role) async {
    throw UnsupportedError(
      'active_role cannot be changed client-side after signup; use approved admin workflow.',
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
