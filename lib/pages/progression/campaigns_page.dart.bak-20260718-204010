import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/models/campaign_model.dart';
import 'package:spotlight_connect/pages/progression/widgets/progression_states.dart';
import 'package:spotlight_connect/pages/progression/widgets/progression_cards.dart';
import 'package:spotlight_connect/pages/shared/feature_disabled_page.dart';
import 'package:spotlight_connect/providers/progression_feature_policy_provider.dart';
import 'package:spotlight_connect/services/progression_service.dart';
import 'package:spotlight_connect/theme.dart';
import 'package:spotlight_connect/widgets/disabled_feature_sheet.dart';

class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final policy = context.watch<ProgressionFeaturePolicyProvider>().policy;

    if (!policy.progressionEnabled || !policy.campaignsEnabled) {
      return const FeatureDisabledPage(
        title: 'Campaigns are disabled',
        message: 'This feature is currently unavailable. Please check back later.',
        icon: Icons.campaign_outlined,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Campaigns')),
      body: SafeArea(
        child: Consumer<ProgressionService>(
          builder: (context, svc, _) {
            if (!svc.isInitialized) {
              unawaited(svc.ensureInitialized().catchError((e, st) => debugPrint('CampaignsPage ensureInitialized failed: $e\n$st')));
            }
            final items = svc.campaigns;
            if (svc.isLoading && items.isEmpty) {
              return ListView(
                padding: AppSpacing.paddingLg,
                children: const [
                  ProgressionSkeletonCard(height: 28),
                  SizedBox(height: AppSpacing.lg),
                  ProgressionSkeletonCard(),
                  SizedBox(height: AppSpacing.md),
                  ProgressionSkeletonCard(),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: svc.refreshHome,
              child: ListView(
                padding: AppSpacing.paddingLg,
                children: [
                  Text('Campaigns', style: theme.textTheme.headlineSmall?.bold),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Structured initiatives with bundled missions and clear outcomes. Join to start tracking your role and deliverables.',
                    style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (svc.lastError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    ProgressionInlineErrorBanner(message: svc.lastError!, onRetry: () => unawaited(svc.refreshHome())),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (items.isEmpty)
                    const ProgressionEmptyStateCard(
                      title: 'No campaigns live yet',
                      message: 'When a campaign starts, you’ll see it here with mission bundles and rewards.',
                      icon: Icons.campaign_outlined,
                    )
                  else
                    ...items.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: CampaignCard(item: e),
                        )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class CampaignCard extends StatelessWidget {
  const CampaignCard({super.key, required this.item});
  final CampaignListItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final svc = context.read<ProgressionService>();
    final policy = context.watch<ProgressionFeaturePolicyProvider>().policy;

    Future<void> toggle() async {
      if (!policy.allowAnyWrite || policy.killCampaignJoins) {
        await DisabledFeatureSheet.show(
          context,
          title: 'Campaign joins are paused',
          message: 'Joining/leaving campaigns is currently disabled by server policy.',
          icon: Icons.lock_outline,
        );
        return;
      }
      if (item.isJoined) {
        await svc.leaveCampaign(item.campaign.id);
      } else {
        await svc.joinCampaign(item.campaign.id);
      }
    }

    String windowLabel() {
      final s = item.campaign.startsAt;
      final e = item.campaign.endsAt;
      if (s == null && e == null) return '';
      String fmt(DateTime d) => '${d.month}/${d.day}';
      if (s != null && e != null) return '${fmt(s)}–${fmt(e)}';
      if (s != null) return 'Starts ${fmt(s)}';
      return 'Ends ${fmt(e!)}';
    }

    return ProgressionCardShell(
      icon: Icons.campaign_outlined,
      iconColor: theme.colorScheme.primary,
      iconBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      title: item.campaign.title,
      subtitle: '${item.campaign.status.toUpperCase()}${windowLabel().isEmpty ? '' : ' • ${windowLabel()}'}',
      badgeText: item.isJoined ? 'JOINED' : null,
      badgeColor: item.isJoined ? theme.colorScheme.secondary : null,
      footer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((item.campaign.summary ?? '').trim().isNotEmpty || (item.campaign.description ?? '').trim().isNotEmpty) ...[
              Text(
                (item.campaign.summary ?? item.campaign.description ?? '').trim(),
                style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: toggle,
                    icon: Icon(item.isJoined ? Icons.check_circle_outline : Icons.add, color: theme.colorScheme.onSurface),
                    label: Text(item.isJoined ? 'Joined' : 'Join campaign', style: theme.textTheme.labelLarge?.bold.withColor(theme.colorScheme.onSurface)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.tonal(
                  onPressed: () => context.push('/campaigns/${item.campaign.id}'),
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
