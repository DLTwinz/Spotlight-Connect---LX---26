import 'package:flutter/material.dart';

import 'package:spotlight_connect/theme.dart';

/// Shared, launch-quality card shell for MRCP list surfaces.
///
/// Keeps spacing, border, and header layout consistent across Missions/Campaigns.
class ProgressionCardShell extends StatelessWidget {
  const ProgressionCardShell({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.emphasize = false,
    this.footer,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final bool emphasize;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeClr = badgeColor ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: emphasize ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: emphasize ? 0.32 : 0.22)),
      ),
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: iconBackgroundColor, borderRadius: BorderRadius.circular(AppRadius.md)),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.bold, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if ((badgeText ?? '').trim().isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: badgeClr.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                  child: Text(badgeText!.trim(), style: theme.textTheme.labelSmall?.bold.withColor(badgeClr)),
                ),
              ],
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.md),
            footer!,
          ],
        ],
      ),
    );
  }
}
