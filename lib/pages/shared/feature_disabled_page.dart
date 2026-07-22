import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/theme.dart';

/// Full-page fallback used when a route is blocked by server-authoritative policy.
///
/// We use a page (not only a bottom sheet) so deep links and web refreshes have a
/// deterministic, accessible destination.
class FeatureDisabledPage extends StatelessWidget {
  const FeatureDisabledPage({super.key, required this.title, required this.message, this.icon = Icons.lock_outline, this.backLabel = 'Back'});

  final String title;
  final String message;
  final IconData icon;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AppAuthProvider>();

    String defaultTarget() {
      if (!auth.isLoggedIn) return '/login';
      final user = auth.currentUser;
      if (user == null) return '/';
      if (user.isAdmin || user.approvedRoles.contains('admin')) return '/admin';
      if (user.activeRole == 'talent' && user.approvedRoles.contains('talent')) return '/talent';
      if (user.activeRole == 'business' && user.approvedRoles.contains('business')) return '/business';
      return '/audience';
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: theme.colorScheme.onSurface),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Text(title, style: theme.textTheme.titleLarge?.bold.withColor(theme.colorScheme.onSurface))),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(message, style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.go(defaultTarget()),
                        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
                        label: Text(backLabel, style: theme.textTheme.labelLarge?.bold.withColor(theme.colorScheme.onPrimary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
