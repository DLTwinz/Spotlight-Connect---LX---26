import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/nav.dart';
import 'package:spotlight_connect/widgets/app_back_button.dart';

/// Single, consistent screen for any blocked/pending access state.
///
/// This page is used when:
/// - a user attempts to access a protected route without approval
/// - role state is pending/unresolved
/// - profile invariants are missing (malformed users row)
class PermissionDeniedPage extends StatelessWidget {
  const PermissionDeniedPage({super.key, required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final auth = context.watch<AppAuthProvider>();
    final missing = (uri.queryParameters['missing'] ?? 'role').toLowerCase();
    final requiredRole = (uri.queryParameters['role'] ?? '').toLowerCase().trim();
    final from = uri.queryParameters['from'] ?? '/';
    final me = auth.currentUser;

    final title = switch (missing) {
      'approval' => 'Approval required',
      'role' => 'Permission denied',
      'profile' => 'Account setup incomplete',
      _ => 'Access blocked',
    };

    final subtitle = switch (missing) {
      'approval' => requiredRole.isEmpty
          ? 'This area requires approval before you can enter.'
          : 'Your account is not approved for the “$requiredRole” role yet.',
      'role' => requiredRole.isEmpty
          ? 'You don’t have permission to access this area.'
          : 'This area is restricted to approved “$requiredRole” accounts.',
      'profile' => 'We couldn’t confirm your role state yet. This is usually a missing or incomplete users profile row.',
      _ => 'We couldn’t confirm access for this area yet.',
    };

    final nextSteps = <_NextStepItem>[
      if (missing == 'approval')
        const _NextStepItem(
          icon: Icons.schedule,
          title: 'Wait for approval',
          body: 'Your application may be pending review. You can still use Audience features while you wait.',
        ),
      const _NextStepItem(
        icon: Icons.refresh,
        title: 'Refresh role state',
        body: 'If you were just approved, refresh to re-check your permissions.',
      ),
      const _NextStepItem(
        icon: Icons.support_agent,
        title: 'Contact support',
        body: 'If this seems wrong, contact support with your account email and the blocked area.',
      ),
    ];

    Future<void> signOut() async {
      try {
        await auth.logout();
      } catch (e) {
        debugPrint('PermissionDeniedPage: logout failed: $e');
      } finally {
        if (context.mounted) context.go(AppRoutes.login);
      }
    }

    Future<void> refresh() async {
      await auth.refreshCurrentUser();
      if (!context.mounted) return;
      // Re-evaluate routing through the existing redirect logic.
      final target = from.trim().isEmpty ? '/' : from;
      context.go(target);
    }

    final cardBorder = BorderSide(color: cs.outlineVariant.withValues(alpha: 0.55));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: signOut,
            icon: Icon(Icons.logout, color: cs.onSurface),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.fromBorderSide(cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: cs.errorContainer,
                          border: Border.all(color: cs.error.withValues(alpha: 0.22)),
                        ),
                        child: Icon(Icons.lock_outline, color: cs.onErrorContainer),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(subtitle, style: theme.textTheme.titleMedium?.copyWith(height: 1.25)),
                            const SizedBox(height: 8),
                            Text(
                              'Blocked area: $from',
                              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                            ),
                            const SizedBox(height: 8),
                            if (me != null)
                              _AccountPill(
                                email: me.email ?? '',
                                userId: me.userId,
                                role: me.activeRole.isEmpty ? 'audience' : me.activeRole,
                                approvedRoles: me.approvedRoles,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.fromBorderSide(cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('What you can do next', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 10),
                      ...nextSteps.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _NextStepTile(item: s),
                          )),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: refresh,
                            icon: Icon(Icons.refresh, color: cs.onPrimary),
                            label: Text('Refresh role state', style: theme.textTheme.labelLarge?.copyWith(color: cs.onPrimary)),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.go('/'),
                            icon: Icon(Icons.home_outlined, color: cs.onSurface),
                            label: Text('Home', style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurface)),
                          ),
                          OutlinedButton.icon(
                            onPressed: signOut,
                            icon: Icon(Icons.logout, color: cs.onSurface),
                            label: Text('Sign out', style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurface)),
                          ),
                          if (kDebugMode && !kReleaseMode)
                            OutlinedButton.icon(
                              onPressed: () => context.go('/__qa'),
                              icon: Icon(Icons.build_outlined, color: cs.onSurface),
                              label: Text('Open QA Harness', style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurface)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Support: support@spotlightconnect.app',
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountPill extends StatelessWidget {
  const _AccountPill({required this.email, required this.userId, required this.role, required this.approvedRoles});

  final String email;
  final String userId;
  final String role;
  final List<String> approvedRoles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = '$email • $role • ${approvedRoles.join(', ')}';

    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: 'email=$email\nuserId=$userId\nrole=$role\napproved=${approvedRoles.join(',')}'));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Copied account details'), behavior: SnackBarBehavior.floating),
          );
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user_outlined, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.copy, size: 16, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _NextStepItem {
  const _NextStepItem({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}

class _NextStepTile extends StatelessWidget {
  const _NextStepTile({required this.item});
  final _NextStepItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: cs.primary.withValues(alpha: 0.10),
            border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
          ),
          child: Icon(item.icon, size: 18, color: cs.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(item.body, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}
