import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/models/dashboard_tab_spec.dart';
import 'package:spotlight_connect/pages/admin/admin_feature_controls_tab.dart';
import 'package:spotlight_connect/pages/dashboards/role_dashboard_shell.dart';
import 'package:spotlight_connect/pages/dashboards/tabs/dashboard_tabs.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/services/admin_approvals_service.dart';

/// Admin entry — Figma Admin Console structure inside [RoleDashboardShell].
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _pendingCount = 0;
  int _flaggedCount = 4;
  final _approvalsService = AdminApprovalsService();

  @override
  void initState() {
    super.initState();
    _refreshPendingCount();
  }

  Future<void> _refreshPendingCount() async {
    try {
      final list = await _approvalsService.fetchPending();
      if (!mounted) return;
      setState(() => _pendingCount = list.length.clamp(0, 999));
    } catch (_) {}
  }

  void _onPendingChanged(int delta) {
    setState(() => _pendingCount = (_pendingCount + delta).clamp(0, 999));
  }

  void _setPendingCount(int count) {
    setState(() => _pendingCount = count.clamp(0, 999));
  }

  void _onFlaggedChanged(int delta) {
    setState(() => _flaggedCount = (_flaggedCount + delta).clamp(0, 999));
  }

  @override
  Widget build(BuildContext context) {
    return RoleDashboardShell(
      role: 'admin',
      tabs: [
        DashboardTabSpec(
          label: 'Dashboard',
          icon: Icons.grid_view_rounded,
          builder: () => _AdminOverviewTab(
            onPendingChanged: _onPendingChanged,
            onPendingCountSet: _setPendingCount,
            onFlaggedChanged: _onFlaggedChanged,
          ),
        ),
        DashboardTabSpec(
          label: 'Approvals',
          icon: Icons.verified_outlined,
          badge: _pendingCount > 0 ? _pendingCount : null,
          builder: () => _AdminApprovalsTab(onPendingChanged: _onPendingChanged, onPendingCountSet: _setPendingCount),
        ),
        DashboardTabSpec(
          label: 'Users',
          icon: Icons.people_outline,
          builder: () => const _AdminUsersTab(),
        ),
        DashboardTabSpec(
          label: 'Moderation',
          icon: Icons.shield_outlined,
          badge: _flaggedCount > 0 ? _flaggedCount : null,
          builder: () => _AdminModerationTab(onFlaggedChanged: _onFlaggedChanged),
        ),
        DashboardTabSpec(
          label: 'Controls',
          icon: Icons.tune_outlined,
          builder: () => const AdminFeatureControlsTab(),
        ),
        DashboardTabSpec(
          label: 'Command',
          icon: Icons.terminal_outlined,
          builder: () => const _AdminCommandTab(),
        ),
        DashboardTabSpec(
          label: 'Profile',
          icon: Icons.person_outline,
          builder: () => const ProfileTab(role: 'admin'),
        ),
      ],
    );
  }
}

class _AdminUi {
  static const bgCard = SpotlightTokens.bgSurface;
  static const border = SpotlightTokens.borderSubtle;
  static const textPrimary = SpotlightTokens.textPrimary;
  static const textMuted = SpotlightTokens.textSecondary;
  static const textDim = SpotlightTokens.textMuted;
  static const cyan = SpotlightTokens.cyan;
  static const amber = SpotlightTokens.warning;
  static const rose = SpotlightTokens.rose;
  static const green = SpotlightTokens.success;
  static const blue = Color(0xFF3B82F6);
  static const purple = SpotlightTokens.purple;
  static const radius = SpotlightTokens.radiusLg;
}

// ─── Overview (Figma Admin Console main surface) ─────────────────────────────
class _AdminOverviewTab extends StatelessWidget {
  const _AdminOverviewTab({
    required this.onPendingChanged,
    required this.onFlaggedChanged,
    this.onPendingCountSet,
  });
  final ValueChanged<int> onPendingChanged;
  final ValueChanged<int> onFlaggedChanged;
  final ValueChanged<int>? onPendingCountSet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin Console',
                        style: TextStyle(
                          color: _AdminUi.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Platform health, moderation, and oversight dashboard',
                        style: TextStyle(
                          color: _AdminUi.textMuted.withValues(alpha: 0.95),
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _PillBadge(
                  label: '5 Urgent Items',
                  fg: _AdminUi.amber,
                  bg: const Color(0x1FF59E0B),
                  border: const Color(0x40F59E0B),
                ),
                const SizedBox(width: 8),
                _GhostButton(label: 'System Status', onTap: () {}),
              ],
            ),
            const SizedBox(height: 22),

