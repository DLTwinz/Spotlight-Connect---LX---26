import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:spotlight_connect/models/mission_model.dart';
import 'package:spotlight_connect/services/progression_service.dart';
import 'package:spotlight_connect/theme.dart';

class MissionDetailPage extends StatefulWidget {
  const MissionDetailPage({super.key, required this.missionId});

  final String missionId;

  @override
  State<MissionDetailPage> createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends State<MissionDetailPage> {
  late Future<MissionModel?> _missionFuture;

  @override
  void initState() {
    super.initState();
    _missionFuture = context.read<ProgressionService>().loadMissionById(
      widget.missionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mission')),
      body: SafeArea(
        child: FutureBuilder<MissionModel?>(
          future: _missionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return ListView(
                padding: AppSpacing.paddingLg,
                children: const [
                  SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(),
                ],
              );
            }

            if (snapshot.hasError) {
              return ListView(
                padding: AppSpacing.paddingLg,
                children: [
                  Text(
                    'Unable to load mission',
                    style: theme.textTheme.titleMedium?.bold,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${snapshot.error}',
                    style: theme.textTheme.bodyMedium?.withColor(
                      theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }

            final mission = snapshot.data;
            if (mission == null) {
              return Center(
                child: Text(
                  'Mission not found.',
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            return ListView(
              padding: AppSpacing.paddingLg,
              children: [
                Text(mission.title, style: theme.textTheme.headlineSmall?.bold),
                if (mission.description.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    mission.description,
                    style: theme.textTheme.bodyLarge?.withColor(
                      theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                _MissionInfoCard(
                  title: 'Short label',
                  value: mission.shortLabel.trim().isEmpty
                      ? 'Not provided'
                      : mission.shortLabel,
                ),
                const SizedBox(height: AppSpacing.md),
                _MissionInfoCard(
                  title: 'Action type',
                  value: mission.actionType,
                ),
                const SizedBox(height: AppSpacing.md),
                _MissionInfoCard(
                  title: 'Target value',
                  value: '${mission.targetValue}',
                ),
                const SizedBox(height: AppSpacing.md),
                _MissionInfoCard(
                  title: 'Prestige reward',
                  value: '${mission.prestigeReward} pts',
                ),
                const SizedBox(height: AppSpacing.md),
                _MissionInfoCard(title: 'Status', value: mission.status),
                if ((mission.timeWindow ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _MissionInfoCard(
                    title: 'Time window',
                    value: mission.timeWindow!,
                  ),
                ],
                if ((mission.campaignId ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _MissionInfoCard(
                    title: 'Campaign ID',
                    value: mission.campaignId!,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MissionInfoCard extends StatelessWidget {
  const _MissionInfoCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.withColor(
              theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: theme.textTheme.titleMedium?.bold),
        ],
      ),
    );
  }
}
