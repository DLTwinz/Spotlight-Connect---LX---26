import 'package:flutter/material.dart';
import 'package:spotlight_connect/models/progression_models.dart';

class MissionDetailPage extends StatelessWidget {
  const MissionDetailPage({
    super.key,
        required this.missionId,
  });

  final Map<String, dynamic>? missions;
  final String missionId;

  @override
  Widget build(BuildContext context) {
    // FIX: missions is a Map — use [] not firstWhere
    final raw = missions?[missionId];
    if (raw == null) {
      return const Scaffold(
        body: Center(child: Text('Mission not found.')),
      );
    }
    final mission = raw as Map<String, dynamic>;

    // FIX: removed duplicate named args — keep only one of each
    final model = SpotlightMission(
      id: mission['id'] as String? ?? missionId,
      title: mission['title'] as String? ?? 'Untitled Mission',
      targetValue: (mission['target_value'] ?? mission['target'] ?? 0) as int,
      prestigeReward:
          (mission['prestige_reward'] ?? mission['prestige'] ?? 0) as int,
      status: MissionStatus.values.byName(
        mission['status'] as String? ?? 'active',
      ),
    );

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(model.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Target', style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text('${model.targetValue}', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text('Prestige Reward', style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text('${model.prestigeReward} pts', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text('Status', style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(model.status.name, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
