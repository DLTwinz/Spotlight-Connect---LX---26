import 'package:flutter/material.dart';
import 'package:spotlight_connect/widgets/post_feed_view.dart';
import 'widgets/behavioral_analytics.dart';

class AudienceDashboard extends StatelessWidget {
  const AudienceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "AUDIENCE INSIGHTS",
          style: TextStyle(letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const Text(
                "LIVE PERFORMANCE",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              // We use LayoutBuilder to get the parent's width,
              // then pass that specific width to the chart container.
              SizedBox(
                height: 250,
                width: constraints.maxWidth,
                child: Card(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BehavioralGraphCard(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "LATEST ENGAGEMENT",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              SizedBox(height: 400, child: PostFeedView(role: 'audience')),
            ],
          );
        },
      ),
    );
  }
}
