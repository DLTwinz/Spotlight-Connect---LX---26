import 'package:flutter/material.dart';
import 'package:spotlight_connect/theme.dart';
import 'package:spotlight_connect/models/dashboard_tab_spec.dart';
import 'package:spotlight_connect/pages/dashboards/role_dashboard_shell.dart';
import 'package:spotlight_connect/pages/dashboards/tabs/dashboard_tabs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotlight_connect/services/graph_event_service.dart';

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
class _AudienceInsightsTab extends StatefulWidget {
  const _AudienceInsightsTab();
  @override
  State<_AudienceInsightsTab> createState() => _AudienceInsightsTabState();
}

class _AudienceInsightsTabState extends State<_AudienceInsightsTab> {
  num _supportImpact = 0;
  num _topFandom = 0;
  List<Map<String, dynamic>> _edges = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final graph = GraphEventService(Supabase.instance.client);
    try {
      await graph.recomputeSupportImpact();
      final impact = await graph.mySupportImpactScore();
      final fandom = await graph.myTopFandomStrength();
      final profileId = await graph.currentProfileId();
      List<Map<String, dynamic>> edges = [];
      if (profileId != null) {
        final rows = await Supabase.instance.client
            .from('graph_relationships')
            .select(
              'edge_type, strength_score, supporting_event_count, object_profile_id',
            )
            .eq('subject_profile_id', profileId)
            .order('strength_score', ascending: false)
            .limit(10);
        edges = List<Map<String, dynamic>>.from(rows as List);
      }
      if (!mounted) return;
      setState(() {
        _supportImpact = impact;
        _topFandom = fandom;
        _edges = edges;
        _loading = false;
      });
    } catch (e) {
      debugPrint('AudienceInsights graph load failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.roleAccent('audience');
    final primary = context.roleTextPrimary('audience');
    final muted = context.roleTextMuted('audience');
    final subtle = context.roleTextSubtle('audience');
    final panel = context.rolePanelBackground('audience');
    final border = context.rolePanelBorder('audience');
    final hasSignal =
        _supportImpact > 0 || _topFandom > 0 || _edges.isNotEmpty;

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
        if (_loading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (!hasSignal)
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
                Icon(Icons.insights_outlined,
                    color: accent.withValues(alpha: 0.75), size: 36),
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
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: _InsightStatCard(
                  label: 'SUPPORT IMPACT',
                  value: _supportImpact.toStringAsFixed(0),
                  icon: Icons.star_outline,
                  accent: accent,
                  panel: panel,
                  border: border,
                  primary: primary,
                  subtle: subtle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InsightStatCard(
                  label: 'TOP FANDOM',
                  value: _topFandom.toStringAsFixed(0),
                  icon: Icons.favorite_outline,
                  accent: accent,
                  panel: panel,
                  border: border,
                  primary: primary,
                  subtle: subtle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RELATIONSHIPS',
                  style: TextStyle(
                    color: subtle,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                if (_edges.isEmpty)
                  Text('No edges yet', style: TextStyle(color: muted, fontSize: 12))
                else
                  for (final e in _edges) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.hub_outlined, size: 16, color: accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${e['edge_type'] ?? 'edge'} → ${(e['object_profile_id'] ?? '').toString().substring(0, 8)}…',
                              style: TextStyle(color: primary, fontSize: 12),
                            ),
                          ),
                          Text(
                            '${e['strength_score'] ?? 0} (${e['supporting_event_count'] ?? 0})',
                            style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
              ],
            ),
          ),
        ],
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.emoji_events_outlined, color: accent, size: 20),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasSignal
                          ? 'Signal live — keep densifying to unlock recognition tiers.'
                          : 'Access-first recognition — not vanity points',
                      style: TextStyle(color: muted, fontSize: 12),
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

class _InsightStatCard extends StatelessWidget {
  const _InsightStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.panel,
    required this.border,
    required this.primary,
    required this.subtle,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final Color panel;
  final Color border;
  final Color primary;
  final Color subtle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: primary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: subtle,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
