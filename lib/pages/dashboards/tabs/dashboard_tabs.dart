import 'package:flutter/material.dart';
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
<<<<<<< HEAD
=======
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
class FeedTab extends StatelessWidget {
  final String? role;
  const FeedTab({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    final bool isTalent = (role ?? 'talent').trim().toLowerCase() == 'talent';
    final Color accentColor = context.roleAccent(role);

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
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(role),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.rolePanelBorder(role)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: accentColor.withValues(alpha: 0.1),
                  radius: 18,
                  child: Icon(
                    isTalent ? Icons.bolt : Icons.analytics_outlined,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isTalent
                                ? 'CONVERSION CAPTURED'
                                : 'PROMPT IMPACT METRIC',
                            style: TextStyle(
                              color: context.roleTextPrimary(role),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${index + 1}h ago',
                            style: TextStyle(
                              color: context.roleTextSubtle(role)
                                  .withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isTalent
                            ? 'Attribution node #8902 generated safe conversion signature via TikTok link-out.'
                            : 'Campaign contract Alpha-Omicron verified proof-of-impact payload from Node 4.',
                        style: TextStyle(
                          color: context.roleTextMuted(role),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      body: Center(
        child: Text(
          'REELS TELEMETRY EMBEDDED',
          style: TextStyle(
            color: context.roleTextSubtle(role),
            fontSize: 11,
            letterSpacing: 2,
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
    final bool isTalent = (role ?? 'talent').trim().toLowerCase() == 'talent';
    final Color accentColor = context.roleAccent(role);

    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      appBar: AppBar(
        backgroundColor: context.roleShellBackground(role),
        title: Text(
          isTalent ? 'DISCOVER MISSIONS' : 'DISCOVER TALENT ECOSYSTEM',
          style: TextStyle(
            color: context.roleTextPrimary(role),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(role),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.rolePanelBorder(role)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isTalent ? Icons.campaign : Icons.token_outlined,
                      color: accentColor,
                      size: 40,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTalent
                            ? 'SQUADRON AUDIO // IMPACT MISSION'
                            : 'CREATOR NODE #${4022 + index}',
                        style: TextStyle(
                          color: context.roleTextPrimary(role),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isTalent
                            ? 'Requires verified proof of conversions. Vanity metrics ignored.'
                            : 'Specialized in tech and infrastructure integration. Direct ROI focus.',
                        style: TextStyle(
                          color: context.roleTextFaint(role),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isTalent
                                ? 'ESCROW BUDGET: \$2,400'
                                : 'VERIFIED IMPACT: 94.2%',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: context.roleOnAccent(role),
                              minimumSize: const Size(80, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {},
                            child: Text(isTalent ? 'ENGAGE' : 'INSPECT'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(),
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
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
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(widget.role),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.rolePanelBorder(widget.role)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
        ),
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
class OpportunitiesTab extends StatelessWidget {
  final String? role;
  const OpportunitiesTab({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      body: Center(
        child: Text(
          'PIPELINE CONTRACTS ENCRYPTED',
          style: TextStyle(
            color: context.roleTextSubtle(role),
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. PROFILE TAB (IDENTITY DEFI MATRIX)
// ==========================================
class ProfileTab extends StatelessWidget {
  final String? role;
  const ProfileTab({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    final Color accentColor = context.roleAccent(role);

    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: context.rolePanelBackground(role),
                  child: Icon(
                    Icons.account_circle_outlined,
                    color: accentColor,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'CORE PROFILE ATTESTATION',
                style: TextStyle(
                  color: context.roleTextPrimary(role),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ROLE INSTANCE: ${role?.toUpperCase() ?? 'TALENT'}',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.rolePanelBackground(role),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.rolePanelBorder(role)),
                ),
                child: Column(
                  children: [
                    _buildIdentityRow(
                      context,
                      role,
                      'Ecosystem Identity Key',
                      '0x71C...392A',
                    ),
                    Divider(color: context.rolePanelBorder(role), height: 24),
                    _buildIdentityRow(
                      context,
                      role,
                      'Routing Token Claim',
                      'Valid',
                    ),
                    Divider(color: context.rolePanelBorder(role), height: 24),
                    _buildIdentityRow(
                      context,
                      role,
                      'Database Protocol',
                      'Supabase Realtime RLS',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          style: TextStyle(
            color: context.roleTextFaint(role),
            fontSize: 12,
          ),
        ),
        Text(
          status,
          style: TextStyle(
            color: context.roleTextPrimary(role),
            fontSize: 12,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
<<<<<<< HEAD
}        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
>>>>>>> 5a8a10a3e7087f86eb0fa787f5f57bd10a4fe526
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
class FeedTab extends StatelessWidget {
  final String? role;
  const FeedTab({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    final bool isTalent = (role ?? 'talent').trim().toLowerCase() == 'talent';
    final Color accentColor = context.roleAccent(role);

    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      appBar: AppBar(
        backgroundColor: context.roleShellBackground(role),
        title: Text(
          isTalent ? 'TALENT ACTIVITY MATRIX' : 'BUSINESS ATTRIBUTION LOG',
          style: const TextStyle(
            color: context.roleTextPrimary(role),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(role),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.rolePanelBorder(role)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: accentColor.withValues(alpha: 0.1),
                  radius: 18,
                  child: Icon(
                    isTalent ? Icons.bolt : Icons.analytics_outlined,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isTalent
                                ? 'CONVERSION CAPTURED'
                                : 'PROMPT IMPACT METRIC',
                            style: const TextStyle(
                              color: context.roleTextPrimary(role),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${index + 1}h ago',
                            style: TextStyle(
                              color: context.roleTextSubtle(role).withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isTalent
                            ? 'Attribution node #8902 generated safe conversion signature via TikTok link-out.'
                            : 'Campaign contract Alpha-Omicron verified proof-of-impact payload from Node 4.',
                        style: TextStyle(
                          color: context.roleTextMuted(role),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      body: Center(
        child: Text(
          "REELS TELEMETRY EMBEDDED",
          style: TextStyle(
            color: context.roleTextSubtle(role),
            fontSize: 11,
            letterSpacing: 2,
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
    final bool isTalent = (role ?? 'talent').trim().toLowerCase() == 'talent';
    final Color accentColor = context.roleAccent(role);

    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      appBar: AppBar(
        backgroundColor: context.roleShellBackground(role),
        title: Text(
          isTalent ? 'DISCOVER MISSIONS' : 'DISCOVER TALENT ECOSYSTEM',
          style: const TextStyle(
            color: context.roleTextPrimary(role),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(role),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.rolePanelBorder(role)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isTalent ? Icons.campaign : Icons.token_outlined,
                      color: accentColor,
                      size: 40,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTalent
                            ? 'SQUADRON AUDIO // IMPACT MISSION'
                            : 'CREATOR NODE #${4022 + index}',
                        style: const TextStyle(
                          color: context.roleTextPrimary(role),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isTalent
                            ? 'Requires verified proof of conversions. Vanity metrics ignored.'
                            : 'Specialized in tech and infrastructure integration. Direct ROI focus.',
                        style: TextStyle(
                          color: context.roleTextFaint(role),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isTalent
                                ? 'ESCROW BUDGET: \$2,400'
                                : 'VERIFIED IMPACT: 94.2%',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: context.roleOnAccent(role),
                              minimumSize: const Size(80, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {},
                            child: Text(isTalent ? 'ENGAGE' : 'INSPECT'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
          style: const TextStyle(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
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
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.rolePanelBackground(widget.role),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.rolePanelBorder(widget.role)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
        ),
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
            style: const TextStyle(
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
class OpportunitiesTab extends StatelessWidget {
  final String? role;
  const OpportunitiesTab({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      body: Center(
        child: Text(
          "PIPELINE CONTRACTS ENCRYPTED",
          style: TextStyle(
            color: context.roleTextSubtle(role),
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. PROFILE TAB (IDENTITY DEFI MATRIX)
// ==========================================
class ProfileTab extends StatelessWidget {
  final String? role;
  const ProfileTab({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    final Color accentColor = context.roleAccent(role);

    return Scaffold(
      backgroundColor: context.roleShellBackground(role),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: context.rolePanelBackground(role),
                  child: Icon(
                    Icons.account_circle_outlined,
                    color: accentColor,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'CORE PROFILE ATTESTATION',
                style: TextStyle(
                  color: context.roleTextPrimary(role),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ROLE INSTANCE: ${role?.toUpperCase() ?? 'TALENT'}',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.rolePanelBackground(role),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.rolePanelBorder(role)),
                ),
                child: Column(
                  children: [
                    _buildIdentityRow(context, role, 'Ecosystem Identity Key', '0x71C...392A'),
                    Divider(color: context.rolePanelBorder(role), height: 24),
                    _buildIdentityRow(context, role, 'Routing Token Claim', 'Valid'),
                    Divider(color: context.rolePanelBorder(role), height: 24),
                    _buildIdentityRow(
                      context,
                      role,
                      'Database Protocol',
                      'Supabase Realtime RLS',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityRow(BuildContext context, String? role, String label, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: context.roleTextFaint(role), fontSize: 12),
        ),
        Text(
          status,
          style: TextStyle(
            color: context.roleTextPrimary(role),
            fontSize: 12,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
=======
>>>>>>> ddc2e22e2384e0aeffeb207456d79041fcc6f937
}
