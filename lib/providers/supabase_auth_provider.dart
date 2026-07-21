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
          'id': uid,
          'user_id': uid,
          'email': email ?? '',
          'username': '',
          'onboarding_complete': false,
          'approved_roles': ['audience'],
          'active_role': 'audience',
          'application_status_summary': 'none',
          'is_admin': false,
        });
      } else {
        final hydrated = Map<String, dynamic>.from(response);
        hydrated['email'] = hydrated['email'] ?? email ?? '';
        hydrated['user_id'] = hydrated['user_id'] ?? uid;
        hydrated['approved_roles'] = hydrated['approved_roles'] ?? ['audience'];
        hydrated['active_role'] = hydrated['active_role'] ?? 'audience';
        hydrated['application_status_summary'] =
            hydrated['application_status_summary'] ?? 'none';
        hydrated['is_admin'] = hydrated['is_admin'] ?? false;
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
  Future<void> login(String email, String password, [String? extra]) async {
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
  Future<void> signup(String email, String password, [String? extra]) async {
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
          'email': email,
          'username': '',
          'active_role': 'audience',
          'approved_roles': ['audience'],
          'onboarding_complete': false,
          'application_status_summary': 'none',
          'is_admin': false,
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
  Future<void> completeOnboarding([String? username, String? role]) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('No active session.');
    }

    final selectedRole = (role ?? '').trim();
    final approvedRoles = <String>['audience'];
    var requestedRolePending = false;
    var applicationStatusSummary = 'none';

    if (selectedRole == 'talent' || selectedRole == 'business') {
      requestedRolePending = true;
      applicationStatusSummary = 'pending';
    }

    await Supabase.instance.client.from('profiles').upsert({
      'user_id': session.user.id,
      'email': session.user.email,
      'username': (username ?? '').trim(),
      'active_role': selectedRole.isEmpty ? 'audience' : 'audience',
      'approved_roles': approvedRoles,
      'onboarding_complete': true,
      'requested_role_pending': requestedRolePending,
      'application_status_summary': applicationStatusSummary,
      'is_admin': false,
    }, onConflict: 'user_id');

    if (selectedRole == 'talent' || selectedRole == 'business') {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('user_id', session.user.id)
          .single();

      await Supabase.instance.client.from('user_roles').upsert({
        'profile_id': profile['id'],
        'role': selectedRole,
        'status': 'pending',
      }, onConflict: 'profile_id,role');
    }

    await refreshCurrentUser();
  }

  @override
  Future<void> setActiveRole(String role) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('No active session.');
    }

    final normalized = role.trim().toLowerCase();
    if (normalized.isEmpty) return;

    await Supabase.instance.client
        .from('profiles')
        .update({'active_role': normalized})
        .eq('user_id', session.user.id);

    await refreshCurrentUser();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
