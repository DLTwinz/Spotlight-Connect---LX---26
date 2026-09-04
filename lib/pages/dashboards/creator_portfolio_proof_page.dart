import 'package:flutter/material.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';

class CreatorPortfolioProofPage extends StatelessWidget {
  const CreatorPortfolioProofPage({super.key});

  void _showPlanningMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1040;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PortfolioHero(
            onUpdate: () => _showPlanningMessage(
              context,
              'Portfolio editing will be connected in a later implementation step.',
            ),
          ),
          const SizedBox(height: 16),
          if (isWide)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 11, child: _PortfolioMainCanvas()),
                SizedBox(width: 16),
                Expanded(flex: 7, child: _PortfolioActionRail()),
              ],
            )
          else
            const Column(
              children: [
                _PortfolioMainCanvas(),
                SizedBox(height: 16),
                _PortfolioActionRail(),
              ],
            ),
        ],
      ),
    );
  }
}

class _PortfolioHero extends StatelessWidget {
  const _PortfolioHero({required this.onUpdate});

  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 18,
        spacing: 18,
        children: [
          const SizedBox(
            width: 620,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Eyebrow(text: 'PORTFOLIO & PROOF'),
                SizedBox(height: 10),
                Text(
                  'Make your proof easy to trust and impossible to miss.',
                  style: TextStyle(
                    color: SpotlightTokens.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'A sample readiness workspace for shaping the work, credits, and context that support your next opportunity.',
                  style: TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onUpdate,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Update portfolio'),
          ),
        ],
      ),
    );
  }
}

class _PortfolioMainCanvas extends StatelessWidget {
  const _PortfolioMainCanvas();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReadinessPanel(),
        SizedBox(height: 16),
        _SelectedWorkPanel(),
        SizedBox(height: 16),
        _ProofLedgerPanel(),
        SizedBox(height: 16),
        _FocusTagsPanel(),
      ],
    );
  }
}

class _ReadinessPanel extends StatelessWidget {
  const _ReadinessPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Portfolio readiness',
            trailing: _StatusChip(label: 'SAMPLE', color: SpotlightTokens.cyan),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '78%',
                style: TextStyle(
                  color: SpotlightTokens.textPrimary,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Complete across identity, featured work, and proof context.',
                  style: const TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              value: 0.78,
              minHeight: 8,
              backgroundColor: SpotlightTokens.bgElevated,
              valueColor: AlwaysStoppedAnimation<Color>(SpotlightTokens.cyan),
            ),
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: 'Identity ready',
                color: SpotlightTokens.success,
              ),
              _StatusChip(
                label: '4 featured items',
                color: SpotlightTokens.cyan,
              ),
              _StatusChip(
                label: '1 refresh due',
                color: SpotlightTokens.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectedWorkPanel extends StatelessWidget {
  const _SelectedWorkPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Selected work',
            subtitle: 'Sample proof assets arranged for opportunity review.',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 560;
              final cards = const [
                _WorkCard(
                  type: 'CASE STUDY',
                  title: 'Campaign concept and direction',
                  detail: 'Sample asset · context and outcome summary needed',
                  icon: Icons.auto_stories_outlined,
                  accent: SpotlightTokens.cyan,
                ),
                _WorkCard(
                  type: 'FEATURED REEL',
                  title: 'Performance and audience moment',
                  detail: 'Sample asset · add platform link and credit',
                  icon: Icons.play_circle_outline_rounded,
                  accent: SpotlightTokens.magenta,
                ),
                _WorkCard(
                  type: 'COLLABORATION',
                  title: 'Cross-disciplinary production',
                  detail: 'Sample asset · verify contributor attribution',
                  icon: Icons.groups_outlined,
                  accent: SpotlightTokens.purple,
                ),
              ];
              if (isCompact) {
                return Column(
                  children: [
                    _WorkCardView(card: cards[0]),
                    SizedBox(height: 10),
                    _WorkCardView(card: cards[1]),
                    SizedBox(height: 10),
                    _WorkCardView(card: cards[2]),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _WorkCardView(card: cards[0])),
                  SizedBox(width: 10),
                  Expanded(child: _WorkCardView(card: cards[1])),
                  SizedBox(width: 10),
                  Expanded(child: _WorkCardView(card: cards[2])),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProofLedgerPanel extends StatelessWidget {
  const _ProofLedgerPanel();

  @override
  Widget build(BuildContext context) {
    const rows = [
      _ProofRowData(
        title: 'Campaign direction deck',
        detail: 'Sample portfolio asset · Creative direction',
        status: 'VERIFIED',
        color: SpotlightTokens.success,
        icon: Icons.verified_outlined,
      ),
      _ProofRowData(
        title: 'Live performance reel',
        detail: 'Sample portfolio asset · Add usage context',
        status: 'PENDING',
        color: SpotlightTokens.warning,
        icon: Icons.schedule_outlined,
      ),
      _ProofRowData(
        title: 'Collaborative production credit',
        detail: 'Sample portfolio asset · Refresh recency and outcome',
        status: 'NEEDS REFRESH',
        color: SpotlightTokens.rose,
        icon: Icons.update_rounded,
      ),
    ];

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Proof ledger',
            subtitle:
                'Status is sample-only until portfolio verification is connected.',
          ),
          const SizedBox(height: 8),
          ...rows.map((row) => _ProofLedgerRow(data: row)),
        ],
      ),
    );
  }
}

