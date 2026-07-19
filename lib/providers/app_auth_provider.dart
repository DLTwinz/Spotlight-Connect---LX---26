import 'package:flutter/material.dart';
import 'package:spotlight_connect/models/user_model.dart';

abstract class AppAuthProvider extends ChangeNotifier {
  bool get isLoading;
  bool get isLoggedIn;
  UserModel? get currentUser;
  bool get isAdmin;

  Future<void> ensureInitialized();
  Future<void> login(String email, String password, [String? extra]);
  Future<void> signup(String email, String password, [String? extra]);
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> refreshCurrentUser();
  Future<void> completeOnboarding([String? a, String? b]);
  Future<void> setActiveRole(String role);
  bool get launchEnabled;
  bool isEarlyAccessApproved();
}
