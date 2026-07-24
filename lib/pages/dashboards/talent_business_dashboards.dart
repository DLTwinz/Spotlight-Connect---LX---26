import 'package:spotlight_connect/pages/dashboards/role_dashboard_shell.dart';
import 'package:spotlight_connect/pages/dashboards/tabs/dashboard_tabs.dart';
import 'package:flutter/material.dart';

import 'package:spotlight_connect/pages/studio/multi_stream_controller.dart';
import 'package:spotlight_connect/models/dashboard_tab_spec.dart';

class TalentDashboard extends StatelessWidget {
  const TalentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardShell(
      role: 'talent',
      tabs: [
        DashboardTabSpec(
          label: 'Dashboard',
          icon: Icons.auto_awesome,
          builder: () => FeedTab(role: 'talent'),
        ),
        DashboardTabSpec(
          label: 'Reels',
          icon: Icons.smart_display_outlined,
          builder: () => ReelsTab(),
        ),
        DashboardTabSpec(
          label: 'Discover',
          icon: Icons.explore_outlined,
          builder: () => DiscoverTab(role: 'talent'),
        ),
        DashboardTabSpec(
          label: 'Studio',
          icon: Icons.live_tv,
          builder: () => StudioTab(role: 'talent'),
        ),
        DashboardTabSpec(
          label: 'Broadcast',
          icon: Icons.broadcast_on_personal_outlined,
          builder: () => const MultiStreamController(),
        ),
        DashboardTabSpec(
          label: 'Opportunities',
          icon: Icons.work_outline,
          builder: () => OpportunitiesTab(role: 'talent'),
        ),
        DashboardTabSpec(
          label: 'Profile',
          icon: Icons.person_outline,
          builder: () => ProfileTab(role: 'talent'),
        ),
      ],
    );
  }
}

class BusinessDashboard extends StatelessWidget {
  const BusinessDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardShell(
      role: 'business',
      tabs: [
        DashboardTabSpec(
          label: 'Dashboard',
          icon: Icons.auto_awesome,
          builder: () => FeedTab(role: 'business'),
        ),
        DashboardTabSpec(
          label: 'Reels',
          icon: Icons.smart_display_outlined,
          builder: () => ReelsTab(),
        ),
        DashboardTabSpec(
          label: 'Discover',
          icon: Icons.explore_outlined,
          builder: () => DiscoverTab(role: 'business'),
        ),
        DashboardTabSpec(
          label: 'Suite',
          icon: Icons.dashboard_customize_outlined,
          builder: () => StudioTab(role: 'business'),
        ),
        DashboardTabSpec(
          label: 'Campaigns',
          icon: Icons.campaign_outlined,
          builder: () => OpportunitiesTab(role: 'business'),
        ),
        DashboardTabSpec(
          label: 'Profile',
          icon: Icons.person_outline,
          builder: () => ProfileTab(role: 'business'),
        ),
      ],
    );
  }
}
