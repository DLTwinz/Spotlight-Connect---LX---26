import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotrue/gotrue.dart';
import 'package:spotlight_connect/backend/backend_mode.dart';
import 'package:spotlight_connect/nav.dart';
import 'package:spotlight_connect/supabase/supabase_config.dart';
import 'package:spotlight_connect/widgets/app_back_button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.initialEmail, this.initialStep});

  /// Optional email to prefill the reset flow.
  final String? initialEmail;

  /// Optional step override. Supported values: request, verify, set.
  ///
  /// If omitted, the page defaults to:
  /// - `verify` if an email is provided
  /// - otherwise `request`
  final String? initialStep;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  static const int _maxVerifyAttempts = 5;
  static const Duration _verifyLockDuration = Duration(seconds: 60);
  static const Duration _resendCooldown = Duration(seconds: 30);

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isBusy = false;
  String? _error;

  int _verifyAttempts = 0;
  DateTime? _verifyLockedUntil;
  Timer? _verifyLockTimer;

  DateTime? _resendAvailableAt;
  Timer? _resendTimer;

  _ResetStep _step = _ResetStep.request;

  @override
  void initState() {
    super.initState();
    final initialEmail = widget.initialEmail?.trim();
    if (initialEmail != null && initialEmail.isNotEmpty) {
      _emailController.text = initialEmail;
    }

    _step = _deriveInitialStep(email: _emailController.text.trim(), override: widget.initialStep);

    // Supabase recovery/magic links can land on `/reset-password` directly (or be
    // rewritten by some hosts/email clients) while still carrying auth params in
    // the fragment/query.
    //
    // If we don't consume those params, `currentSession` will be null and the
    // user will never reach the "set new password" step.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (BackendConfig.mode != BackendMode.supabase) return;

      try {
        final uri = Uri.base;
        final frag = uri.fragment;
        final qp = uri.queryParameters;
        final hasFragmentTokens = frag.contains('access_token=') || frag.contains('refresh_token=') || frag.contains('type=recovery');
        final hasPkceCode = (qp['code'] ?? '').isNotEmpty;
        final hasRecoveryType = (qp['type'] ?? '').toLowerCase() == 'recovery';
        final hasAuthParams = hasFragmentTokens || hasPkceCode || hasRecoveryType;

        if (hasAuthParams && SupabaseConfig.client.auth.currentSession == null) {
          if (kDebugMode) debugPrint('ResetPasswordPage: detected Supabase email-link params; forwarding to ${AppRoutes.authCallback}');
          final target = Uri(path: AppRoutes.authCallback, queryParameters: qp, fragment: frag).toString();
          context.go(target);
        }
      } catch (e) {
        debugPrint('ResetPasswordPage: failed to inspect Uri.base for email-link params: $e');
      }
    });

    // If a user enters directly via a recovery link, we may start on `set`.
    // That requires an auth session; if we don't have one, fall back to OTP verify.
    if (_step == _ResetStep.set && SupabaseConfig.client.auth.currentSession == null) {
      _step = _emailController.text.trim().isNotEmpty ? _ResetStep.verify : _ResetStep.request;
    }
  }

  @override
  void dispose() {
    _verifyLockTimer?.cancel();
    _resendTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  int get _verifySecondsRemaining {
    final until = _verifyLockedUntil;
    if (until == null) return 0;
    final diff = until.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  bool get _verifyLocked => _verifySecondsRemaining > 0;

  void _startVerifyLock() {
    _verifyLockTimer?.cancel();
    setState(() => _verifyLockedUntil = DateTime.now().add(_verifyLockDuration));
    _verifyLockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_verifySecondsRemaining <= 0) {
        t.cancel();
        setState(() {
          _verifyLockedUntil = null;
          _verifyAttempts = 0;
        });
      } else {
        setState(() {});
      }
    });
  }

  int get _resendSecondsRemaining {
    final until = _resendAvailableAt;
    if (until == null) return 0;
    final diff = until.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  bool get _resendLocked => _resendSecondsRemaining > 0;

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendAvailableAt = DateTime.now().add(_resendCooldown));
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendSecondsRemaining <= 0) {
        t.cancel();
        setState(() => _resendAvailableAt = null);
      } else {
        setState(() {});
      }
    });
  }

  static _ResetStep _deriveInitialStep({required String email, required String? override}) {
    final normalizedOverride = (override ?? '').trim().toLowerCase();
    final fromOverride = switch (normalizedOverride) {
      'request' => _ResetStep.request,
      'verify' => _ResetStep.verify,
      'set' => _ResetStep.set,
      _ => null,
    };
    if (fromOverride != null) return fromOverride;
    return email.isNotEmpty ? _ResetStep.verify : _ResetStep.request;
  }

  String get _normalizedEmail => _emailController.text.trim().toLowerCase();

  void _setStep(_ResetStep next) {
    if (!mounted) return;
    setState(() {
      _error = null;
      _step = next;
    });
  }

  Future<void> _sendOneTimeCode() async {
    final email = _normalizedEmail;
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }

    if (_resendLocked) {
      setState(() => _error = 'Please wait ${_resendSecondsRemaining}s before requesting another code.');
      return;
    }

    setState(() {
      _isBusy = true;
      _error = null;
    });

    try {
      await SupabaseConfig.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('One-time code sent. Check your email, then enter the code to continue.')),
      );
      _startResendCooldown();
      _setStep(_ResetStep.verify);
    } catch (e) {
      debugPrint('ResetPasswordPage send code failed: $e');
      setState(() => _error = 'Could not send the reset code. Please try again.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _verifyOneTimeCode() async {
    if (_verifyLocked) {
      setState(() => _error = 'Too many attempts. Please wait ${_verifySecondsRemaining}s and try again.');
      return;
    }

    final email = _normalizedEmail;
    final code = _codeController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter the email address you requested the reset for.');
      return;
    }
    if (code.length < 6) {
      setState(() => _error = 'Enter the 6-digit code from the email.');
      return;
    }

    setState(() {
      _isBusy = true;
      _error = null;
    });

    try {
      final res = await SupabaseConfig.client.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.recovery,
      );
      final hasSession = res.session != null || SupabaseConfig.client.auth.currentSession != null;
      if (!hasSession) {
        throw StateError('No session after verifyOTP');
      }
      if (mounted) {
        setState(() {
          _verifyAttempts = 0;
          _verifyLockedUntil = null;
        });
      }
      _setStep(_ResetStep.set);
    } catch (e) {
      debugPrint('ResetPasswordPage verify code failed: $e');
      if (!mounted) return;

      final isAuthApi = e is AuthApiException;
      final codeStr = isAuthApi ? (e.code ?? '').toLowerCase().trim() : '';

      // Only count a "wrong code" as an attempt. Network/timeouts/etc should not
      // lock a user out.
      final shouldCountAttempt = isAuthApi && (codeStr == 'otp_expired' || codeStr == 'otp_invalid');
      if (shouldCountAttempt) {
        setState(() => _verifyAttempts = (_verifyAttempts + 1).clamp(0, 999));
      }

      final remaining = (_maxVerifyAttempts - _verifyAttempts).clamp(0, _maxVerifyAttempts);
      if (_verifyAttempts >= _maxVerifyAttempts) {
        _startVerifyLock();
        setState(() => _error = 'Too many incorrect codes. Please wait ${_verifyLockDuration.inSeconds}s and try again.');
        return;
      }

      if (codeStr == 'otp_expired') {
        setState(() => _error = 'That code expired. Tap “Resend code” to request a fresh one. ($remaining attempts left)');
      } else if (codeStr == 'otp_invalid') {
        setState(() => _error = 'Incorrect code. Try again. ($remaining attempts left)');
      } else {
        // Fallback.
        setState(() => _error = 'Could not verify the code. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _submit() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (password.isEmpty || password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isBusy = true;
      _error = null;
    });

    try {
      await SupabaseConfig.client.auth.updateUser(UserAttributes(password: password));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated. Please sign in again.')),
      );
      await SupabaseConfig.client.auth.signOut();
      if (!mounted) return;
      context.go(AppRoutes.login);
    } catch (e) {
      debugPrint('ResetPasswordPage submit failed: $e');
      setState(() => _error = 'Failed to update password. Please try again.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset password'),
        leading: AppBackButton(enabled: !_isBusy),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              child: _ResetStepBody(
                key: ValueKey(_step),
                step: _step,
                isBusy: _isBusy,
                errorText: _error,
                  resendSecondsRemaining: _resendSecondsRemaining,
                  verifySecondsRemaining: _verifySecondsRemaining,
                emailController: _emailController,
                codeController: _codeController,
                passwordController: _passwordController,
                confirmController: _confirmController,
                onSendCode: _sendOneTimeCode,
                onVerifyCode: _verifyOneTimeCode,
                onSubmitNewPassword: _submit,
                onStartOver: _isBusy
                    ? null
                    : () {
                        setState(() {
                          _emailController.clear();
                          _codeController.clear();
                          _passwordController.clear();
                          _confirmController.clear();
                          _error = null;
                          _verifyAttempts = 0;
                          _verifyLockedUntil = null;
                          _resendAvailableAt = null;
                          _step = _ResetStep.request;
                        });
                      },
                onBackToVerify: _isBusy ? null : () => _setStep(_ResetStep.verify),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _ResetStep { request, verify, set }

class _ResetStepBody extends StatelessWidget {
  const _ResetStepBody({
    super.key,
    required this.step,
    required this.isBusy,
    required this.errorText,
    required this.resendSecondsRemaining,
    required this.verifySecondsRemaining,
    required this.emailController,
    required this.codeController,
    required this.passwordController,
    required this.confirmController,
    required this.onSendCode,
    required this.onVerifyCode,
    required this.onSubmitNewPassword,
    required this.onStartOver,
    required this.onBackToVerify,
  });

  final _ResetStep step;
  final bool isBusy;
  final String? errorText;
  final int resendSecondsRemaining;
  final int verifySecondsRemaining;
  final TextEditingController emailController;
  final TextEditingController codeController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final VoidCallback onSendCode;
  final VoidCallback onVerifyCode;
  final VoidCallback onSubmitNewPassword;
  final VoidCallback? onStartOver;
  final VoidCallback? onBackToVerify;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resendLocked = resendSecondsRemaining > 0;
    final verifyLocked = verifySecondsRemaining > 0;
    final title = switch (step) {
      _ResetStep.request => 'Forgot your password?',
      _ResetStep.verify => 'Enter your code',
      _ResetStep.set => 'Choose a new password',
    };
    final subtitle = switch (step) {
      _ResetStep.request => 'We’ll email you a one-time code.',
      _ResetStep.verify => 'Paste the 6-digit one-time code from your email.',
      _ResetStep.set => 'Set a new password for your account.',
    };

    Widget errorBanner() {
      if (errorText == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          errorText!,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
        ),
      );
    }

    Widget busyIndicator() => const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2));

    return Column(
      key: ValueKey(step),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        errorBanner(),
        if (step == _ResetStep.request || step == _ResetStep.verify) ...[
          TextField(
            controller: emailController,
            enabled: !isBusy,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
        ],
        if (step == _ResetStep.request) ...[
          FilledButton(
            onPressed: (isBusy || resendLocked) ? null : onSendCode,
            child: isBusy ? busyIndicator() : const Text('Send one-time code'),
          ),
          if (resendLocked) ...[
            const SizedBox(height: 8),
            Text(
              'You can request another code in $resendSecondsRemaining seconds.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          if (onStartOver != null)
            TextButton(
              onPressed: onStartOver,
              child: const Text('Start over'),
            ),
        ],
        if (step == _ResetStep.verify) ...[
          TextField(
            controller: codeController,
            enabled: !isBusy && !verifyLocked,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'One-time code'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: (isBusy || verifyLocked) ? null : onVerifyCode,
            child: isBusy ? busyIndicator() : const Text('Verify code'),
          ),
          if (verifyLocked) ...[
            const SizedBox(height: 8),
            Text(
              'Too many attempts. Try again in $verifySecondsRemaining seconds.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: (isBusy || resendLocked) ? null : onSendCode,
                child: Text(resendLocked ? 'Resend in ${resendSecondsRemaining}s' : 'Resend code'),
              ),
              if (onStartOver != null)
                TextButton(
                  onPressed: onStartOver,
                  child: const Text('Use a different email'),
                ),
            ],
          ),
        ],
        if (step == _ResetStep.set) ...[
          TextField(
            controller: passwordController,
            enabled: !isBusy,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New password'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmController,
            enabled: !isBusy,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm password'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: isBusy ? null : onSubmitNewPassword,
            child: isBusy ? busyIndicator() : const Text('Update password'),
          ),
          const SizedBox(height: 12),
          if (onBackToVerify != null)
            TextButton(
              onPressed: onBackToVerify,
              child: const Text('Back to code entry'),
            ),
        ],
      ],
    );
  }
}
