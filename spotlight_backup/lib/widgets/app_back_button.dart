import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotlight_connect/backend/backend_mode.dart';
import 'package:spotlight_connect/nav.dart';

/// A go_router-safe back button that never strands the user.
///
/// Behavior:
/// - If the router can pop, it pops.
/// - Otherwise it navigates to a safe fallback entry route.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.enabled = true, this.fallbackLocation});

  final bool enabled;

  /// Optional override. If null, defaults to the current entry surface:
  /// - prelaunch: [AppRoutes.earlyAccess]
  /// - launch: [AppRoutes.login]
  final String? fallbackLocation;

  String _defaultFallback() => BackendConfig.prelaunchGateEnabled ? AppRoutes.earlyAccess : AppRoutes.login;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      tooltip: 'Back',
      onPressed: !enabled
          ? null
          : () {
              try {
                final router = GoRouter.of(context);
                if (router.canPop()) {
                  context.pop();
                  return;
                }
              } catch (_) {
                // If go_router isn't available for any reason, fall back to safe navigation.
              }
              context.go(fallbackLocation ?? _defaultFallback());
            },
      icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
    );
  }
}
