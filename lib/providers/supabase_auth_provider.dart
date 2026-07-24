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

  String? _mapProfileRoleToLedgerRole(String profileRole) {
    switch (profileRole.trim().toLowerCase()) {
      case 'audience':
        return 'fan';
      case 'talent':
        return 'creator';
      case 'business':
        return 'brand';
      case 'admin':
        return 'admin';
      default:
        return null;
    }
  }

  Future<void> refreshProfile(String uid, String? email) async {
    if (_isLoading) return;
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('user_id', uid)
          .maybeSingle();

      if (response == null) {
        _currentUser = UserModel.fromJson({
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
      _lastError = e.toString();
      debugPrint('SupabaseAuthProvider.refreshProfile error: $e\n$stackTrace');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
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
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
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
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final result = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final uid = result.user?.id;
      if (uid != null) {
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
    final approvedRoles = <String>['audience'];

    await Supabase.instance.client.from('profiles').upsert({
      'user_id': session.user.id,
      'display_name': _currentUser?.displayName.isNotEmpty == true
          ? _currentUser!.displayName
          : 'User',
      'username': (username ?? '').trim().isEmpty
          ? null
          : (username ?? '').trim(),
      'approved': false,
      'approved_roles': approvedRoles,
      'requested_role_pending': pendingRole,
      'onboarding_complete': true,
      'application_status_summary': pendingRole == null
          ? 'approved'
          : 'pending',
      'is_admin': _currentUser?.isAdminFlag ?? false,
      'admin_role_edit_enabled': _currentUser?.adminRoleEditEnabled ?? false,
    }, onConflict: 'user_id');

    final ledgerRole = _mapProfileRoleToLedgerRole(pendingRole ?? 'audience');

    if (ledgerRole != null) {
      await Supabase.instance.client.from('user_roles').upsert({
        'user_id': session.user.id,
        'role_key': ledgerRole,
        'is_active': pendingRole == null,
      }, onConflict: 'user_id,role_key');
    }

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
