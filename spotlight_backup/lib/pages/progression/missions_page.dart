import 'package:spotlight_connect/models/mission_list_item_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/pages/shared/feature_disabled_page.dart';
import 'package:spotlight_connect/pages/progression/widgets/progression_states.dart';
import 'package:spotlight_connect/pages/progression/widgets/progression_cards.dart';
import 'package:spotlight_connect/providers/progression_feature_policy_provider.dart';
import 'package:spotlight_connect/services/progression_service.dart';
import 'package:spotlight_connect/theme.dart';
import 'package:spotlight_connect/widgets/disabled_feature_sheet.dart';

class MissionsPage extends StatelessWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final policyProvider = context.watch<ProgressionFeaturePolicyProvider>();
    final policy = policyProvider.policy;

    if (!policy.progressionEnabled || !policy.missionsEnabled) {
      return const FeatureDisabledPage(
        title: 'Missions are disabled',
        message: 'This feature is currently unavailable. Please check back later.',
        icon: Icons.flag_outlined,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Missions'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Consumer<ProgressionService>(
          builder: (context, svc, _) {
            if (!svc.isInitialized) {
              unawaited(svc.ensureInitialized().catchError((e, st) => debugPrint('MissionsPage ensureInitialized failed: $e\n$st')));
            }
            final items = svc.missions;
            if (svc.isLoading && items.isEmpty) {
              return ListView(
                padding: AppSpacing.paddingLg,
                children: const [
                  ProgressionSkeletonCard(height: 28),
                  SizedBox(height: AppSpacing.lg),
                  ProgressionSkeletonCard(),
                  SizedBox(height: AppSpacing.md),
                  ProgressionSkeletonCard(),
                  SizedBox(height: AppSpacing.md),
                  ProgressionSkeletonCard(),
                ],
              );
            }

            if (svc.lastError != null && items.isEmpty) {
              return _ErrorState(message: svc.lastError!, onRetry: svc.refreshHome);
            }

            final sections = svc.missionSections;
            return RefreshIndicator(
              onRefresh: svc.refreshHome,
              child: ListView(
                padding: AppSpacing.paddingLg,
                children: [
                  Text('Missions', style: theme.textTheme.headlineSmall?.bold),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Focused, career-relevant objectives that build your Prestige and unlock higher tiers.',
                    style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
                  ),
                  if (svc.lastError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    ProgressionInlineErrorBanner(message: svc.lastError!, onRetry: () => unawaited(svc.refreshHome())),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  for (final entry in sections.entries) ...[
                    Row(
                      children: [
                        Expanded(child: Text(entry.key, style: theme.textTheme.titleMedium?.bold)),
                        Text('${entry.value.length}', style: theme.textTheme.labelLarge?.withColor(theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (entry.value.isEmpty)
                      const ProgressionEmptyStateCard(
                        title: 'No missions yet',
                        message: 'Nothing to work on in this section right now. Check back soon or refresh.',
                        icon: Icons.flag_outlined,
                      )
                    else
                      ...entry.value.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: MissionCard(item: e),
                          )),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MissionCard extends StatelessWidget {
  const MissionCard({super.key, required this.item, this.emphasize = false});

  final MissionListItemModel item;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final svc = context.read<ProgressionService>();
    final policy = context.watch<ProgressionFeaturePolicyProvider>().policy;

    final title = item.mission.shortLabel.trim().isEmpty ? item.mission.title : item.mission.shortLabel;
    final subtitle = item.mission.description;
    final status = item.computedStatus;
    final progressTarget = item.progressTarget <= 0 ? 1 : item.progressTarget;
    final pct = (item.progressValue / progressTarget).clamp(0, 1).toDouble();

    Color statusColor() {
      return switch (status) {
        'completed' => theme.colorScheme.tertiary,
        'claimed' => theme.colorScheme.onSurfaceVariant,
        'in_progress' => theme.colorScheme.secondary,
        'available' => theme.colorScheme.primary,
        'locked' => theme.colorScheme.onSurfaceVariant,
        _ => theme.colorScheme.onSurfaceVariant,
      };
    }

    Future<void> onCta() async {
      final writesAllowed = policy.allowAnyWrite;
      if (!writesAllowed) {
        await DisabledFeatureSheet.show(
          context,
          title: 'Actions temporarily unavailable',
          message: 'Progression write actions are currently disabled by server policy.',
          icon: Icons.lock_outline,
        );
        return;
      }

      if (status == 'completed') {
        if (policy.killMissionClaims || !policy.missionClaimsEnabled) {
          await DisabledFeatureSheet.show(
            context,
            title: 'Claiming is disabled',
            message: 'Mission claiming is currently paused. Please try again later.',
            icon: Icons.redeem_outlined,
          );
          return;
        }
        final id = item.userMission?.id;
        if (id != null) await svc.claimMission(id);
        return;
      }
      if (status == 'locked' || status == 'claimed') return;

      // Start mission if needed.
      if (item.userMission == null) await svc.startMission(item.mission.id);

      // Deep-link to the main mission center detail page.
      if (context.mounted) context.push('/missions/${item.mission.id}');
    }

    return ProgressionCardShell(
      icon: Icons.flag_outlined,
      iconColor: statusColor(),
      iconBackgroundColor: statusColor().withValues(alpha: 0.12),
      title: title,
      subtitle: subtitle,
      badgeText: status.toUpperCase(),
      badgeColor: statusColor(),
      emphasize: emphasize,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.progressValue} / ${item.progressTarget} • +${item.mission.prestigeReward} prestige',
                  style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant),
                ),
              ),
              FilledButton(
                onPressed: (status == 'locked' || status == 'claimed') ? null : onCta,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: Text(item.cta),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.sm),
            Text('Could not load missions', style: theme.textTheme.titleMedium?.bold),
            const SizedBox(height: AppSpacing.xs),
            Text(message, style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
