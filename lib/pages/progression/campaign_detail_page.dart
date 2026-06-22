import 'package:spotlight_connect/models/mission_list_item_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/models/campaign_model.dart';
import 'package:spotlight_connect/services/progression_service.dart';
import 'package:spotlight_connect/theme.dart';

class CampaignDetailPage extends StatefulWidget {
  const CampaignDetailPage({super.key, required this.campaignId});

  final String campaignId;

  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  bool _loading = true;
  CampaignModel? _campaign;
  List<MissionListItemModel> _missions = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final svc = context.read<ProgressionService>();
      final c = await svc.loadCampaignById(widget.campaignId);
      final m = await svc.loadCampaignMissions(widget.campaignId);
      if (!mounted) return;
      setState(() {
        _campaign = c;
        _missions = m;
      });
    } catch (e) {
      debugPrint('CampaignDetailPage load failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final svc = context.watch<ProgressionService>();
    final c = _campaign;

    return Scaffold(
      appBar: AppBar(
        title: Text(c?.title ?? 'Campaign'),
        actions: [
          IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : c == null
                ? Center(
                    child: Padding(
                      padding: AppSpacing.paddingLg,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Campaign not found', style: theme.textTheme.titleMedium?.bold),
                          const SizedBox(height: AppSpacing.sm),
                          Text('This campaign may be private or no longer available.', style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.md),
                          FilledButton(onPressed: () => context.pop(), child: const Text('Back')),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await _load();
                      await svc.refreshHome();
                    },
                    child: ListView(
                      padding: AppSpacing.paddingLg,
                      children: [
                        _HeaderCard(campaign: c),
                        const SizedBox(height: AppSpacing.md),
                        _CampaignActions(campaignId: c.id),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(child: Text('Missions', style: theme.textTheme.titleMedium?.bold)),
                            Text('${_missions.length}', style: theme.textTheme.labelLarge?.withColor(theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (_missions.isEmpty)
                          Text('No missions have been attached yet.', style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant))
                        else
                          ..._missions.map((m) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: _CampaignMissionCard(item: m),
                              )),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Rewards', style: theme.textTheme.titleMedium?.bold),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: AppSpacing.paddingLg,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22)),
                          ),
                          child: Text(
                            'Campaign rewards will appear here once the reward catalog is linked. Mission rewards grant Prestige immediately after verification.',
                            style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.campaign});

  final CampaignModel campaign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String windowLabel() {
      final s = campaign.startsAt;
      final e = campaign.endsAt;
      if (s == null && e == null) return 'Dates TBD';
      String fmt(DateTime d) => '${d.month}/${d.day}/${d.year}';
      if (s != null && e != null) return '${fmt(s)} – ${fmt(e)}';
      if (s != null) return 'Starts ${fmt(s)}';
      return 'Ends ${fmt(e!)}';
    }

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.campaign_outlined, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(campaign.title, style: theme.textTheme.titleLarge?.bold),
                    const SizedBox(height: 2),
                    Text(windowLabel(), style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25)),
                ),
                child: Text(campaign.status.toUpperCase(), style: theme.textTheme.labelSmall?.bold),
              ),
            ],
          ),
          if ((campaign.summary ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(campaign.summary!.trim(), style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
          ],
          if ((campaign.primaryAudience ?? '').trim().isNotEmpty || campaign.primaryActions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if ((campaign.primaryAudience ?? '').trim().isNotEmpty) _Pill(text: campaign.primaryAudience!, icon: Icons.groups_outlined),
                for (final a in campaign.primaryActions.take(3)) _Pill(text: a, icon: Icons.task_alt),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CampaignActions extends StatelessWidget {
  const _CampaignActions({required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final svc = context.watch<ProgressionService>();
    CampaignListItemModel? item;
    for (final c in svc.campaigns) {
      if (c.campaign.id == campaignId) {
        item = c;
        break;
      }
    }
    final joined = item?.isJoined ?? false;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: svc.isLoading
                ? null
                : () async {
                    final ok = await svc.joinCampaign(campaignId);
                    if (!context.mounted) return;
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not join campaign.')));
                    }
                  },
            icon: Icon(joined ? Icons.check_circle_outline : Icons.add, color: theme.colorScheme.onPrimary),
            label: Text(joined ? 'Joined' : 'Join campaign', style: theme.textTheme.labelLarge?.bold.withColor(theme.colorScheme.onPrimary)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic, alignment: 0.1),
          icon: Icon(Icons.list_alt, color: theme.colorScheme.onSurface),
          label: Text('View missions', style: theme.textTheme.labelLarge?.bold.withColor(theme.colorScheme.onSurface)),
        ),
      ],
    );
  }
}

class _CampaignMissionCard extends StatelessWidget {
  const _CampaignMissionCard({required this.item});
  final MissionListItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = item.computedStatus;
    Color tint() => switch (status) {
          'completed' => theme.colorScheme.tertiary,
          'claimed' => theme.colorScheme.onSurfaceVariant,
          'in_progress' => theme.colorScheme.secondary,
          'available' => theme.colorScheme.primary,
          _ => theme.colorScheme.onSurfaceVariant,
        };

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () => context.push('/missions/${item.mission.id}'),
      child: Container(
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
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: tint().withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
                  alignment: Alignment.center,
                  child: Icon(Icons.flag_outlined, color: tint()),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.mission.shortLabel, style: theme.textTheme.titleMedium?.bold, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(item.mission.description, style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: tint().withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                  child: Text(status.replaceAll('_', ' ').toUpperCase(), style: theme.textTheme.labelSmall?.bold.withColor(tint())),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: item.progressPct,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(child: Text('${item.progressValue} / ${item.progressTarget}', style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant))),
                Text('+${item.mission.prestigeReward} prestige', style: theme.textTheme.labelSmall?.bold.withColor(theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(text, style: theme.textTheme.labelMedium?.bold.withColor(theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
