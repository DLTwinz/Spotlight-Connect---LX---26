import 'package:flutter/material.dart';
import 'package:spotlight_connect/database_service.dart';
import 'package:spotlight_connect/models/brand_attribution_summary_model.dart';
import 'package:spotlight_connect/models/creator_attribution_summary_model.dart';

// ==========================================
// SHARED UTILITIES & COMPONENTS FOR HUD LABELS
// ==========================================
class _TelemetryCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color accentColor;

  const _TelemetryCard({
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
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A1A1A)),
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
                  color: Colors.white.withValues(alpha: 0.4),
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
                style: const TextStyle(
                  color: Colors.white,
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
                      : Colors.redAccent,
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
    final Color accentColor =
        isTalent ? const Color(0xFF39FF14) : const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          isTalent ? 'TALENT ACTIVITY MATRIX' : 'BUSINESS ATTRIBUTION LOG',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor, size: 20),
            onPressed: () {},
          )
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
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF141414)),
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
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${index + 1}h ago',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.2),
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
                          color: Colors.white.withValues(alpha: 0.5),
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
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "REELS TELEMETRY EMBEDDED",
          style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2),
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
    final Color accentColor =
        isTalent ? const Color(0xFF39FF14) : const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          isTalent ? 'DISCOVER MISSIONS' : 'DISCOVER TALENT ECOSYSTEM',
          style: const TextStyle(
            color: Colors.white,
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
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1C1C1C)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.05),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
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
                          color: Colors.white,
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
                          color: Colors.white.withValues(alpha: 0.4),
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
                              foregroundColor: Colors.black,
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
                          )
                        ],
                      )
                    ],
                  ),
                )
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

  Color get _accentColor =>
      _isTalent ? const Color(0xFF39FF14) : const Color(0xFFD4AF37);

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
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _isTalent ? 'CREATOR OPERATIONS ENGINE' : 'BRAND IMPACT ENGINE',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _accentColor, size: 20),
            onPressed: _loadAttribution,
          )
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
      return Center(
        child: CircularProgressIndicator(color: _accentColor),
      );
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
                    title: 'Total Earnings',
                    value: _formatCurrency(_creatorSummary?.totalEarnings),
                    trend: 'CREATOR ATTRIBUTION LIVE',
                    icon: Icons.monetization_on_outlined,
                    accentColor: _accentColor,
                  ),
                  _TelemetryCard(
                    title: 'Pipeline Value',
                    value: _formatCurrency(_creatorSummary?.pipelineValue),
                    trend: 'SUMMARY RESOLVED',
                    icon: Icons.account_tree_outlined,
                    accentColor: _accentColor,
                  ),
                  _TelemetryCard(
                    title: 'Completion Rate',
                    value: _formatPercent(_creatorSummary?.completionRatePct),
                    trend: 'SYSTEM SECURE',
                    icon: Icons.gpp_good_outlined,
                    accentColor: _accentColor,
                  ),
                  _TelemetryCard(
                    title: 'Creator',
                    value: _creatorSummary?.creatorName ?? '--',
                    trend: _formatTimestamp(_creatorSummary?.summaryGeneratedAt),
                    icon: Icons.person_outline,
                    accentColor: _accentColor,
                  ),
                ]
              : [
                  _TelemetryCard(
                    title: 'Total Spend',
                    value: _formatCurrency(_brandSummary?.totalSpend),
                    trend: 'BRAND ATTRIBUTION LIVE',
                    icon: Icons.monetization_on_outlined,
                    accentColor: _accentColor,
                  ),
                  _TelemetryCard(
                    title: 'Avg Deal Value',
                    value: _formatCurrency(_brandSummary?.avgDealValue),
                    trend: 'SUMMARY RESOLVED',
                    icon: Icons.handshake_outlined,
                    accentColor: _accentColor,
                  ),
                  _TelemetryCard(
                    title: 'Completion Rate',
                    value: _formatPercent(_brandSummary?.completionRatePct),
                    trend: 'SYSTEM SECURE',
                    icon: Icons.gpp_good_outlined,
                    accentColor: _accentColor,
                  ),
                  _TelemetryCard(
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
            color: Colors.white.withValues(alpha: 0.3),
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
              color: const Color(0xFF060606),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF111111)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.waves,
                    color: _accentColor.withValues(alpha: 0.4), size: 36),
                const SizedBox(height: 12),
                Text(
                  _isTalent
                      ? 'CREATOR ATTRIBUTION SIGNALS LOCKED TO VERIFIED SUMMARY LAYER'
                      : 'BRAND ATTRIBUTION SIGNALS LOCKED TO VERIFIED SUMMARY LAYER',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        )
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
        color: const Color(0xFF060606),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF141414)),
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
              color: Colors.white,
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
              color: Colors.white.withValues(alpha: 0.45),
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
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "PIPELINE CONTRACTS ENCRYPTED",
          style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2),
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
    final bool isTalent = (role ?? 'talent').trim().toLowerCase() == 'talent';
    final Color accentColor =
        isTalent ? const Color(0xFF39FF14) : const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF111111),
                  child: Icon(
                    Icons.account_circle_outlined,
                    color: accentColor,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'CORE PROFILE ATTESTATION',
                style: TextStyle(
                  color: Colors.white,
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
                  color: const Color(0xFF0D0D0D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1A1A1A)),
                ),
                child: Column(
                  children: [
                    _buildIdentityRow('Ecosystem Identity Key', '0x71C...392A'),
                    const Divider(color: Color(0xFF1A1A1A), height: 24),
                    _buildIdentityRow('Routing Token Claim', 'Valid'),
                    const Divider(color: Color(0xFF1A1A1A), height: 24),
                    _buildIdentityRow(
                        'Database Protocol', 'Supabase Realtime RLS'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityRow(String label, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(
          status,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}