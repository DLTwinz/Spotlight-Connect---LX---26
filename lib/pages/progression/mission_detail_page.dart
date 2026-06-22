import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/services/progression_service.dart';
import 'package:spotlight_connect/models/mission_list_item_model.dart';
import 'package:spotlight_connect/models/mission_model.dart';

class MissionDetailPage extends StatefulWidget {
  final String missionId;
  const MissionDetailPage({super.key, required this.missionId});

  @override
  State<MissionDetailPage> createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends State<MissionDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mission Detail')),
      body: Consumer<ProgressionService>(
        builder: (context, svc, _) {
          final item = svc.missions.firstWhere(
            (e) => e.mission.id == widget.missionId,
            orElse: () => MissionListItemModel(
              mission: MissionModel(
                id: widget.missionId, 
                title: 'Unknown Mission', 
                description: 'No description available.',
                shortLabel: 'N/A',
                actionType: 'none', 
                targetValue: 0, 
                prestigeReward: 0, 
                status: 'inactive'
              ),
            ),
          );
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Mission: ${item.mission.title}', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                Text('Status: ${item.mission.status}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
