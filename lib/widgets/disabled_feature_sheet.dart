import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotlight_connect/theme.dart';
import 'package:spotlight_connect/widgets/feature_flags_sheet.dart';
import 'package:spotlight_connect/widgets/viewport_constrained_sheet.dart';

/// A launch-safe, user-facing sheet shown when a feature is unavailable.
///
/// In debug builds, this can optionally offer an "Open Features" shortcut
/// (FeatureFlagsSheet) to help QA toggle flags.
class DisabledFeatureSheet extends StatelessWidget {
  const DisabledFeatureSheet({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lock_outline,
    this.primaryLabel = 'Got it',
  });

  final String title;
  final String message;
  final IconData icon;
  final String primaryLabel;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.lock_outline,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          DisabledFeatureSheet(title: title, message: message, icon: icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showOpenFeatures = kDebugMode;
    return SafeArea(
      child: ViewportConstrainedSheet(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: theme.colorScheme.onSurface),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.bold.withColor(
                          theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.withColor(
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    if (showOpenFeatures) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            context.pop();
                            await FeatureFlagsSheet.show(context);
                          },
                          icon: Icon(
                            Icons.tune,
                            color: theme.colorScheme.onSurface,
                          ),
                          label: Text(
                            'Open Features',
                            style: theme.textTheme.labelLarge?.bold.withColor(
                              theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          primaryLabel,
                          style: theme.textTheme.labelLarge?.bold.withColor(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
