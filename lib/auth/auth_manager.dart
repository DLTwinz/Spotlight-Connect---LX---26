// Authentication Manager - Base interface for auth implementations
//
// This abstract class and mixins define the contract for authentication systems.
// Implement this with concrete classes for Firebase, Supabase, or local auth.
//
// Usage:
// 1. Create a concrete class extending AuthManager
// 2. Mix in the required authentication provider mixins
// 3. Implement all abstract methods with your auth provider logic

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show User, UserAttributes;
import 'package:spotlight_connect/supabase/supabase_config.dart';

// Core authentication operations that all auth implementations must provide
abstract class AuthManager {
  Future signOut();
  Future deleteUser(BuildContext context);
  Future updateEmail({required String email, required BuildContext context});
  Future resetPassword({required String email, required BuildContext context});

  /// Supabase sends confirmation/verification emails as part of auth flows.
  /// This is intentionally a no-op for Supabase-backed builds.
  Future<void> sendEmailVerification({required User user}) async {}

  Future<void> refreshUser({required User user}) async {}
}

/// Supabase-backed auth manager used by this project.
///
/// Notes:
/// - Supabase Auth handles email verification internally.
/// - We intentionally keep this class focused on auth operations only; loading
///   the app user profile (from `public.users`) should happen elsewhere.
class SupabaseAuthManager extends AuthManager
    with EmailSignInManager, JwtSignInManager {
  @override
  Future<void> signOut() async {
    try {
      await SupabaseConfig.auth.signOut();
    } catch (e, st) {
      debugPrint('SupabaseAuthManager.signOut failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(BuildContext context) async {
    // Deleting auth users requires the service role key and should be done via
    // an Edge Function for security. We explicitly do not attempt it client-side.
    throw UnsupportedError(
      'Deleting a Supabase auth user must be done server-side.',
    );
  }

  @override
  Future<void> updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await SupabaseConfig.auth.updateUser(UserAttributes(email: email));
    } catch (e, st) {
      debugPrint('SupabaseAuthManager.updateEmail failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(
        email,
        redirectTo: '${SupabaseConfig.authRedirectOrigin}/#/reset-password',
      );
    } catch (e, st) {
      debugPrint('SupabaseAuthManager.resetPassword failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<User?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final res = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return res.user;
    } catch (e, st) {
      debugPrint('SupabaseAuthManager.signInWithEmail failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<User?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final res = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: '${SupabaseConfig.authRedirectOrigin}/#/auth/callback',
      );
      return res.user;
    } catch (e, st) {
      debugPrint('SupabaseAuthManager.createAccountWithEmail failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<User?> signInWithJwtToken(
    BuildContext context,
    String jwtToken,
  ) async {
    try {
      final res = await SupabaseConfig.auth.recoverSession(jwtToken);
      return res.user;
    } catch (e, st) {
      debugPrint('SupabaseAuthManager.signInWithJwtToken failed: $e\n$st');
      rethrow;
    }
  }
}

// Email/password authentication mixin
mixin EmailSignInManager on AuthManager {
  Future<User?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  );

  Future<User?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  );
}

// Anonymous authentication for guest users
mixin AnonymousSignInManager on AuthManager {
  Future<User?> signInAnonymously(BuildContext context);
}

// Apple Sign-In authentication (iOS/web)
mixin AppleSignInManager on AuthManager {
  Future<User?> signInWithApple(BuildContext context);
}

// Google Sign-In authentication (all platforms)
mixin GoogleSignInManager on AuthManager {
  Future<User?> signInWithGoogle(BuildContext context);
}

// JWT token authentication for custom backends
mixin JwtSignInManager on AuthManager {
  Future<User?> signInWithJwtToken(BuildContext context, String jwtToken);
}

// Phone number authentication with SMS verification
mixin PhoneSignInManager on AuthManager {
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  });

  Future verifySmsCode({
    required BuildContext context,
    required String smsCode,
  });
}

// Facebook Sign-In authentication
mixin FacebookSignInManager on AuthManager {
  Future<User?> signInWithFacebook(BuildContext context);
}

// Microsoft Sign-In authentication (Azure AD)
mixin MicrosoftSignInManager on AuthManager {
  Future<User?> signInWithMicrosoft(
    BuildContext context,
    List<String> scopes,
    String tenantId,
  );
}

// GitHub Sign-In authentication (OAuth)
mixin GithubSignInManager on AuthManager {
  Future<User?> signInWithGithub(BuildContext context);
}
