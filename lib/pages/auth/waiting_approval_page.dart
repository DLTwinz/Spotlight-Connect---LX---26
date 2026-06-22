import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/nav.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';

class WaitingApprovalPage extends StatelessWidget {
  const WaitingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final user = auth.currentUser;
    final requested = (user?.activeRole ?? '').trim().isEmpty ? null : user!.activeRole;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Under review', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  Text(
                    requested == null
                        ? 'Your account is being reviewed. You’ll get access as soon as you’re approved.'
                        : 'Your $requested access request is being reviewed. You’ll get access as soon as you’re approved.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.hourglass_top, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This usually takes a short time. You can close the app and come back later.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                await auth.refreshCurrentUser();
                              },
                        icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onPrimary),
                        label: Text('Refresh', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go(AppRoutes.audience),
                        icon: Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
                        label: Text('Back to Audience', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      ),
                      TextButton.icon(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                await auth.logout();
                                if (!context.mounted) return;
                                context.go(AppRoutes.login);
                              },
                        icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.tertiary),
                        label: Text('Log out', style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
