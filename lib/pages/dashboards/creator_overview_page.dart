import 'package:flutter/material.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';

class CreatorOverviewPage extends StatelessWidget {
  const CreatorOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1280;
    final isDesktop = width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 12, child: _CreatorHero()),
                SizedBox(width: 16),
                Expanded(flex: 6, child: _OverviewRightRail()),
              ],
            )
          else
            const Column(
              children: [
                _CreatorHero(),
                SizedBox(height: 16),
                _OverviewRightRail(),
              ],
            ),
          const SizedBox(height: 16),
          if (isDesktop)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _OpportunityPipeline()),
                SizedBox(width: 16),
                Expanded(flex: 5, child: _StudioWorkflow()),
                SizedBox(width: 16),
                Expanded(flex: 6, child: _RelationshipPreview()),
              ],
            )
          else
            const Column(
              children: [
                _OpportunityPipeline(),
                SizedBox(height: 16),
                _StudioWorkflow(),
                SizedBox(height: 16),
                _RelationshipPreview(),
              ],
            ),
          const SizedBox(height: 16),
          if (isDesktop)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: _PortfolioProof()),
                SizedBox(width: 16),
                Expanded(flex: 6, child: _ProgramsServices()),
                SizedBox(width: 16),
                Expanded(flex: 5, child: _EarningsPulse()),
              ],
            )
          else
            const Column(
              children: [
                _PortfolioProof(),
                SizedBox(height: 16),
                _ProgramsServices(),
                SizedBox(height: 16),
                _EarningsPulse(),
              ],
            ),
          const SizedBox(height: 16),
          const _CalendarPanel(),
        ],
      ),
    );
  }
}

class _CreatorHero extends StatelessWidget {
  const _CreatorHero();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 360,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/landing/hero_collage.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xF207090F),
                      Color(0xC907090F),
                      Color(0x3307090F),
                    ],
                    stops: [0, 0.52, 1],
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xD907090F), Colors.transparent],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Eyebrow(label: 'TODAY IN YOUR STUDIO'),
                    const Spacer(),
                    Text(
                      'Your Momentum,\nin Motion.',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: SpotlightTokens.textPrimary,
                        fontWeight: FontWeight.w900,
                        height: 0.98,
                        letterSpacing: -1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(
                      width: 340,
                      child: Text(
                        'Every connection. Every creation. Every move forward.',
                        style: TextStyle(
                          color: SpotlightTokens.textSecondary,
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _NextAction(
                      onTap: () => _showMessage(
                        context,
                        'Opening your opportunity workspace next.',
                      ),
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
}

class _OverviewRightRail extends StatelessWidget {
  const _OverviewRightRail();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _MomentumSummary(),
        SizedBox(height: 16),
        _SupporterPulse(),
        SizedBox(height: 16),
        _ActiveMission(),
      ],
    );
  }
}

class _MomentumSummary extends StatelessWidget {
  const _MomentumSummary();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            title: 'Momentum Summary',
            action: 'This week',
            showActionChevron: true,
          ),
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '82',
                style: TextStyle(
                  color: SpotlightTokens.textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
              SizedBox(width: 5),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '/100',
                  style: TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Spacer(),
              _MiniTrend(),
            ],
          ),
          const SizedBox(height: 14),
          const _MetricDivider(),
          const _MetricLine(
            icon: Icons.trending_up_rounded,
            label: 'Growth',
            value: '↑ 18%',
            valueColor: SpotlightTokens.success,
          ),
          const _MetricLine(
            icon: Icons.auto_graph_rounded,
            label: 'Engagement',
            value: '↑ 24%',
            valueColor: SpotlightTokens.success,
          ),
          const _MetricLine(
            icon: Icons.work_outline_rounded,
            label: 'Opportunities',
            value: '12',
          ),
          const _MetricLine(
            icon: Icons.people_outline_rounded,
            label: 'Relationships',
            value: '↑ 15',
            valueColor: SpotlightTokens.success,
          ),
        ],
      ),
    );
  }
}

