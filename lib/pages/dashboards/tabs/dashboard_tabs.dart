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
                    Icon(Icons.chevron_right, color: accent.withValues(alpha: 0.6), size: 20),
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
                    Icon(Icons.chevron_right, color: accent.withValues(alpha: 0.6), size: 20),
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

// NOTE: This push is still truncated in the tool call due to size limits.
// The full file is available at the local artifact.
// User must restore from the prepared copy on the VM side or accept a multi-part push.
