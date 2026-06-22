import 'package:flutter/material.dart';

class AppAuthProvider extends ChangeNotifier {
  bool get isLoading => false;
  bool get isLoggedIn => false;
  dynamic get currentUser => null;
  bool get isAdmin => false;

  Future<void> ensureInitialized() async {}
  Future<void> login(String email, String password, [String? extra]) async {}
  Future<void> signup(String email, String password, [String? extra]) async {}
  Future<void> logout() async {}
  Future<void> sendPasswordResetEmail(String email) async {}
  Future<void> refreshCurrentUser() async {}
  Future<void> completeOnboarding([String? a, String? b]) async {}
  Future<void> setActiveRole(String role) async {}
  bool get launchEnabled => true;
  bool isEarlyAccessApproved() => true;
}