class _SupporterPulse extends StatelessWidget {
  const _SupporterPulse();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Supporter Pulse', action: 'View all'),
          const SizedBox(height: 16),
          const _AvatarRow(),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _CompactStat(label: 'Top supporter', value: 'LENA J.'),
              ),
              Expanded(
                child: _CompactStat(label: 'Top engager', value: 'MARCUS K.'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _MetricDivider(),
          const _SupportLine(
            icon: Icons.favorite_rounded,
            label: 'Total support',
            value: '1.2K',
            growth: '↑ 21%',
          ),
          const _SupportLine(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Comments',
            value: '312',
            growth: '↑ 18%',
          ),
          const _SupportLine(
            icon: Icons.ios_share_rounded,
            label: 'Shares',
            value: '189',
            growth: '↑ 14%',
          ),
        ],
      ),
    );
  }
}

class _ActiveMission extends StatelessWidget {
  const _ActiveMission();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      accent: SpotlightTokens.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Active Mission'),
          const SizedBox(height: 12),
          const Text(
            'Drop the visuals for “Midnight Drive”',
            style: TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Text(
                'Due in 6 days',
                style: TextStyle(
                  color: SpotlightTokens.textSecondary,
                  fontSize: 11,
                ),
              ),
              Spacer(),
              Text(
                '60%',
                style: TextStyle(
                  color: SpotlightTokens.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _ProgressLine(value: 0.60),
          const SizedBox(height: 14),
          SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: () =>
                  _showMessage(context, 'Opening Studio Workflow next.'),
              child: const Text('View mission'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpportunityPipeline extends StatelessWidget {
  const _OpportunityPipeline();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Opportunity Pipeline', action: 'View all'),
          const SizedBox(height: 14),
          const _OpportunityRow(
            mark: 'N',
            markColor: SpotlightTokens.magenta,
            title: 'Brand Partnership',
            subtitle: 'Lunar Headphones',
            status: 'Proposal',
            priority: 'High',
          ),
          const SizedBox(height: 9),
          const _OpportunityRow(
            mark: 'S',
            markColor: SpotlightTokens.rose,
            title: 'Sync Opportunity',
            subtitle: 'Netflix · Indie Feature',
            status: 'Intro call',
            priority: 'Medium',
          ),
          const SizedBox(height: 9),
          const _OpportunityRow(
            mark: '★',
            markColor: SpotlightTokens.warning,
            title: 'Festival Performance',
            subtitle: 'Echo Park Festival',
            status: 'Invited',
            priority: 'High',
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  _showMessage(context, 'Opening Opportunities next.'),
              child: const Text('Open opportunities'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioWorkflow extends StatelessWidget {
  const _StudioWorkflow();

  @override
  Widget build(BuildContext context) {
    const steps = <_WorkflowStepData>[
      _WorkflowStepData('1', 'Ideate', 'Midnight Drive Visual Campaign', true),
      _WorkflowStepData('2', 'Create', 'Music video + photo assets', true),
      _WorkflowStepData('3', 'Refine', 'Mix & rough cut', false),
      _WorkflowStepData('4', 'Release', 'Plan & distribute', false),
    ];

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Studio Workflow', action: 'See workflow'),
          const SizedBox(height: 14),
          for (var index = 0; index < steps.length; index++) ...[
            _WorkflowStep(data: steps[index]),
            if (index < steps.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _RelationshipPreview extends StatelessWidget {
  const _RelationshipPreview();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            title: 'Relationship Gravity Map',
            action: 'Preview',
          ),
          const SizedBox(height: 12),
          Container(
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: RadialGradient(
                colors: [
                  SpotlightTokens.cyan.withValues(alpha: 0.20),
                  SpotlightTokens.purple.withValues(alpha: 0.11),
                  SpotlightTokens.bgElevated,
                ],
              ),
              border: Border.all(color: SpotlightTokens.border),
            ),
            child: const Stack(
              children: [
                Positioned(
                  left: 24,
                  top: 26,
                  child: _OrbitAvatar(
                    initials: 'L',
                    color: SpotlightTokens.cyan,
                  ),
                ),
                Positioned(
                  right: 32,
                  top: 22,
                  child: _OrbitAvatar(
                    initials: 'M',
                    color: SpotlightTokens.magenta,
                  ),
                ),
                Positioned(
                  left: 42,
                  bottom: 22,
                  child: _OrbitAvatar(
                    initials: 'K',
                    color: SpotlightTokens.purple,
                  ),
                ),
                Positioned(
                  right: 54,
                  bottom: 24,
                  child: _OrbitAvatar(
                    initials: 'R',
                    color: SpotlightTokens.cyanSoft,
                  ),
                ),
                Center(child: _IdentityNode()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _NetworkMetric(label: 'Collaborators', value: '23'),
              SizedBox(width: 20),
              _NetworkMetric(label: 'Opportunities', value: '14'),
              SizedBox(width: 20),
              _NetworkMetric(label: 'Superfans', value: '1.2K'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  _showMessage(context, 'Opening Gravity Map next.'),
              child: const Text('Explore relationships'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioProof extends StatelessWidget {
  const _PortfolioProof();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Portfolio & Proof', action: 'View all'),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: _WorkTile(
                  title: 'Midnight Drive',
                  subtitle: 'Music Video',
                  color: SpotlightTokens.cyan,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _WorkTile(
                  title: 'Electric Heart',
                  subtitle: 'Single',
                  color: SpotlightTokens.magenta,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _WorkTile(
                  title: 'Live at Echo',
                  subtitle: 'Performance',
                  color: SpotlightTokens.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Your proof profile is ready to strengthen your next opportunity.',
            style: TextStyle(
              color: SpotlightTokens.textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramsServices extends StatelessWidget {
  const _ProgramsServices();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Programs & Services', action: 'View all'),
          const SizedBox(height: 12),
          const _ProgramLine(
            icon: Icons.bolt_rounded,
            title: 'Creative Accelerator',
            detail: '6 weeks left',
            status: 'Active',
            statusColor: SpotlightTokens.success,
          ),
          const SizedBox(height: 10),
          const _ProgramLine(
            icon: Icons.sync_rounded,
            title: 'Sync Lab',
            detail: 'Application review',
            status: 'In review',
            statusColor: SpotlightTokens.cyan,
          ),
          const SizedBox(height: 10),
          const _ProgramLine(
            icon: Icons.workspace_premium_outlined,
            title: 'Brand Partners Circle',
            detail: 'Member',
            status: 'Active',
            statusColor: SpotlightTokens.success,
          ),
          const SizedBox(height: 10),
          const _ProgramLine(
            icon: Icons.school_outlined,
            title: 'Masterclasses',
            detail: 'Next: May 24',
            status: 'Registered',
            statusColor: SpotlightTokens.magenta,
          ),
        ],
      ),
    );
  }
}

class _EarningsPulse extends StatelessWidget {
  const _EarningsPulse();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            title: 'Earnings & Attribution',
            action: 'View all',
          ),
          const SizedBox(height: 16),
          const Text(
            '\$7,842',
            style: TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'This week  ·  ↑ 16%',
            style: TextStyle(
              color: SpotlightTokens.success,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const _Bars(),
          const SizedBox(height: 16),
          const _EarningsRow(label: 'Top source', value: 'Streaming'),
          const SizedBox(height: 8),
          const _EarningsRow(
            label: 'Top opportunity',
            value: 'Brand partnership',
          ),
          const SizedBox(height: 8),
          const _EarningsRow(label: 'Top release', value: 'Midnight Drive'),
        ],
      ),
    );
  }
}

class _CalendarPanel extends StatelessWidget {
  const _CalendarPanel();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            color: SpotlightTokens.cyan,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PanelHeader(
                  title: 'Upcoming Calendar',
                  action: 'View calendar',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  children: const [
                    _CalendarItem(
                      date: 'MAY 20',
                      title: 'Intro call — Lunar Headphones',
                      time: '10:00 AM PT',
                    ),
                    _CalendarItem(
                      date: 'MAY 21',
                      title: 'Studio session',
                      time: '2:00 PM PT',
                    ),
                    _CalendarItem(
                      date: 'MAY 23',
                      title: 'Content drop — Teaser cut',
                      time: '11:00 AM PT',
                    ),
                    _CalendarItem(
                      date: 'MAY 25',
                      title: 'Echo Park Festival',
                      time: 'Los Angeles, CA',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.accent,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent?.withValues(alpha: 0.26) ?? SpotlightTokens.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.title,
    this.action,
    this.showActionChevron = false,
  });

  final String title;
  final String? action;
  final bool showActionChevron;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: SpotlightTokens.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (action != null) ...[
          Text(
            action!,
            style: const TextStyle(
              color: SpotlightTokens.cyan,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (showActionChevron) ...[
            const SizedBox(width: 3),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: SpotlightTokens.textSecondary,
              size: 15,
            ),
          ],
        ],
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: SpotlightTokens.cyan,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.25,
      ),
    );
  }
}

class _NextAction extends StatelessWidget {
  const _NextAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 370,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SpotlightTokens.bgElevated.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: SpotlightTokens.purple.withValues(alpha: 0.34),
          ),
        ),
        child: const Row(
          children: [
            _ActionOrb(),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEXT BEST ACTION',
                    style: TextStyle(
                      color: SpotlightTokens.cyan,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Review invitation to collaborate',
                    style: TextStyle(
                      color: SpotlightTokens.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'From Aria Lee on “Midnight Drive”',
                    style: TextStyle(
                      color: SpotlightTokens.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: SpotlightTokens.cyan,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionOrb extends StatelessWidget {
  const _ActionOrb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [SpotlightTokens.purple, SpotlightTokens.magenta],
        ),
        boxShadow: [
          BoxShadow(
            color: SpotlightTokens.magenta.withValues(alpha: 0.34),
            blurRadius: 16,
          ),
        ],
      ),
      child: const Icon(
        Icons.group_add_outlined,
        size: 19,
        color: SpotlightTokens.textPrimary,
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: SpotlightTokens.border);
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = SpotlightTokens.textPrimary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: SpotlightTokens.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: SpotlightTokens.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTrend extends StatelessWidget {
  const _MiniTrend();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 38,
      child: CustomPaint(painter: _MiniTrendPainter()),
    );
  }
}

class _MiniTrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cyan = Paint()
      ..color = SpotlightTokens.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final purple = Paint()
      ..color = SpotlightTokens.magenta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final first = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.22,
        size.width * 0.38,
        size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.54,
        size.height * 0.9,
        size.width * 0.68,
        size.height * 0.38,
      );

    final second = Path()
      ..moveTo(size.width * 0.67, size.height * 0.38)
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.05,
        size.width,
        size.height * 0.28,
      );

    canvas.drawPath(first, cyan);
    canvas.drawPath(second, purple);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AvatarRow extends StatelessWidget {
  const _AvatarRow();

  @override
  Widget build(BuildContext context) {
    const colors = [
      SpotlightTokens.cyan,
      SpotlightTokens.magenta,
      SpotlightTokens.purple,
      SpotlightTokens.rose,
      SpotlightTokens.cyanSoft,
    ];

    return Row(
      children: [
        for (var i = 0; i < colors.length; i++)
          Align(
            widthFactor: i == 0 ? 1 : 0.66,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: SpotlightTokens.bgElevated,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: colors[i].withValues(alpha: 0.88),
                child: Text(
                  String.fromCharCode(65 + i),
                  style: const TextStyle(
                    color: SpotlightTokens.textOnAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(width: 12),
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: SpotlightTokens.border),
          ),
          child: const Text(
            '+24',
            style: TextStyle(
              color: SpotlightTokens.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactStat extends StatelessWidget {
  const _CompactStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: SpotlightTokens.textMuted,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.75,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: SpotlightTokens.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SupportLine extends StatelessWidget {
  const _SupportLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.growth,
  });

  final IconData icon;
  final String label;
  final String value;
  final String growth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: SpotlightTokens.magenta),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: SpotlightTokens.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            growth,
            style: const TextStyle(
              color: SpotlightTokens.success,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 6,
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: SpotlightTokens.border,
          valueColor: const AlwaysStoppedAnimation(SpotlightTokens.cyan),
        ),
      ),
    );
  }
}

class _OpportunityRow extends StatelessWidget {
  const _OpportunityRow({
    required this.mark,
    required this.markColor,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.priority,
  });

  final String mark;
  final Color markColor;
  final String title;
  final String subtitle;
  final String status;
  final String priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgElevated.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: SpotlightTokens.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 33,
            height: 33,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: markColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: markColor.withValues(alpha: 0.32)),
            ),
            child: Text(
              mark,
              style: TextStyle(
                color: markColor,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SpotlightTokens.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                status,
                style: const TextStyle(
                  color: SpotlightTokens.textSecondary,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                priority,
                style: TextStyle(
                  color: priority == 'High'
                      ? SpotlightTokens.rose
                      : SpotlightTokens.warning,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkflowStepData {
  const _WorkflowStepData(this.number, this.title, this.subtitle, this.active);

  final String number;
  final String title;
  final String subtitle;
  final bool active;
}

class _WorkflowStep extends StatelessWidget {
  const _WorkflowStep({required this.data});

  final _WorkflowStepData data;

  @override
  Widget build(BuildContext context) {
    final color = data.active
        ? SpotlightTokens.cyan
        : SpotlightTokens.textMuted.withValues(alpha: 0.75);

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: data.active
                ? SpotlightTokens.cyan.withValues(alpha: 0.14)
                : Colors.transparent,
            border: Border.all(color: color),
          ),
          child: Text(
            data.number,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: TextStyle(
                  color: SpotlightTokens.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SpotlightTokens.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Icon(
          data.active ? Icons.check_rounded : Icons.arrow_forward_ios_rounded,
          color: color,
          size: data.active ? 18 : 12,
        ),
      ],
    );
  }
}

class _OrbitAvatar extends StatelessWidget {
  const _OrbitAvatar({required this.initials, required this.color});

  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31,
      height: 31,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.24), blurRadius: 10),
        ],
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _IdentityNode extends StatelessWidget {
  const _IdentityNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [SpotlightTokens.cyan, SpotlightTokens.magenta],
        ),
        border: Border.all(color: SpotlightTokens.cyanSoft, width: 2),
        boxShadow: [
          BoxShadow(
            color: SpotlightTokens.cyan.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: const Text(
        'AJ',
        style: TextStyle(
          color: SpotlightTokens.textOnAccent,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _NetworkMetric extends StatelessWidget {
  const _NetworkMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SpotlightTokens.textMuted,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkTile extends StatelessWidget {
  const _WorkTile({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.72),
                SpotlightTokens.bgElevated,
                SpotlightTokens.bgPrimary,
              ],
            ),
            border: Border.all(color: color.withValues(alpha: 0.24)),
          ),
          child: Center(
            child: Icon(
              Icons.play_circle_outline_rounded,
              color: SpotlightTokens.textPrimary.withValues(alpha: 0.9),
              size: 29,
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: SpotlightTokens.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: SpotlightTokens.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _ProgramLine extends StatelessWidget {
  const _ProgramLine({
    required this.icon,
    required this.title,
    required this.detail,
    required this.status,
    required this.statusColor,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: statusColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: SpotlightTokens.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(
                  color: SpotlightTokens.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars();

  @override
  Widget build(BuildContext context) {
    const heights = [28.0, 43.0, 34.0, 56.0, 38.0, 49.0, 64.0];

    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < heights.length; i++) ...[
            Expanded(
              child: Container(
                height: heights[i],
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: i.isEven
                        ? [SpotlightTokens.cyan, SpotlightTokens.cyanSoft]
                        : [SpotlightTokens.magenta, SpotlightTokens.purple],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EarningsRow extends StatelessWidget {
  const _EarningsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: SpotlightTokens.textMuted,
            fontSize: 10,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: SpotlightTokens.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CalendarItem extends StatelessWidget {
  const _CalendarItem({
    required this.date,
    required this.title,
    required this.time,
  });

  final String date;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Text(
              date,
              style: const TextStyle(
                color: SpotlightTokens.cyan,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SpotlightTokens.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 10,
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

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
