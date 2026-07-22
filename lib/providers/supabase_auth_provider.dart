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

  void _initializeAuthListener() {
    debugPrint('🚨 AUTH: Initializing onAuthStateChange listener...');
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final event = data.event;
      debugPrint('🚨 AUTH EVENT TRIGGERED: $event');

      if (session == null) {
        debugPrint('🚨 AUTH: No session found.');
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint(
        '🚨 AUTH: Session captured for UID: ${session.user.id}. Hydrating...',
      );
      await refreshProfile(session.user.id, session.user.email);
    });
  }

  Future<void> refreshProfile(String uid, String? email) async {
    if (_isLoading) return;
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      debugPrint('🚨 DB REQUEST: Fetching profile row for UID: $uid');
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .or('id.eq.$uid,user_id.eq.$uid')
          .maybeSingle();

      debugPrint('🚨 DB RESPONSE: Payload received: $response');

      if (response == null) {
        _currentUser = UserModel.fromJson({
          'id': uid,
          'email': email,
          'display_name': '',
          'username': '',
          'onboarding_complete': false,
          'approved_roles': ['audience'],
          'active_role': 'audience',
          'application_status_summary': 'none',
          'is_admin': false,
          'admin_role_edit_enabled': false,
        });
      } else {
        _currentUser = UserModel.fromJson({
          ...response,
          'email': email ?? response['email'],
        });
      }
    } catch (e, stackTrace) {
      _lastError = e.toString();
      debugPrint('🚨 PARSER CRASH: $e\n$stackTrace');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> ensureInitialized() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && _currentUser == null && !_isLoading) {
      await refreshProfile(session.user.id, session.user.email);
    }
  }

  @override
  Future<void> login(String email, String password, {String? extra}) async {
    try {
      _isLoading = true;
      _lastError = null;
      notifyListeners();
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<void> signup(String email, String password, {String? extra}) async {
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Future<void> refreshCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await refreshProfile(user.id, user.email);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> completeOnboarding(
    String? username,
    String? requestedRole,
  ) async {}

  @override
  Future<void> setActiveRole(String role) async {
    if (!isAdmin) {
      debugPrint(
        '🚨 SECURITY VIOLATION: Unauthorized role switch attempt to [$role] was rejected.',
      );
      throw Exception(
        'UNAUTHORIZED: Profile mutation and role switching is strictly locked for standard accounts.',
      );
    }

    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null || _currentUser == null) return;

    try {
      _isLoading = true;
      _lastError = null;
      notifyListeners();

      debugPrint(
        '🚨 DB REQUEST: Admin authorized. Shifting runtime perspective to [$role] for UID: $uid',
      );

      await Supabase.instance.client
          .from('profiles')
          .update({'active_role': role})
          .or('id.eq.$uid,user_id.eq.$uid');

      await refreshProfile(uid, Supabase.instance.client.auth.currentUser?.email);
    } catch (e) {
      _lastError = e.toString();
      debugPrint('🚨 ROLE MUTATION PROTOCOL FAILURE: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
