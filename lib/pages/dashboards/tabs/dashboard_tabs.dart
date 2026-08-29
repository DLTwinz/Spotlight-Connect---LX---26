import 'package:spotlight_connect/pages/dashboards/role_dashboard_shell.dart';
import 'package:flutter/material.dart';
import 'package:spotlight_connect/services/graph_event_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/services/opportunity_service.dart';
import 'package:spotlight_connect/widgets/post_feed_view.dart';
import 'package:spotlight_connect/services/post_service.dart';
import 'package:spotlight_connect/theme.dart';
import 'package:spotlight_connect/services/database_service.dart';
import 'package:spotlight_connect/models/brand_attribution_summary_model.dart';
import 'package:spotlight_connect/models/creator_attribution_summary_model.dart';

// ==========================================
// SHARED UTILITIES & COMPONENTS FOR HUD LABELS
// ==========================================
class _TelemetryCard extends StatelessWidget {
  final String? role;
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color accentColor;

  const _TelemetryCard({
    required this.role,
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.panelBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: context.roleTextSubtle(role),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(icon, color: accentColor, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: context.roleTextPrimary(role),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                trend,
                style: TextStyle(
                  color: trend.contains('+') || trend.contains('SECURE')
                      ? accentColor
                      : context.roleDanger(role),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 1. FEED TAB (ACTIVITY ENGINE & LOGS)
// ==========================================

// ==========================================
// CREATOR HOME — Operations HUD (graph-aware)
// Spec: unique per-role dashboard. Talent must not share FeedTab.
// ==========================================
class CreatorHomeTab extends StatefulWidget {
  const CreatorHomeTab({super.key});

  @override
  State<CreatorHomeTab> createState() => _CreatorHomeTabState();
}

class _CreatorHomeTabState extends State<CreatorHomeTab> {
  static const _role = 'talent';
  bool _claiming = false;
  int _applyCount = 0;
  int _eventCount = 0;
  num _supportBalance = 0;
  num _supportImpact = 0;
  num _fandomStrength = 0;
  bool _graphLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGraphStats();
  }

  Future<void> _loadGraphStats() async {
    final client = Supabase.instance.client;
    final graph = GraphEventService(client);
    try {
      final applies = await graph.countMyEvents(eventType: 'campaign_apply');
      final all = await graph.countMyEvents();
      final balance = await graph.mySupportBalance();
      await graph.recomputeSupportImpact();
      final impact = await graph.mySupportImpactScore();
      final fandom = await graph.myTopFandomStrength();
      if (!mounted) return;
      setState(() {
        _applyCount = applies;
        _eventCount = all;
        _supportBalance = balance;
        _supportImpact = impact;
        _fandomStrength = fandom;
        _graphLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _graphLoading = false);
    }
  }


  void _go(String tabLabel) {
    final nav = RoleShellNav.maybeOf(context);
    if (nav != null) {
      nav.goToLabel(tabLabel);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open $tabLabel from the sidebar')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.roleAccent(_role);
    final oppSvc = context.watch<OpportunityService>();
    final openCount = oppSvc.opportunities.length;
    final loading = oppSvc.isLoading;

    return Scaffold(
      backgroundColor: context.roleShellBackground(_role),
      appBar: AppBar(
        backgroundColor: context.roleShellBackground(_role),
        title: Text(
          'CREATOR OPERATIONS HUD',
          style: TextStyle(
            color: context.roleTextPrimary(_role),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accent, size: 20),
            onPressed: () {
              oppSvc.fetchActiveOpportunities();
              setState(() => _graphLoading = true);
              _loadGraphStats();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: _HudKpi(
                  role: _role,
                  label: 'OPEN OPPORTUNITIES',
                  value: loading ? '—' : '$openCount',
                  icon: Icons.work_outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HudKpi(
                  role: _role,
                  label: 'APPLICATIONS',
                  value: _graphLoading ? '—' : '$_applyCount',
                  icon: Icons.send_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HudKpi(
                  role: _role,
                  label: 'GRAPH EVENTS',
                  value: _graphLoading ? '—' : '$_eventCount',
                  icon: Icons.hub_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HudKpi(
                  role: _role,
                  label: 'SUPPORT',
                  value: _graphLoading
                      ? '—'
                      : _supportBalance.toStringAsFixed(0),
                  icon: Icons.star_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'ACTION QUEUE',
            style: TextStyle(
              color: context.roleTextSubtle(_role),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _go('Opportunities'),
              child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(_role),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.rolePanelBorder(_role)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  color: accent.withValues(alpha: 0.7),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  _applyCount > 0
                      ? 'Applications in flight'
                      : 'No actions right now',
                  style: TextStyle(
                    color: context.roleTextPrimary(_role),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _applyCount > 0
                      ? '$_applyCount apply event${_applyCount == 1 ? '' : 's'} · support impact ${_supportImpact.toStringAsFixed(0)}'
                      : 'Approvals, mission steps, and contract responses will land here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.roleTextMuted(_role),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'OPPORTUNITIES',
            style: TextStyle(
              color: context.roleTextSubtle(_role),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _go('Opportunities'),
              child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(_role),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.rolePanelBorder(_role)),
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
                  child: Icon(Icons.work_outline, color: accent, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        openCount == 0
                            ? 'No open opportunities'
                            : '$openCount open ${openCount == 1 ? 'opportunity' : 'opportunities'}',
                        style: TextStyle(
                          color: context.roleTextPrimary(_role),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Browse full list in the Opportunities tab',
                        style: TextStyle(
                          color: context.roleTextMuted(_role),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'ECONOMICS',
            style: TextStyle(
              color: context.roleTextSubtle(_role),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _go('Studio'),
              child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(_role),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.rolePanelBorder(_role)),
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
                  child: Icon(Icons.insights_outlined, color: accent, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creator Operations Engine',
                        style: TextStyle(
                          color: context.roleTextPrimary(_role),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Earnings, pipeline, and attribution live in Studio',
                        style: TextStyle(
                          color: context.roleTextMuted(_role),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'GATED EXPERIENCE (STUB)',
            style: TextStyle(
              color: context.roleTextSubtle(_role),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(_role),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.rolePanelBorder(_role)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilot fan pass',
                        style: TextStyle(
                          color: context.roleTextPrimary(_role),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _fandomStrength > 0
                            ? 'Top fandom strength ${_fandomStrength.toStringAsFixed(0)} · claim densifies fan_creator'
                            : 'Claim densifies fan_creator edge + fandom strength (+5)',
                        style: TextStyle(
                          color: context.roleTextMuted(_role),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: context.roleOnAccent(_role),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: _claiming
                        ? null
                        : () async {
                            setState(() => _claiming = true);
                            final graph =
                                GraphEventService(Supabase.instance.client);
                            final id = await graph.claimGatedPass(
                              passId:
                                  '481eccb2-8c3c-4051-bc36-84600b388792',
                              roleContext: _role,
                            );
                            if (!mounted) return;
                            setState(() => _claiming = false);

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  id == null
                                      ? 'Gated claim failed'
                                      : 'Gated pass claimed — graph densified',
                                ),
                              ),
                            );
                            if (id != null) {
                              setState(() => _graphLoading = true);
                              _loadGraphStats();
                            }
                          },
                    child: Text(_claiming ? '…' : 'CLAIM'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HudKpi extends StatelessWidget {
  const _HudKpi({
    required this.role,
    required this.label,
    required this.value,
    required this.icon,
  });
  final String role;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final accent = context.roleAccent(role);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: context.rolePanelBackground(role),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.rolePanelBorder(role)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent.withValues(alpha: 0.85), size: 16),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: context.roleTextPrimary(role),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: context.roleTextSubtle(role),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// Spec: unique per-role dashboard. Business must not share FeedTab as home.
// ==========================================
class BusinessHomeTab extends StatefulWidget {
  const BusinessHomeTab({super.key});

  @override
  State<BusinessHomeTab> createState() => _BusinessHomeTabState();
}

class _BusinessHomeTabState extends State<BusinessHomeTab> {
  static const _role = 'business';
  int _eventCount = 0;
  num _supportImpact = 0;
  bool _graphLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final client = Supabase.instance.client;
    final graph = GraphEventService(client);
    final oppSvc = context.read<OpportunityService>();
    try {
      await oppSvc.fetchActiveOpportunities();
      final all = await graph.countMyEvents();
      await graph.recomputeSupportImpact();
      final impact = await graph.mySupportImpactScore();
      if (!mounted) return;
      setState(() {
        _eventCount = all;
        _supportImpact = impact;
        _graphLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _graphLoading = false);
    }
  }

  void _go(String tabLabel) {
    final nav = RoleShellNav.maybeOf(context);
    if (nav != null) {
      nav.goToLabel(tabLabel);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open $tabLabel from the sidebar')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.roleAccent(_role);
    final oppSvc = context.watch<OpportunityService>();
    final openCount = oppSvc.opportunities.length;
    final loading = oppSvc.isLoading || _graphLoading;

    return Scaffold(
      backgroundColor: context.roleShellBackground(_role),
      appBar: AppBar(
        backgroundColor: context.roleShellBackground(_role),
        title: Text(
          'BUSINESS OPERATIONS HUD',
          style: TextStyle(
            color: context.roleTextPrimary(_role),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accent, size: 20),
            onPressed: () {
              setState(() => _graphLoading = true);
              _load();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: _HudKpi(
                  role: _role,
                  label: 'OPEN CAMPAIGNS',
                  value: loading ? '—' : '$openCount',
                  icon: Icons.campaign_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HudKpi(
                  role: _role,
                  label: 'GRAPH EVENTS',
                  value: _graphLoading ? '—' : '$_eventCount',
                  icon: Icons.hub_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HudKpi(
                  role: _role,
                  label: 'IMPACT',
                  value: _graphLoading
                      ? '—'
                      : _supportImpact.toStringAsFixed(0),
                  icon: Icons.insights_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HudKpi(
                  role: _role,
                  label: 'SUITE',
                  value: 'LIVE',
                  icon: Icons.dashboard_customize_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'CAMPAIGN QUEUE',
            style: TextStyle(
              color: context.roleTextSubtle(_role),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _go('Campaigns'),
              child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(_role),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.rolePanelBorder(_role)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.campaign_outlined,
                  color: accent.withValues(alpha: 0.7),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  openCount > 0
                      ? 'Campaigns in market'
                      : 'No campaigns right now',
                  style: TextStyle(
                    color: context.roleTextPrimary(_role),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  openCount > 0
                      ? '$openCount open campaign${openCount == 1 ? '' : 's'} · impact ${_supportImpact.toStringAsFixed(0)}'
                      : 'Publish a campaign to start creator applications and attribution.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.roleTextMuted(_role),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'BRAND CONTROL',
            style: TextStyle(
              color: context.roleTextSubtle(_role),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _go('Suite'),
              child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(_role),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.rolePanelBorder(_role)),
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
                  child: Icon(Icons.business_outlined, color: accent, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Brand Impact Engine',
                        style: TextStyle(
                          color: context.roleTextPrimary(_role),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Spend, deal value, and attribution live in Suite',
                        style: TextStyle(
                          color: context.roleTextMuted(_role),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: accent.withValues(alpha: 0.6), size: 20),
              ],
            ),
          ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'CAMPAIGNS',
            style: TextStyle(
              color: context.roleTextSubtle(_role),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _go('Campaigns'),
              child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(_role),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.rolePanelBorder(_role)),
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
                  child: Icon(Icons.campaign_outlined, color: accent, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        openCount == 0
                            ? 'No open campaigns'
                            : '$openCount open ${openCount == 1 ? 'campaign' : 'campaigns'}',
                        style: TextStyle(
                          color: context.roleTextPrimary(_role),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Manage full list in the Campaigns tab',
                        style: TextStyle(
                          color: context.roleTextMuted(_role),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: accent.withValues(alpha: 0.6), size: 20),
              ],
            ),
          ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeedTab extends StatelessWidget {
  final String? role;
  const FeedTab({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    final r = (role ?? 'talent').trim().toLowerCase();
    final accentColor = context.roleAccent(role);
    final isTalent = r == 'talent';

    // Kick off load if empty
    final postSvc = context.read<PostService>();
    if (postSvc.posts.isEmpty && !postSvc.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        postSvc.ensureInitialized();
      });
    }

    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      appBar: AppBar(
        backgroundColor: context.roleShellBackground(role),
        title: Text(
          isTalent ? 'TALENT ACTIVITY MATRIX' : 'BUSINESS ATTRIBUTION LOG',
          style: TextStyle(
            color: context.roleTextPrimary(role),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor, size: 20),
            onPressed: () => postSvc.ensureInitialized(),
          ),
        ],
      ),
      body: PostFeedView(role: r),
    );
  }
}

// ==========================================
// 2. REELS TAB (CONTENT PERFORMANCE HUB)
// ==========================================
class ReelsTab extends StatelessWidget {
  final String? role;
  const ReelsTab({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    final accent = context.roleAccent(role);
    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      appBar: AppBar(
        backgroundColor: context.roleShellBackground(role),
        title: Text(
          'REELS',
          style: TextStyle(
            color: context.roleTextPrimary(role),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.smart_display_outlined,
                color: accent.withValues(alpha: 0.7),
                size: 40,
              ),
              const SizedBox(height: 14),
              Text(
                'No reels yet',
                style: TextStyle(
                  color: context.roleTextPrimary(role),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Short-form performance will show up here once you publish.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.roleTextMuted(role),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. DISCOVER TAB (CAMPAIGN & NODE MATCHING)
// ==========================================
class DiscoverTab extends StatelessWidget {
  final String? role;
  const DiscoverTab({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    final r = (role ?? 'talent').trim().toLowerCase();
    final accent = context.roleAccent(role);
    final isTalent = r == 'talent';
    final isAudience = r == 'audience';
    final title = isTalent
        ? 'DISCOVER MISSIONS'
        : isAudience
        ? 'DISCOVER'
        : 'DISCOVER TALENT ECOSYSTEM';
    final emptyTitle = isTalent
        ? 'No missions yet'
        : isAudience
        ? 'Nothing to discover yet'
        : 'No talent nodes yet';
    final emptyBody = isTalent
        ? 'Campaign missions that match your profile will show up here.'
        : isAudience
        ? 'Creators, drops, and experiences will appear as the graph densifies.'
        : 'Creator matches based on fandom fit will appear here.';

    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      appBar: AppBar(
        backgroundColor: context.roleShellBackground(role),
        title: Text(
          title,
          style: TextStyle(
            color: context.roleTextPrimary(role),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore_outlined,
                color: accent.withValues(alpha: 0.7),
                size: 40,
              ),
              const SizedBox(height: 14),
              Text(
                emptyTitle,
                style: TextStyle(
                  color: context.roleTextPrimary(role),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                emptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.roleTextMuted(role),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. STUDIO TAB (IMPACT & TELEMETRY CONTROL ENGINE)
// ==========================================
class StudioTab extends StatefulWidget {
  final String? role;
  const StudioTab({super.key, this.role});

  @override
  State<StudioTab> createState() => _StudioTabState();
}

class _StudioTabState extends State<StudioTab> {
  final SpotlightDatabase _database = SpotlightDatabase();

  bool _isLoading = true;
  String? _errorMessage;
  BrandAttributionSummary? _brandSummary;
  CreatorAttributionSummary? _creatorSummary;

  bool get _isTalent =>
      (widget.role ?? 'talent').trim().toLowerCase() == 'talent';

  Color get _accentColor => context.roleAccent(widget.role);

  @override
  void initState() {
    super.initState();
    _loadAttribution();
  }

  Future<void> _loadAttribution() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isTalent) {
        final creatorSummary = await _database.getCreatorAttribution();
        if (!mounted) return;
        setState(() {
          _creatorSummary = creatorSummary;
        });
      } else {
        final brandSummary = await _database.getBrandAttribution();
        if (!mounted) return;
        setState(() {
          _brandSummary = brandSummary;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load attribution data.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(num? value) {
    if (value == null) return '--';
    return '\$${value.toStringAsFixed(0)}';
  }

  String _formatPercent(num? value) {
    if (value == null) return '--';
    return '${value.toStringAsFixed(1)}%';
  }

  String _formatTimestamp(String? value) {
    if (value == null || value.isEmpty) return 'Awaiting summary generation';
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.roleShellBackground(widget.role),
      appBar: AppBar(
        backgroundColor: context.roleShellBackground(widget.role),
        title: Text(
          _isTalent ? 'CREATOR OPERATIONS ENGINE' : 'BRAND IMPACT ENGINE',
          style: TextStyle(
            color: context.roleTextPrimary(widget.role),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _accentColor, size: 20),
            onPressed: _loadAttribution,
          ),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: _accentColor));
    }

    if (_errorMessage != null) {
      return _buildStatePanel(
        icon: Icons.error_outline,
        title: 'ATTRIBUTION LINK FAILED',
        subtitle: _errorMessage!,
      );
    }

    if (_isTalent && _creatorSummary == null) {
      return _buildStatePanel(
        icon: Icons.insights_outlined,
        title: 'NO CREATOR ATTRIBUTION DATA YET',
        subtitle: 'Metrics will appear after attribution entries are recorded.',
      );
    }

    if (!_isTalent && _brandSummary == null) {
      return _buildStatePanel(
        icon: Icons.insights_outlined,
        title: 'NO BRAND ATTRIBUTION DATA YET',
        subtitle: 'Metrics will appear after attribution entries are recorded.',
      );
    }

    // Scrollable — GridView + signal panel must not use Expanded under tight height.
    return ListView(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: _isTalent
              ? [
                  _TelemetryCard(
                    role: widget.role,
                    title: 'Total Earnings',
                    value: _formatCurrency(_creatorSummary?.totalEarnings),
                    trend: 'CREATOR ATTRIBUTION LIVE',
                    icon: Icons.monetization_on_outlined,
                    accentColor: _accentColor,
                  ),
                  _TelemetryCard(
                    role: widget.role,
                    title: 'Pipeline Value',
                    value: _formatCurrency(_creatorSummary?.pipelineValue),
                    trend: 'SUMMARY RESOLVED',
                    icon: Icons.account_tree_outlined,
                    accentColor: _accentColor,
                  ),
                  _TelemetryCard(
                    role: widget.role,
                    title: 'Completion Rate',
                    value: _formatPercent(_creatorSummary?.completionRatePct),
                    trend: 'SYSTEM SECURE',
                    icon: Icons.gpp_good_outlined,
                    accentColor: _accentColor,
                  ),
                  _TelemetryCard(
                    role: widget.role,
                    title: 'Creator',
                    value: _creatorSummary?.creatorName ?? '--',
                    trend: _formatTimestamp(
                      _creatorSummary?.summaryGeneratedAt,
                    ),
                    icon: Icons.person_outline,
                    accentColor: _accentColor,
                  ),
                ]
              : [
                  _TelemetryCard(
                    role: widget.role,
                    title: 'Total Spend',
                    value: _formatCurrency(_brandSummary?.totalSpend),
                    trend: 'BRAND ATTRIBUTION LIVE',
                    icon: Icons.monetization_on_outlined,
                    accentColor: _accentColor,
                  ),
                  _TelemetryCard(
                    role: widget.role,
                    title: 'Avg Deal Value',
                    value: _formatCurrency(_brandSummary?.avgDealValue),
                    trend: 'SUMMARY RESOLVED',
                    icon: Icons.handshake_outlined,
                    accentColor: _accentColor,
                  ),
                  _TelemetryCard(
                    role: widget.role,
                    title: 'Completion Rate',
                    value: _formatPercent(_brandSummary?.completionRatePct),
                    trend: 'SYSTEM SECURE',
                    icon: Icons.gpp_good_outlined,
                    accentColor: _accentColor,
                  ),
                  _TelemetryCard(
                    role: widget.role,
                    title: 'Brand',
                    value: _brandSummary?.brandName ?? '--',
                    trend: _formatTimestamp(_brandSummary?.summaryGeneratedAt),
                    icon: Icons.business_outlined,
                    accentColor: _accentColor,
                  ),
                ],
        ),
        const SizedBox(height: 24),
        Text(
          'REALTIME SIGNAL FLOWS',
          style: TextStyle(
            color: context.roleTextSubtle(widget.role),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.rolePanelBackground(widget.role),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.rolePanelBorder(widget.role)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.waves,
                color: _accentColor.withValues(alpha: 0.4),
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                _isTalent
                    ? 'CREATOR ATTRIBUTION SIGNALS LOCKED TO VERIFIED SUMMARY LAYER'
                    : 'BRAND ATTRIBUTION SIGNALS LOCKED TO VERIFIED SUMMARY LAYER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.roleTextSubtle(widget.role),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStatePanel({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.rolePanelBackground(widget.role),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.rolePanelBorder(widget.role)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _accentColor, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.roleTextPrimary(widget.role),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.roleTextFaint(widget.role),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. OPPORTUNITIES TAB (ESCROW CONTRACTS)
// ==========================================
class OpportunitiesTab extends StatefulWidget {
  final String? role;
  const OpportunitiesTab({super.key, this.role});

  @override
  State<OpportunitiesTab> createState() => _OpportunitiesTabState();
}

class _OpportunitiesTabState extends State<OpportunitiesTab> {
  String? get role => widget.role;
  bool get isBusiness => (role ?? '').toLowerCase() == 'business';
  final Set<String> _applying = {};

  Future<void> _createCampaign() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final accent = context.roleAccent(role);
        return AlertDialog(
          backgroundColor: context.rolePanelBackground(role),
          title: Text(
            'New campaign',
            style: TextStyle(
              color: context.roleTextPrimary(role),
              fontSize: 16,
            ),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: TextStyle(color: context.roleTextPrimary(role)),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: context.roleTextMuted(role)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  style: TextStyle(color: context.roleTextPrimary(role)),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: context.roleTextMuted(role)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: context.roleTextMuted(role)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accent),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Publish'),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    final title = titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title required')));
      return;
    }
    final auth = context.read<AppAuthProvider>();
    final uid = auth.currentUser?.userId;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not signed in')));
      return;
    }
    final svc = context.read<OpportunityService>();
    try {
      await svc.createCampaign(
        title: title,
        description: descCtrl.text.trim(),
        brandId: uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Campaign published')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.roleAccent(role);
    final svc = Provider.of<OpportunityService>(context);
    final items = svc.opportunities;
    final loading = svc.isLoading;

    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      appBar: AppBar(
        backgroundColor: context.roleShellBackground(role),
        title: Text(
          isBusiness ? 'CAMPAIGNS' : 'OPPORTUNITIES',
          style: TextStyle(
            color: context.roleTextPrimary(role),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          if (isBusiness)
            IconButton(
              tooltip: 'New campaign',
              icon: Icon(Icons.add_circle_outline, color: accent, size: 22),
              onPressed: _createCampaign,
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: accent, size: 20),
            onPressed: () => svc.fetchActiveOpportunities(),
          ),
        ],
      ),
      floatingActionButton: isBusiness
          ? FloatingActionButton.extended(
              onPressed: _createCampaign,
              backgroundColor: accent,
              foregroundColor: context.roleOnAccent(role),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'New campaign',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            )
          : null,
      body: loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      svc.lastError != null
                          ? Icons.error_outline
                          : Icons.work_outline,
                      color: context.roleTextSubtle(role),
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      svc.lastError != null
                          ? 'Could not load ${isBusiness ? 'campaigns' : 'opportunities'}'
                          : (isBusiness
                                ? 'No campaigns yet'
                                : 'No open opportunities'),
                      style: TextStyle(
                        color: context.roleTextPrimary(role),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      svc.lastError != null
                          ? svc.lastError!
                          : (isBusiness
                                ? 'Publish a pilot campaign to start densifying creator applications'
                                : 'Pull to refresh or check back later'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.roleTextMuted(role),
                        fontSize: 12,
                      ),
                    ),
                    if (isBusiness && svc.lastError == null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                        ),
                        onPressed: _createCampaign,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Create campaign'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final row = items[index];
                final title = (row['title'] ?? 'Untitled').toString();
                final description = (row['description'] ?? '').toString();
                final status = (row['status'] ?? 'open').toString();
                final category = (row['category'] ?? '').toString();
                final compensation = (row['compensation_type'] ?? '')
                    .toString();
                final budgetLabel = compensation.isNotEmpty
                    ? compensation
                    : (category.isNotEmpty ? category : '—');
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.rolePanelBackground(role),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.rolePanelBorder(role)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: context.roleTextPrimary(role),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.28),
                              ),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.roleTextMuted(role),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            budgetLabel,
                            style: TextStyle(
                              color: context.roleTextPrimary(role),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (!isBusiness && status.toLowerCase() == 'open')
                            SizedBox(
                              height: 32,
                              child: Builder(
                                builder: (ctx) {
                                  final id = (row['id'] ?? '').toString();
                                  final busy = _applying.contains(id);
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      foregroundColor: context.roleOnAccent(role),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    onPressed: (id.isEmpty || busy)
                                        ? null
                                        : () async {
                                            setState(() => _applying.add(id));
                                            try {
                                              await svc.applyToOpportunity(
                                                opportunityId: id,
                                                roleContext: (role ?? 'talent')
                                                    .toLowerCase(),
                                              );
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Application submitted — graph densified',
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text('Apply failed: $e'),
                                                ),
                                              );
                                            } finally {
                                              if (mounted) {
                                                setState(
                                                  () => _applying.remove(id),
                                                );
                                              }
                                            }
                                          },
                                    child: Text(busy ? '…' : 'APPLY'),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class GatedPassesTab extends StatefulWidget {
  final String? role;
  const GatedPassesTab({super.key, this.role});

  @override
  State<GatedPassesTab> createState() => _GatedPassesTabState();
}

class _GatedPassesTabState extends State<GatedPassesTab> {
  List<Map<String, dynamic>> _passes = [];
  final Set<String> _claiming = {};
  final Set<String> _claimedPassIds = {};
  bool _claimedByMeOnly = false;
  bool _loading = true;
  String? _error;

  String? get role => widget.role;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _isClaimedByMe(Map<String, dynamic> row) {
    final claimed = row['claimed_by_me'];
    if (claimed is bool) return claimed;
    final status = (row['claim_status'] ?? '').toString().toLowerCase();
    if (status.isNotEmpty) return status == 'claimed';
    final id = (row['id'] ?? '').toString();
    return _claimedPassIds.contains(id);
  }

  List<Map<String, dynamic>> _dedupePasses(List<Map<String, dynamic>> rows) {
    final seenIds = <String>{};
    final seenTitles = <String>{};
    final deduped = <Map<String, dynamic>>[];
    for (final row in rows) {
      final id = (row['id'] ?? '').toString();
      final titleKey = (row['title'] ?? '').toString().trim().toLowerCase();
      if (id.isEmpty || seenIds.contains(id)) continue;
      if (titleKey.isNotEmpty && seenTitles.contains(titleKey)) continue;
      seenIds.add(id);
      if (titleKey.isNotEmpty) seenTitles.add(titleKey);
      deduped.add(row);
    }
    return deduped;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;

      final rows = await client
          .from('gated_passes')
          .select(
            'id, title, description, status, max_claims, claim_count, host_user_id, created_at',
          )
          .eq('status', 'open')
          .order('created_at', ascending: false)
          .limit(50);

      final claimedIds = <String>{};
      if (uid != null && uid.isNotEmpty) {
        try {
          final claims = await client
              .from('gated_pass_claims')
              .select('pass_id')
              .eq('claimer_user_id', uid);
          for (final c in (claims as List)) {
            final pid = (c['pass_id'] ?? '').toString();
            if (pid.isNotEmpty) claimedIds.add(pid);
          }
        } catch (_) {
          try {
            final claims = await client
                .from('gated_pass_claims')
                .select('pass_id')
                .eq('user_id', uid);
            for (final c in (claims as List)) {
              final pid = (c['pass_id'] ?? '').toString();
              if (pid.isNotEmpty) claimedIds.add(pid);
            }
          } catch (_) {}
        }
      }

      final list = _dedupePasses(List<Map<String, dynamic>>.from(rows as List));
      final filtered = _claimedByMeOnly
          ? list
              .where(
                (row) =>
                    claimedIds.contains((row['id'] ?? '').toString()) ||
                    _isClaimedByMe(row),
              )
              .toList()
          : list;

      if (!mounted) return;
      setState(() {
        _claimedPassIds
          ..clear()
          ..addAll(claimedIds);
        _passes = filtered;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _claim(String passId) async {
    if (_claiming.contains(passId)) return;
    setState(() => _claiming.add(passId));
    final graph = GraphEventService(Supabase.instance.client);
    final id = await graph.claimGatedPass(
      passId: passId,
      roleContext: (role ?? 'audience').toLowerCase(),
    );
    if (!mounted) return;
    setState(() {
      _claiming.remove(passId);
      if (id != null) {
        _claimedPassIds.add(passId);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          id == null ? 'Claim failed' : 'Pass claimed — graph densified',
        ),
      ),
    );
    if (id != null) _load();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.roleAccent(role);
    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      appBar: AppBar(
        backgroundColor: context.roleShellBackground(role),
        title: Text(
          'PASSES',
          style: TextStyle(
            color: context.roleTextPrimary(role),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _claimedByMeOnly = !_claimedByMeOnly);
              _load();
            },
            child: Text(
              _claimedByMeOnly ? 'ALL' : 'CLAIMED',
              style: TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: accent, size: 20),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load passes\n$_error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.roleTextMuted(role),
                    fontSize: 13,
                  ),
                ),
              ),
            )
          : _passes.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    color: context.roleTextSubtle(role),
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _claimedByMeOnly ? 'No claimed passes' : 'No open passes',
                    style: TextStyle(
                      color: context.roleTextPrimary(role),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _claimedByMeOnly
                        ? 'Passes you claimed will appear here'
                        : 'Gated experiences from creators will appear here',
                    style: TextStyle(
                      color: context.roleTextMuted(role),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              itemCount: _passes.length,
              itemBuilder: (context, index) {
                final row = _passes[index];
                final id = (row['id'] ?? '').toString();
                final title = (row['title'] ?? 'Pass').toString();
                final desc = (row['description'] ?? '').toString();
                final claimed = row['claim_count'];
                final max = row['max_claims'];
                final busy = _claiming.contains(id);
                final claimedByMe = _isClaimedByMe(row);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.rolePanelBackground(role),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.rolePanelBorder(role)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: context.roleTextPrimary(role),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: claimedByMe
                                  ? accent.withValues(alpha: 0.18)
                                  : accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.28),
                              ),
                            ),
                            child: Text(
                              claimedByMe ? 'CLAIMED' : 'OPEN',
                              style: TextStyle(
                                color: accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          desc,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.roleTextMuted(role),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            max == null
                                ? '${claimed ?? 0} claimed'
                                : '${claimed ?? 0} / $max claimed',
                            style: TextStyle(
                              color: context.roleTextSubtle(role),
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: context.roleOnAccent(role),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onPressed: (id.isEmpty || busy || claimedByMe)
                                  ? null
                                  : () => _claim(id),
                              child: Text(
                                busy
                                    ? '…'
                                    : claimedByMe
                                    ? 'CLAIMED'
                                    : 'CLAIM',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  final String? role;
  const ProfileTab({super.key, this.role});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  num _supportImpact = 0;
  num _topFandom = 0;
  List<Map<String, dynamic>> _edges = [];
  bool _loadingGraph = true;

  String? get role => widget.role;

  @override
  void initState() {
    super.initState();
    _loadGraph();
  }

  Future<void> _loadGraph() async {
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
        _loadingGraph = false;
      });
    } catch (e) {
      debugPrint('ProfileTab graph load failed: $e');
      if (mounted) setState(() => _loadingGraph = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = context.roleAccent(role);
    final auth = Provider.of<AppAuthProvider>(context);
    final user = auth.currentUser;
    final name = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : (user?.username.isNotEmpty == true ? user!.username : 'User');
    final email = user?.email ?? '—';
    // Operating shell (tab registry), not DB active_role.
    final shellRole = (role ?? 'audience').trim().toLowerCase();
    final shellLabel = switch (shellRole) {
      'talent' => 'CREATOR',
      'business' => 'BUSINESS',
      'admin' => 'ADMIN',
      'audience' => 'AUDIENCE',
      _ => shellRole.toUpperCase(),
    };
    final status = user?.applicationStatusSummary ?? 'none';
    final photo = user?.profilePhoto;
    final roles = user?.approvedRoles ?? const <String>[];

    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const SizedBox(height: 12),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: context.rolePanelBackground(role),
                backgroundImage: (photo != null && photo.isNotEmpty)
                    ? NetworkImage(photo)
                    : null,
                child: (photo == null || photo.isEmpty)
                    ? Icon(
                        Icons.account_circle_outlined,
                        color: accentColor,
                        size: 50,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.roleTextPrimary(role),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.roleTextMuted(role),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ROLE: $shellLabel',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accentColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // ── Graph identity ──────────────────────────────────────────
            Text(
              'GRAPH IDENTITY',
              style: TextStyle(
                color: context.roleTextSubtle(role),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _GraphStatCard(
                    role: role,
                    label: 'SUPPORT IMPACT',
                    value: _loadingGraph
                        ? '—'
                        : _supportImpact.toStringAsFixed(0),
                    icon: Icons.star_outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _GraphStatCard(
                    role: role,
                    label: 'TOP FANDOM',
                    value: _loadingGraph ? '—' : _topFandom.toStringAsFixed(0),
                    icon: Icons.favorite_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.rolePanelBackground(role),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.rolePanelBorder(role)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RELATIONSHIPS',
                    style: TextStyle(
                      color: context.roleTextSubtle(role),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingGraph)
                    Text(
                      'Loading…',
                      style: TextStyle(
                        color: context.roleTextMuted(role),
                        fontSize: 12,
                      ),
                    )
                  else if (_edges.isEmpty)
                    Text(
                      'No edges yet — apply or claim to densify the graph.',
                      style: TextStyle(
                        color: context.roleTextMuted(role),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    )
                  else
                    ..._edges.map((e) {
                      final type = (e['edge_type'] ?? 'edge').toString();
                      final strength = e['strength_score'];
                      final n = e['supporting_event_count'];
                      final obj = (e['object_profile_id'] ?? '').toString();
                      final shortObj = obj.length > 12
                          ? '${obj.substring(0, 6)}…${obj.substring(obj.length - 4)}'
                          : obj;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.hub_outlined,
                              size: 16,
                              color: accentColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type,
                                    style: TextStyle(
                                      color: context.roleTextPrimary(role),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '→ $shortObj',
                                    style: TextStyle(
                                      color: context.roleTextMuted(role),
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${strength ?? 0}',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (n != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                '($n)',
                                style: TextStyle(
                                  color: context.roleTextSubtle(role),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // ── Account identity ────────────────────────────────────────
            Text(
              'ACCOUNT',
              style: TextStyle(
                color: context.roleTextSubtle(role),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.rolePanelBackground(role),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.rolePanelBorder(role)),
              ),
              child: Column(
                children: [
                  _buildIdentityRow(
                    context,
                    role,
                    'User ID',
                    _shortId(user?.userId),
                  ),
                  Divider(color: context.rolePanelBorder(role), height: 24),
                  _buildIdentityRow(
                    context,
                    role,
                    'Application Status',
                    status,
                  ),
                  Divider(color: context.rolePanelBorder(role), height: 24),
                  _buildIdentityRow(
                    context,
                    role,
                    'Approved Roles',
                    roles.isEmpty ? 'audience' : roles.join(', '),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortId(String? id) {
    if (id == null || id.isEmpty) return '—';
    if (id.length <= 12) return id;
    return '${id.substring(0, 6)}…${id.substring(id.length - 4)}';
  }

  Widget _buildIdentityRow(
    BuildContext context,
    String? role,
    String label,
    String status,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: context.roleTextFaint(role), fontSize: 12),
        ),
        Flexible(
          child: Text(
            status,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: context.roleTextPrimary(role),
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _GraphStatCard extends StatelessWidget {
  const _GraphStatCard({
    required this.role,
    required this.label,
    required this.value,
    required this.icon,
  });
  final String? role;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final accent = context.roleAccent(role);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: context.rolePanelBackground(role),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.rolePanelBorder(role)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent.withValues(alpha: 0.9), size: 16),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: context.roleTextPrimary(role),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: context.roleTextSubtle(role),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
