import 'package:spotlight_connect/pages/dashboards/role_dashboard_shell.dart';
import 'package:spotlight_connect/pages/dashboards/tabs/dashboard_tabs.dart';
import 'package:flutter/material.dart';

import 'package:spotlight_connect/pages/dashboards/creator_studio_shell.dart';
import 'package:spotlight_connect/models/dashboard_tab_spec.dart';

class TalentDashboard extends StatelessWidget {
  const TalentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const CreatorStudioShell();
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
          builder: () => const BusinessHomeTab(),
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