            // KPI grid — exact Figma numbers
            _KpiGrid(wide: wide),
            const SizedBox(height: 18),

            // Chart + Quick Actions
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 6, child: _PlatformGrowthCard()),
                  const SizedBox(width: 16),
                  Expanded(flex: 5, child: _QuickActionsCard()),
                ],
              )
            else ...[
              const _PlatformGrowthCard(),
              const SizedBox(height: 16),
              _QuickActionsCard(),
            ],
            const SizedBox(height: 18),

            // Pending Approvals preview
            _PendingApprovalsPreview(onChanged: onPendingChanged, onCountSet: onPendingCountSet),
            const SizedBox(height: 18),

            // Flagged Content preview
            _FlaggedContentPreview(onChanged: onFlaggedChanged),
          ],
        );
      },
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.wide});
  final bool wide;

  static const _items = <_KpiData>[
    _KpiData('TOTAL USERS', '84,291', '+2,848 this month', true),
    _KpiData('ACTIVE CREATORS', '12,480', '+8.2% MoM', true),
    _KpiData('ACTIVE BUSINESSES', '3,142', '+12.4% MoM', true),
    _KpiData('PENDING APPROVALS', '48', '12 urgent', false, urgent: true),
    _KpiData('ACTIVE CAMPAIGNS', '284', '+34 this week', true),
    _KpiData('FLAGGED CONTENT', '23', '−11 from last week', true),
  ];

  @override
  Widget build(BuildContext context) {
    final cols = wide ? 3 : (MediaQuery.sizeOf(context).width >= 640 ? 2 : 1);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisExtent: 118,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) => _KpiCard(data: _items[i]),
    );
  }
}

