import 'package:flutter/material.dart';
import 'package:spotlight_connect/theme.dart';
import 'package:spotlight_connect/models/dashboard_tab_spec.dart';
import 'package:spotlight_connect/pages/dashboards/role_dashboard_shell.dart';
import 'package:spotlight_connect/pages/dashboards/tabs/dashboard_tabs.dart';

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
          label: 'Passes',
          icon: Icons.confirmation_number_outlined,
          builder: () => const GatedPassesTab(role: 'audience'),
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
    final accent = context.roleAccent('audience');
    final primary = context.roleTextPrimary('audience');
    final muted = context.roleTextMuted('audience');
    final subtle = context.roleTextSubtle('audience');
    final panel = context.rolePanelBackground('audience');
    final border = context.rolePanelBorder('audience');

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        Text(
          'YOUR PROGRESSION',
          style: TextStyle(
            color: subtle,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              Icon(Icons.insights_outlined, color: accent.withValues(alpha: 0.75), size: 36),
              const SizedBox(height: 14),
              Text(
                'No fandom signal yet',
                style: TextStyle(
                  color: primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Support creators, claim passes, and join campaigns.\n'
                'Your progression and recognition will show up here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12.5, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'RECOGNITION',
          style: TextStyle(
            color: subtle,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.military_tech_outlined, color: accent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiers & badges unlock with support',
                      style: TextStyle(
                        color: primary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Access-first recognition — not vanity points',
                      style: TextStyle(color: muted, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
