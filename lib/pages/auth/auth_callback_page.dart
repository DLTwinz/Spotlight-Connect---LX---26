import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotlight_connect/nav.dart';
import 'package:spotlight_connect/supabase/supabase_config.dart';
import 'package:spotlight_connect/widgets/app_back_button.dart';

/// Universal handler for Supabase email links (confirm signup, magic link, recovery).
///
/// Supabase places tokens in the URL fragment. Some hosts additionally use hash
/// routing, which can produce confusing "double-hash" URLs.
///
/// This page normalizes the URL, consumes the session via
/// `auth.getSessionFromUrl`, then routes the user to the appropriate page.
class AuthCallbackPage extends StatefulWidget {
  const AuthCallbackPage({super.key});

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  bool _busy = true;
  String? _error;
  String? _debugDetails;

  @override
  void initState() {
    super.initState();
    _consume();
  }

  Future<void> _consume() async {
    setState(() {
      _busy = true;
      _error = null;
      _debugDetails = null;
    });

    try {
      final normalized = _normalizeSupabaseEmailLink(Uri.base);

      final supabaseError = _extractSupabaseError(normalized);
      if (supabaseError != null) {
        if (!mounted) return;
        setState(() {
          _error = supabaseError.userFacingMessage;
          if (kDebugMode) _debugDetails = supabaseError.debugDetails;
        });
        return;
      }

      // Supabase currently supports multiple email-link styles:
      // - Implicit flow tokens in fragment: #access_token=...&type=recovery
      // - PKCE flow code in query: ?code=...&type=recovery
      // getSessionFromUrl handles the fragment-token case.
      // For PKCE code links, we must exchange the code explicitly.
      final code = normalized.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        await SupabaseConfig.client.auth.exchangeCodeForSession(code);
      } else {
        await SupabaseConfig.client.auth.getSessionFromUrl(normalized);
      }

      String? type;
      try {
        // Prefer explicit query parameter when present.
        type = normalized.queryParameters['type'];
        if (type == null || type.isEmpty) {
          final frag = normalized.fragment;
          if (frag.isNotEmpty) type = Uri.splitQueryString(frag)['type'];
        }
      } catch (_) {
        type = null;
      }
      if (!mounted) return;

      final typeLower = type?.toLowerCase().trim();

      // Recovery link support:
      // - Some Supabase configs send a link (type=recovery) that establishes a session.
      // - Others send an OTP code.
      // We support BOTH by routing to /reset-password step=set if a session exists;
      // otherwise we route to /reset-password step=verify for OTP entry.
      if (typeLower == 'recovery') {
        final hasSession = SupabaseConfig.client.auth.currentSession != null;
        if (!mounted) return;
        if (hasSession) {
          context.go(Uri(path: AppRoutes.resetPassword, queryParameters: {'step': 'set'}).toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter the one-time code from your email to continue.')),
          );
          context.go(Uri(path: AppRoutes.resetPassword, queryParameters: {'step': 'verify'}).toString());
        }
        return;
      }

      // For signup confirmation / magic links, once the session is established
      // the router redirect guards will place the user correctly.
      context.go(AppRoutes.root);
    } catch (e) {
      debugPrint('AuthCallbackPage: failed to consume email link: $e');
      if (!mounted) return;
      setState(() {
        _error = 'This link is invalid or expired. Please request a new one.';
        if (kDebugMode) _debugDetails = e.toString();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static _SupabaseEmailLinkError? _extractSupabaseError(Uri uri) {
    // Supabase can return errors in fragment or query, e.g.
    //   #error=access_denied&error_code=403&error_description=...
    // Some environments truncate/transform these; we treat any `error=` as fatal.
    String? error;
    String? errorCode;
    String? errorDescription;
    try {
      error = uri.queryParameters['error'];
      errorCode = uri.queryParameters['error_code'];
      errorDescription = uri.queryParameters['error_description'];

      if ((error == null || error.isEmpty) && uri.fragment.isNotEmpty) {
        final frag = uri.fragment;
        final fragParams = Uri.splitQueryString(frag);
        error = fragParams['error'] ?? error;
        errorCode = fragParams['error_code'] ?? errorCode;
        errorDescription = fragParams['error_description'] ?? errorDescription;
      }
    } catch (_) {
      // ignore; fallback below
    }

    // A last-resort parse for unusual fragments like `error=acc`.
    if ((error == null || error.isEmpty) && uri.fragment.startsWith('error=')) {
      error = uri.fragment.substring('error='.length);
    }

    if (error == null || error.isEmpty) return null;

    final normalizedError = error.toLowerCase().trim();
    final userFacing = switch (normalizedError) {
      'access_denied' || 'accessdenied' || 'acc' =>
        'We couldn\'t confirm your email because Supabase rejected the link. Please request a new confirmation email, and if it keeps happening, verify the app redirect URL is allowed in Supabase.',
      'otp_expired' => 'This one-time link has expired. Please request a new one.',
      _ => 'We couldn\'t finish sign-in. Please request a new link and try again.',
    };

    final debugDetails = <String, String?>{
      'error': error,
      'error_code': errorCode,
      'error_description': errorDescription,
      'path': uri.path,
      'query': uri.query,
      'fragment': uri.fragment,
    }.entries.map((e) => '${e.key}=${e.value ?? ''}').join('\n');

    return _SupabaseEmailLinkError(userFacingMessage: userFacing, debugDetails: debugDetails);
  }

  static Uri _normalizeSupabaseEmailLink(Uri uri) {
    // Most Supabase links look like:
    //   https://host/auth/callback#access_token=...&type=recovery
    // If someone uses hash routing, we can see fragments like:
    //   /reset-password#access_token=...
    // If we see a route prefix inside the fragment, strip it.
    final frag = uri.fragment;
    if (!frag.startsWith('/')) return uri;

    final idx = frag.indexOf('#');
    if (idx < 0) {
      // Might be '/reset-password?x=y' without tokens; keep as-is.
      return uri;
    }
    final tokens = frag.substring(idx + 1);
    return uri.replace(fragment: tokens);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finishing sign-in'),
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_busy) ...[
                  const Center(child: SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))),
                  const SizedBox(height: 12),
                  Text('Processing your link…', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                ] else if (_error != null) ...[
                  Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
                  if (kDebugMode && (_debugDetails?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(_debugDetails!, style: theme.textTheme.labelSmall),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _consume,
                    child: const Text('Try again'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Back to sign in'),
                  ),
                ] else ...[
                  Text('Done. Redirecting…', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupabaseEmailLinkError {
  const _SupabaseEmailLinkError({required this.userFacingMessage, required this.debugDetails});
  final String userFacingMessage;
  final String debugDetails;
}