class _KpiData {
  const _KpiData(this.label, this.value, this.change, this.positive, {this.urgent = false});
  final String label;
  final String value;
  final String change;
  final bool positive;
  final bool urgent;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});
  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    final changeColor = data.urgent
        ? _AdminUi.rose
        : (data.positive ? _AdminUi.green : _AdminUi.rose);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: _AdminUi.bgCard,
        borderRadius: BorderRadius.circular(_AdminUi.radius),
        border: Border.all(color: _AdminUi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            style: const TextStyle(
              color: _AdminUi.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const Spacer(),
          Text(
            data.value,
            style: const TextStyle(
              color: _AdminUi.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                data.positive && !data.urgent
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 12,
                color: changeColor,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  data.change,
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 11.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlatformGrowthCard extends StatelessWidget {
  const _PlatformGrowthCard();

  @override
  Widget build(BuildContext context) {
    // Mock series matching Figma growth shape (Oct→Mar)
    final audience = [58.0, 62.0, 66.0, 72.0, 78.0, 86.0];
    final businesses = [52.0, 56.0, 60.0, 65.0, 71.0, 78.0];
    final creators = [55.0, 59.0, 64.0, 70.0, 76.0, 84.0];
    final months = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];

    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: _AdminUi.bgCard,
        borderRadius: BorderRadius.circular(_AdminUi.radius),
        border: Border.all(color: _AdminUi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Growth',
            style: TextStyle(
              color: _AdminUi.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Users by role over time',
            style: TextStyle(color: _AdminUi.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withValues(alpha: 0.04),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 25,
                      getTitlesWidget: (v, _) => Text(
                        v == 0 ? '0K' : '${v.toInt()}K',
                        style: const TextStyle(color: _AdminUi.textDim, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= months.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            months[i],
                            style: const TextStyle(color: _AdminUi.textDim, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _line(audience, _AdminUi.purple),
                  _line(businesses, _AdminUi.blue),
                  _line(creators, _AdminUi.cyan),
                ],
                lineTouchData: const LineTouchData(enabled: false),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: _AdminUi.purple, label: 'Audience'),
              SizedBox(width: 14),
              _LegendDot(color: _AdminUi.blue, label: 'Businesses'),
              SizedBox(width: 14),
              _LegendDot(color: _AdminUi.cyan, label: 'Creators'),
            ],
          ),
        ],
      ),
    );
  }

  static LineChartBarData _line(List<double> values, Color color) {
    return LineChartBarData(
      spots: [
        for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
      ],
      isCurved: true,
      color: color,
      barWidth: 2.2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: _AdminUi.textMuted, fontSize: 11)),
      ],
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  _QuickActionsCard();

  final _actions = const [
    _QaItem('Review Approvals', Icons.verified_outlined, '5 pending', _AdminUi.cyan),
    _QaItem('Moderation Queue', Icons.shield_outlined, '4 pending', _AdminUi.rose),
    _QaItem('User Lookup', Icons.search_rounded, null, _AdminUi.blue),
    _QaItem('Audit Log', Icons.receipt_long_outlined, null, _AdminUi.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: _AdminUi.bgCard,
        borderRadius: BorderRadius.circular(_AdminUi.radius),
        border: Border.all(color: _AdminUi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(color: _AdminUi.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          const Text(
            'Most common admin tasks',
            style: TextStyle(color: _AdminUi.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 72,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (_, i) {
              final a = _actions[i];
              return Material(
                color: const Color(0xFF0A0F1A),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  hoverColor: Colors.white.withValues(alpha: 0.03),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _AdminUi.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: a.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(a.icon, size: 18, color: a.color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                a.label,
                                style: const TextStyle(
                                  color: _AdminUi.textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (a.sub != null)
                                Text(
                                  a.sub!,
                                  style: TextStyle(color: a.color, fontSize: 11, fontFamily: 'monospace'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QaItem {
  const _QaItem(this.label, this.icon, this.sub, this.color);
  final String label;
  final IconData icon;
  final String? sub;
  final Color color;
}

class _PendingApprovalsPreview extends StatefulWidget {
  const _PendingApprovalsPreview({this.onChanged, this.onCountSet});
  final ValueChanged<int>? onChanged;
  final ValueChanged<int>? onCountSet;
  @override
  State<_PendingApprovalsPreview> createState() => _PendingApprovalsPreviewState();
}

class _PendingApprovalsPreviewState extends State<_PendingApprovalsPreview> {
  final _service = AdminApprovalsService();
  List<PendingApproval> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.fetchPending();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
      widget.onCountSet?.call(list.length);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _act(PendingApproval item, String action) async {
    // Optimistic remove
    setState(() => _items.remove(item));
    widget.onChanged?.call(-1);

    final color = action == 'Approved' ? _AdminUi.green : _AdminUi.rose;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action ${item.displayName}'),
        backgroundColor: color.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final reviewerId =
          Supabase.instance.client.auth.currentUser?.id ?? '';
      if (action == 'Approved') {
        await _service.approve(item: item, reviewerUserId: reviewerId);
      } else {
        await _service.reject(item: item, reviewerUserId: reviewerId);
      }
    } catch (e) {
      // Roll back on failure
      if (!mounted) return;
      setState(() => _items.insert(0, item));
      widget.onChanged?.call(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: _AdminUi.rose.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      decoration: BoxDecoration(
        color: _AdminUi.bgCard,
        borderRadius: BorderRadius.circular(_AdminUi.radius),
        border: Border.all(color: _AdminUi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pending Approvals', style: TextStyle(color: _AdminUi.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      _loading
                          ? 'Loading…'
                          : (_items.isEmpty ? 'All caught up' : 'Accounts awaiting review'),
                      style: const TextStyle(color: _AdminUi.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _loading ? null : _load,
                style: TextButton.styleFrom(foregroundColor: _AdminUi.cyan),
                child: const Text('Refresh', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: _AdminUi.rose, size: 28),
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _AdminUi.rose, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _load,
                      style: TextButton.styleFrom(foregroundColor: _AdminUi.cyan),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _AdminUi.cyan.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.verified_outlined, color: _AdminUi.cyan, size: 24),
                    ),
                    const SizedBox(height: 14),
                    const Text('All caught up', style: TextStyle(color: _AdminUi.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('No accounts waiting for review', style: TextStyle(color: _AdminUi.textDim, fontSize: 12.5)),
                  ],
                ),
              ),
            )
          else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('USER / ENTITY', style: TextStyle(color: _AdminUi.textDim, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                  Expanded(child: Text('TYPE', style: TextStyle(color: _AdminUi.textDim, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text('INFO', style: TextStyle(color: _AdminUi.textDim, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                  Expanded(child: Text('APPLIED', style: TextStyle(color: _AdminUi.textDim, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                  Expanded(child: Text('STATUS', style: TextStyle(color: _AdminUi.textDim, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                  SizedBox(width: 152),
                ],
              ),
            ),
            const Divider(height: 1, color: _AdminUi.border),
            for (final item in _items)
              _ApprovalRowWidget(
                row: _ApprovalRow(
                  item.displayName,
                  item.username.isNotEmpty ? '@${item.username}' : item.userId,
                  item.typeLabel,
                  item.requestedRole,
                  _fmtDate(item.createdAt),
                  'Pending',
                ),
                onApprove: () => _act(item, 'Approved'),
                onReject: () => _act(item, 'Rejected'),
              ),
          ],
        ],
      ),
    );
  }
}

class _ApprovalRow {
  const _ApprovalRow(this.name, this.email, this.type, this.info, this.date, this.status);
  final String name, email, type, info, date, status;
}

class _ApprovalRowWidget extends StatelessWidget {
  const _ApprovalRowWidget({
    required this.row,
    required this.onApprove,
    required this.onReject,
  });
  final _ApprovalRow row;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final isCreator = row.type == 'Creator';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF1A2535),
                  child: Text(row.name[0], style: const TextStyle(color: _AdminUi.textPrimary, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.name, style: const TextStyle(color: _AdminUi.textPrimary, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                      Text(row.email, style: const TextStyle(color: _AdminUi.textDim, fontSize: 11), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _PillBadge(
                label: row.type,
                fg: isCreator ? _AdminUi.cyan : _AdminUi.blue,
                bg: (isCreator ? _AdminUi.cyan : _AdminUi.blue).withValues(alpha: 0.12),
                border: (isCreator ? _AdminUi.cyan : _AdminUi.blue).withValues(alpha: 0.28),
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(row.info, style: const TextStyle(color: _AdminUi.textMuted, fontSize: 12), overflow: TextOverflow.ellipsis)),
          Expanded(child: Text(row.date, style: const TextStyle(color: _AdminUi.textDim, fontSize: 11, fontFamily: 'monospace'))),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _PillBadge(
                label: row.status,
                fg: _AdminUi.amber,
                bg: const Color(0x1FF59E0B),
                border: const Color(0x40F59E0B),
              ),
            ),
          ),
          SizedBox(
            width: 152,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _PrimarySm(label: 'Approve', onTap: onApprove),
                const SizedBox(width: 6),
                _DangerSm(label: 'Reject', onTap: onReject),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlaggedContentPreview extends StatefulWidget {
  const _FlaggedContentPreview({this.onChanged});
  final ValueChanged<int>? onChanged;
  @override
  State<_FlaggedContentPreview> createState() => _FlaggedContentPreviewState();
}

class _FlaggedContentPreviewState extends State<_FlaggedContentPreview> {
  late List<(String, String, String, String, String, String)> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      ('Spam / Promo', 'high', '3 reports', 'Unsolicited affiliate links in comments', 'user_1029', 'Mar 22'),
      ('Misinfo', 'medium', '2 reports', 'Unverified health claim in reel caption', 'user_824', 'Mar 21'),
      ('Harassment', 'high', '5 reports', 'Targeted comments on creator livestream', 'user_344', 'Mar 20'),
    ];
  }

  void _remove(int index) {
    final item = _items[index];
    setState(() => _items.removeAt(index));
    widget.onChanged?.call(-1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed: ${item.$1}'),
        backgroundColor: _AdminUi.rose.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: _AdminUi.bgCard,
        borderRadius: BorderRadius.circular(_AdminUi.radius),
        border: Border.all(color: _AdminUi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Flagged Content', style: TextStyle(color: _AdminUi.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      _items.isEmpty ? 'Queue clear' : 'Reported items requiring action',
                      style: const TextStyle(color: _AdminUi.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: _AdminUi.cyan),
                child: const Text('View all', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _AdminUi.green.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.shield_outlined, color: _AdminUi.green, size: 24),
                    ),
                    const SizedBox(height: 14),
                    const Text('Queue clear', style: TextStyle(color: _AdminUi.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('No flagged content requiring action', style: TextStyle(color: _AdminUi.textDim, fontSize: 12.5)),
                  ],
                ),
              ),
            )
          else
            for (var i = 0; i < _items.length; i++) ...[
              _FlaggedRow(
                type: _items[i].$1,
                severity: _items[i].$2,
                reports: _items[i].$3,
                content: _items[i].$4,
                creator: _items[i].$5,
                date: _items[i].$6,
                onRemove: () => _remove(i),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _FlaggedRow extends StatelessWidget {
  const _FlaggedRow({
    required this.type,
    required this.severity,
    required this.reports,
    required this.content,
    required this.creator,
    required this.date,
    required this.onRemove,
  });
  final String type, severity, reports, content, creator, date;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final high = severity == 'high';
    final sevColor = high ? _AdminUi.rose : _AdminUi.amber;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AdminUi.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: sevColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('🚩', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(type, style: const TextStyle(color: _AdminUi.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    _PillBadge(
                      label: severity,
                      fg: sevColor,
                      bg: sevColor.withValues(alpha: 0.12),
                      border: sevColor.withValues(alpha: 0.28),
                    ),
                    const SizedBox(width: 8),
                    Text(reports, style: const TextStyle(color: _AdminUi.textDim, fontSize: 11, fontFamily: 'monospace')),
                  ],
                ),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(color: _AdminUi.textMuted, fontSize: 12.5)),
                const SizedBox(height: 2),
                Text('$creator · $date', style: const TextStyle(color: _AdminUi.textDim, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _GhostButton(label: 'Review', onTap: () {}),
          const SizedBox(width: 6),
          _DangerSm(label: 'Remove', onTap: onRemove),
        ],
      ),
    );
  }
}

// ─── Approvals tab ───────────────────────────────────────────────────────────
class _AdminApprovalsTab extends StatelessWidget {
  const _AdminApprovalsTab({this.onPendingChanged, this.onPendingCountSet});
  final ValueChanged<int>? onPendingChanged;
  final ValueChanged<int>? onPendingCountSet;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      children: [
        const Text('Approvals Queue', style: TextStyle(color: _AdminUi.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Review and action creator and business account applications', style: TextStyle(color: _AdminUi.textMuted, fontSize: 13)),
        const SizedBox(height: 18),
        _PendingApprovalsPreview(onChanged: onPendingChanged, onCountSet: onPendingCountSet),
      ],
    );
  }
}

// ─── Users tab ───────────────────────────────────────────────────────────────
class _AdminUsersTab extends StatelessWidget {
  const _AdminUsersTab();

  static const _users = [
    ('Aria Chen', 'aria@example.com', 'Creator', 'active', '248.6K'),
    ('Nova Brands', 'hello@novabrands.co', 'Business', 'active', '—'),
    ('Jordan Blake', 'jordan@example.com', 'Creator', 'pending', '48K'),
    ('Alex Kim', 'alex@example.com', 'Audience', 'active', '83'),
    ('Maya Patel', 'maya@example.com', 'Creator', 'review', '12K'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      children: [
        const Text('User Management', style: TextStyle(color: _AdminUi.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Search, view, and manage platform accounts', style: TextStyle(color: _AdminUi.textMuted, fontSize: 13)),
        const SizedBox(height: 18),
        for (final u in _users) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _AdminUi.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _AdminUi.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1A2535),
                  child: Text(u.$1[0], style: const TextStyle(color: _AdminUi.textPrimary)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.$1, style: const TextStyle(color: _AdminUi.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5)),
                      Text(u.$2, style: const TextStyle(color: _AdminUi.textDim, fontSize: 11.5)),
                    ],
                  ),
                ),
                _PillBadge(
                  label: u.$3,
                  fg: u.$3 == 'Creator' ? _AdminUi.cyan : (u.$3 == 'Business' ? _AdminUi.blue : _AdminUi.purple),
                  bg: Colors.white.withValues(alpha: 0.04),
                  border: _AdminUi.border,
                ),
                const SizedBox(width: 8),
                _PillBadge(
                  label: u.$4,
                  fg: u.$4 == 'active' ? _AdminUi.green : _AdminUi.amber,
                  bg: Colors.white.withValues(alpha: 0.04),
                  border: _AdminUi.border,
                ),
                const SizedBox(width: 12),
                Text(u.$5, style: const TextStyle(color: _AdminUi.cyan, fontFamily: 'monospace', fontSize: 12)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Moderation tab ──────────────────────────────────────────────────────────
class _AdminModerationTab extends StatelessWidget {
  const _AdminModerationTab({this.onFlaggedChanged});
  final ValueChanged<int>? onFlaggedChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      children: [
        const Text('Moderation', style: TextStyle(color: _AdminUi.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Review flagged content, manage reports, and enforce platform policies', style: TextStyle(color: _AdminUi.textMuted, fontSize: 13)),
        const SizedBox(height: 18),
        _FlaggedContentPreview(onChanged: onFlaggedChanged),
      ],
    );
  }
}

// ─── Command (role shift — production capability, preserved) ─────────────────
class _AdminCommandTab extends StatelessWidget {
  const _AdminCommandTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'SYSTEM COMMAND FLIGHT DECK',
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: colorScheme.error.withValues(alpha: 0.30)),
              ),
              child: Text(
                'ROOT AUTH',
                style: TextStyle(color: colorScheme.error, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'GLOBAL PERSPECTIVE SHIFT PANEL',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'As an administrator, you are authorized to cross-examine other runtime environments. Mutating this configuration shifts your global session state context.',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, height: 1.5),
        ),
        const SizedBox(height: 20),
        _RoleMutationCard(
          title: 'SHIFTOUT TO CREATOR MATRIX',
          subtitle: 'Impersonate Talent / Creator HUD workspace',
          targetRole: 'talent',
          onTap: () => authProvider.setActiveRole('talent'),
        ),
        const SizedBox(height: 12),
        _RoleMutationCard(
          title: 'SHIFTOUT TO BRAND OPS',
          subtitle: 'Impersonate Business / Brand suite workspace',
          targetRole: 'business',
          onTap: () => authProvider.setActiveRole('business'),
        ),
        const SizedBox(height: 12),
        _RoleMutationCard(
          title: 'SHIFTOUT TO AUDIENCE FEED',
          subtitle: 'Impersonate Fan / Audience surface',
          targetRole: 'audience',
          onTap: () => authProvider.setActiveRole('audience'),
        ),
        const SizedBox(height: 28),
        Text(
          'RUNTIME TELEMETRY',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        _SystemMetricRow(context: context, label: 'Auth Provider', status: 'ONLINE'),
        _SystemMetricRow(context: context, label: 'Supabase Session', status: 'BOUND'),
        _SystemMetricRow(context: context, label: 'Role Scope', status: 'ROOT'),
        _SystemMetricRow(context: context, label: 'Launch Gate', status: 'ENABLED'),
      ],
    );
  }
}

class _RoleMutationCard extends StatelessWidget {
  const _RoleMutationCard({
    required this.title,
    required this.subtitle,
    required this.targetRole,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final String targetRole;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11)),
              const SizedBox(height: 8),
              Text('→ $targetRole', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.55), fontSize: 10, fontFamily: 'monospace')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemMetricRow extends StatelessWidget {
  const _SystemMetricRow({required this.context, required this.label, required this.status});
  final BuildContext context;
  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
          Text(
            status,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared chrome widgets ───────────────────────────────────────────────────
class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.label, required this.fg, required this.bg, required this.border});
  final String label;
  final Color fg, bg, border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _AdminUi.border),
          ),
          child: Text(label, style: const TextStyle(color: _AdminUi.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

class _PrimarySm extends StatelessWidget {
  const _PrimarySm({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: _AdminUi.cyan,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF07090F),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}


class _DangerSm extends StatelessWidget {
  const _DangerSm({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _AdminUi.rose.withValues(alpha: 0.55)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: _AdminUi.rose,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

