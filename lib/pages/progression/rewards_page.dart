import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/pages/shared/feature_disabled_page.dart';
import 'package:spotlight_connect/pages/progression/widgets/progression_states.dart';
import 'package:spotlight_connect/providers/progression_feature_policy_provider.dart';
import 'package:spotlight_connect/services/progression_service.dart';
import 'package:spotlight_connect/theme.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final policy = context.watch<ProgressionFeaturePolicyProvider>().policy;
    if (!policy.progressionEnabled || !policy.redemptionsEnabled) {
      return const FeatureDisabledPage(
        title: 'Rewards are disabled',
        message: 'Rewards and redemptions are currently unavailable. Please check back later.',
        icon: Icons.redeem_outlined,
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards')),
      body: SafeArea(
        child: Consumer<ProgressionService>(
          builder: (context, svc, _) {
            if (!svc.isInitialized) {
              unawaited(svc.ensureInitialized().catchError((e, st) => debugPrint('RewardsPage ensureInitialized failed: $e\n$st')));
            }
            final prog = svc.progression;
            if (svc.isLoading && prog == null) {
              return ListView(
                padding: AppSpacing.paddingLg,
                children: const [
                  ProgressionSkeletonCard(height: 28),
                  SizedBox(height: AppSpacing.lg),
                  ProgressionSkeletonCard(height: 140),
                  SizedBox(height: AppSpacing.lg),
                  ProgressionSkeletonCard(height: 120),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: svc.refreshHome,
              child: ListView(
                padding: AppSpacing.paddingLg,
                children: [
                  Text('Your balance', style: theme.textTheme.titleMedium?.bold),
                  const SizedBox(height: AppSpacing.sm),
                  _BalanceCard(
                    prestige: prog?.prestigeTotal ?? 0,
                    momentum: prog?.momentumScore ?? 0,
                    tier: prog?.currentTier ?? 'Starter',
                    nextTierPrestigeRequired: prog?.nextTierPrestigeRequired,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Recognition', style: theme.textTheme.titleMedium?.bold),
                  const SizedBox(height: AppSpacing.sm),
                  _ProofCardsRow(
                    tier: prog?.currentTier ?? 'Starter',
                    prestige: prog?.prestigeTotal ?? 0,
                    missionsCompleted: prog?.missionsCompleted ?? 0,
                    campaignsParticipated: prog?.campaignsParticipated ?? 0,
                    badgesEarned: svc.badges.length,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BadgesPanel(badges: svc.badges),
                  const SizedBox(height: AppSpacing.md),
                  _ProofHistoryPanel(events: svc.proofEvents),
                  if (svc.lastError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    ProgressionInlineErrorBanner(message: svc.lastError!, onRetry: () => unawaited(svc.refreshHome())),
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.prestige, required this.momentum, required this.tier, required this.nextTierPrestigeRequired});

  final int prestige;
  final int momentum;
  final String tier;
  final int? nextTierPrestigeRequired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextReq = nextTierPrestigeRequired;
    final pct = (nextReq == null || nextReq <= 0) ? 0.0 : (prestige / nextReq).clamp(0, 1).toDouble();

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
                alignment: Alignment.center,
                child: Icon(Icons.workspace_premium_outlined, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text('Tier: $tier', style: theme.textTheme.titleMedium?.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _Metric(label: 'Prestige', value: prestige.toString(), icon: Icons.workspace_premium_outlined)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _Metric(label: 'Momentum', value: momentum.toString(), icon: Icons.auto_graph)),
            ],
          ),
          if (nextReq != null && nextReq > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Next tier requirement', style: theme.textTheme.labelLarge?.bold),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('$prestige / $nextReq Prestige', style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall?.withColor(theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.titleMedium?.bold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgesPanel extends StatelessWidget {
  const _BadgesPanel({required this.badges});
  final List<UserBadgeView> badges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (badges.isEmpty) {
      return Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_outlined, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'No badges yet. Complete missions and participate in campaigns to earn recognizable proof.',
                style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Badges', style: theme.textTheme.titleSmall?.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final b in badges.take(18))
                _BadgeChip(name: b.name, badgeType: b.badgeType, description: b.description),
            ],
          ),
          if (badges.length > 18) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '+${badges.length - 18} more',
              style: theme.textTheme.labelMedium?.withColor(theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.name, required this.badgeType, required this.description});

  final String name;
  final String badgeType;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              name,
              style: theme.textTheme.labelLarge?.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (badgeType.trim().isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              badgeType,
              style: theme.textTheme.labelSmall?.withColor(theme.colorScheme.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProofHistoryPanel extends StatelessWidget {
  const _ProofHistoryPanel({required this.events});
  final List<ProofEventView> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Proof history', style: theme.textTheme.titleSmall?.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (events.isEmpty)
            Text(
              'Your completed missions and campaign participation will show up here as verifiable proof.',
              style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
            )
          else
            Column(
              children: [
                for (final e in events.take(12)) ...[
                  _ProofHistoryRow(event: e),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ProofHistoryRow extends StatelessWidget {
  const _ProofHistoryRow({required this.event});
  final ProofEventView event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (event.kind) {
      ProofEventKind.mission => Icons.task_alt,
      ProofEventKind.campaign => Icons.campaign_outlined,
    };
    final tint = switch (event.kind) {
      ProofEventKind.mission => theme.colorScheme.primary,
      ProofEventKind.campaign => theme.colorScheme.secondary,
    };

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: tint.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
            alignment: Alignment.center,
            child: Icon(icon, color: tint),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: theme.textTheme.labelLarge?.bold, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(event.subtitle, style: theme.textTheme.labelMedium?.withColor(theme.colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            _formatShortDate(event.at),
            style: theme.textTheme.labelSmall?.withColor(theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  static String _formatShortDate(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '$mm/$dd';
  }
}

class _ProofCardsRow extends StatelessWidget {
  const _ProofCardsRow({
    required this.tier,
    required this.prestige,
    required this.missionsCompleted,
    required this.campaignsParticipated,
    required this.badgesEarned,
  });

  final String tier;
  final int prestige;
  final int missionsCompleted;
  final int campaignsParticipated;
  final int badgesEarned;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ProofCard(label: 'Tier', value: tier, icon: Icons.workspace_premium_outlined),
          const SizedBox(width: AppSpacing.md),
          _ProofCard(label: 'Badges', value: badgesEarned.toString(), icon: Icons.verified),
          const SizedBox(width: AppSpacing.md),
          _ProofCard(label: 'Prestige', value: prestige.toString(), icon: Icons.auto_graph),
          const SizedBox(width: AppSpacing.md),
          _ProofCard(label: 'Missions', value: missionsCompleted.toString(), icon: Icons.task_alt),
          const SizedBox(width: AppSpacing.md),
          _ProofCard(label: 'Campaigns', value: campaignsParticipated.toString(), icon: Icons.campaign_outlined),
        ],
      ),
    );
  }
}

class _ProofCard extends StatelessWidget {
  const _ProofCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 148,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleMedium?.bold, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.labelSmall?.withColor(theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
