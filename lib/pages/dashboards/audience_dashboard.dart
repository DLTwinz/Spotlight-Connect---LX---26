import 'package:flutter/material.dart';
import 'package:spotlight_connect/models/dashboard_tab_spec.dart';
import 'package:spotlight_connect/pages/dashboards/role_dashboard_shell.dart';
import 'package:spotlight_connect/pages/dashboards/tabs/dashboard_tabs.dart';
import 'package:spotlight_connect/widgets/post_feed_view.dart';
import 'widgets/behavioral_analytics.dart';

/// Audience role entry — same chrome as Talent/Business via [RoleDashboardShell].
/// Tab content preserves existing insights graph + feed.
class AudienceDashboard extends StatelessWidget {
  const AudienceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardShell(
      role: 'audience',
      tabs: [
        DashboardTabSpec(
          label: 'Insights',
          icon: Icons.insights_outlined,
          builder: () => const _AudienceInsightsTab(),
        ),
        DashboardTabSpec(
          label: 'Feed',
          icon: Icons.dynamic_feed_outlined,
          builder: () => const FeedTab(role: 'audience'),
        ),
        DashboardTabSpec(
          label: 'Discover',
          icon: Icons.explore_outlined,
          builder: () => const DiscoverTab(role: 'audience'),
        ),
        DashboardTabSpec(
          label: 'Profile',
          icon: Icons.person_outline,
          builder: () => const ProfileTab(role: 'audience'),
        ),
      ],
    );
  }
}

/// Former standalone Audience body: live performance graph + engagement feed.
class _AudienceInsightsTab extends StatelessWidget {
  const _AudienceInsightsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              'LIVE PERFORMANCE',
              style: TextStyle(
                color: subtle,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              width: constraints.maxWidth,
              child: Card(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: BehavioralGraphCard(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'LATEST ENGAGEMENT',
              style: TextStyle(
                color: subtle,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 400,
              child: PostFeedView(role: 'audience'),
            ),
          ],
        );
      },
    );
  }
}