class _FocusTagsPanel extends StatelessWidget {
  const _FocusTagsPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            title: 'Positioning signals',
            subtitle:
                'Sample tags to make your target work legible at a glance.',
          ),
          SizedBox(height: 14),
          _Eyebrow(text: 'CAPABILITIES'),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(label: 'Creative direction'),
              _Tag(label: 'Performance'),
              _Tag(label: 'Storytelling'),
              _Tag(label: 'Community activation'),
            ],
          ),
          SizedBox(height: 16),
          _Eyebrow(text: 'TARGET WORK'),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(label: 'Brand campaigns'),
              _Tag(label: 'Live experiences'),
              _Tag(label: 'Creative partnerships'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PortfolioActionRail extends StatelessWidget {
  const _PortfolioActionRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelTitle(
                title: 'Next best action',
                subtitle: 'Sample recommendation',
              ),
              SizedBox(height: 14),
              Text(
                'Add a concise outcome and contribution credit to your featured campaign asset.',
                style: TextStyle(
                  color: SpotlightTokens.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'That is the highest-leverage gap before you send your next opportunity application.',
                style: TextStyle(
                  color: SpotlightTokens.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelTitle(
                title: 'Connected platforms',
                subtitle: 'Planning state',
              ),
              SizedBox(height: 8),
              _ConnectionRow(
                icon: Icons.video_library_outlined,
                label: 'Media channel',
                value: 'Not connected',
              ),
              _ConnectionRow(
                icon: Icons.public_outlined,
                label: 'Professional profile',
                value: 'Not connected',
              ),
              _ConnectionRow(
                icon: Icons.link_outlined,
                label: 'Portfolio link',
                value: 'Not connected',
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelTitle(
                title: 'Portfolio gaps',
                subtitle: 'Sample readiness review',
              ),
              SizedBox(height: 10),
              _GapRow(
                icon: Icons.assignment_late_outlined,
                text: 'Add context to one featured asset',
              ),
              _GapRow(
                icon: Icons.person_search_outlined,
                text: 'Verify one collaboration credit',
              ),
              _GapRow(
                icon: Icons.schedule_outlined,
                text: 'Replace one stale work sample',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: SpotlightTokens.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: SpotlightTokens.cyan,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.25,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: SpotlightTokens.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WorkCard {
  const _WorkCard({
    required this.type,
    required this.title,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final String type;
  final String title;
  final String detail;
  final IconData icon;
  final Color accent;
}

class _WorkCardView extends StatelessWidget {
  const _WorkCardView({required this.card});

  final _WorkCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 176,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(card.icon, color: card.accent, size: 26),
          const Spacer(),
          Text(
            card.type,
            style: TextStyle(
              color: card.accent,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.95,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SpotlightTokens.textSecondary,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofRowData {
  const _ProofRowData({
    required this.title,
    required this.detail,
    required this.status,
    required this.color,
    required this.icon,
  });

  final String title;
  final String detail;
  final String status;
  final Color color;
  final IconData icon;
}

class _ProofLedgerRow extends StatelessWidget {
  const _ProofLedgerRow({required this.data});

  final _ProofRowData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SpotlightTokens.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: SpotlightTokens.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.detail,
                  style: const TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusChip(label: data.status, color: data.color),
        ],
      ),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: SpotlightTokens.textSecondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: SpotlightTokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: SpotlightTokens.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _GapRow extends StatelessWidget {
  const _GapRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: SpotlightTokens.warning, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: SpotlightTokens.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
