import 'package:flutter/material.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/supabase/supabase_config.dart';

class SupabaseAuthProvider extends AppAuthProvider {
  bool _isLoading = false;
  String? _lastError; 
  dynamic _currentUser;

  @override
  bool get isLoading => _isLoading;
  @override
  dynamic get currentUser => _currentUser;

  @override
  Future<void> login(String email, String password, [String? extra]) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await SupabaseConfig.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Login Error: $_lastError');
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
      await SupabaseConfig.auth.signUp(email: email, password: password);
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> completeOnboarding([String? a, String? b]) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Production onboarding logic goes here
      debugPrint('Onboarding completed for: $a');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
