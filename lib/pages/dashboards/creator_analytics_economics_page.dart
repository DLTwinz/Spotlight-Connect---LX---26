import 'package:flutter/material.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';

class CreatorAnalyticsEconomicsPage extends StatelessWidget {
  const CreatorAnalyticsEconomicsPage({super.key});

  void _message(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Reporting connections will be configured in a later implementation step.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1040;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Hero(onReview: () => _message(context)),
          const SizedBox(height: 16),
          if (wide)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 11, child: _MainCanvas()),
                SizedBox(width: 16),
                Expanded(flex: 7, child: _ActionRail()),
              ],
            )
          else
            const Column(
              children: [_MainCanvas(), SizedBox(height: 16), _ActionRail()],
            ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onReview});

  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 18,
        runSpacing: 18,
        children: [
          const SizedBox(
            width: 620,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Eyebrow('ANALYTICS & ECONOMICS'),
                SizedBox(height: 10),
                Text(
                  'Understand the levers behind sustainable work.',
                  style: TextStyle(
                    color: SpotlightTokens.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Planning-only signals for earning readiness, opportunity flow, and the next action worth taking.',
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
            onPressed: onReview,
            icon: const Icon(Icons.insights_outlined),
            label: const Text('Review performance'),
          ),
        ],
      ),
    );
  }
}

class _MainCanvas extends StatelessWidget {
  const _MainCanvas();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Metrics(),
        SizedBox(height: 16),
        _PulsePanel(),
        SizedBox(height: 16),
        _ContributionPanel(),
        SizedBox(height: 16),
        _MovementPanel(),
      ],
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        const cards = [
          _Metric(
            label: 'SAMPLE REPORTED EARNINGS',
            value: '—',
            detail: 'No verified payout source connected.',
            icon: Icons.account_balance_wallet_outlined,
            color: SpotlightTokens.cyan,
          ),
          _Metric(
            label: 'ESTIMATED PIPELINE',
            value: '3 paths',
            detail: 'Planning-only opportunity conversations.',
            icon: Icons.account_tree_outlined,
            color: SpotlightTokens.magenta,
          ),
          _Metric(
            label: 'SAMPLE RETENTION SIGNAL',
            value: 'Rising',
            detail: 'Fixture-based returning attention trend.',
            icon: Icons.favorite_outline_rounded,
            color: SpotlightTokens.success,
          ),
        ];

        if (compact) {
          return Column(
            children: [
              _MetricCard(metric: cards[0]),
              const SizedBox(height: 10),
              _MetricCard(metric: cards[1]),
              const SizedBox(height: 10),
              _MetricCard(metric: cards[2]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _MetricCard(metric: cards[0])),
            const SizedBox(width: 10),
            Expanded(child: _MetricCard(metric: cards[1])),
            const SizedBox(width: 10),
            Expanded(child: _MetricCard(metric: cards[2])),
          ],
        );
      },
    );
  }
}

class _Metric {
  const _Metric({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(metric.icon, color: metric.color, size: 23),
          const Spacer(),
          Text(
            metric.label,
            style: TextStyle(
              color: metric.color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            metric.value,
            style: const TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SpotlightTokens.textSecondary,
              fontSize: 11,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsePanel extends StatelessWidget {
  const _PulsePanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Economic pulse',
            subtitle:
                'Planning view — fixture signals, not settled financial data.',
            trailing: _Status(
              label: 'PLANNING VIEW',
              color: SpotlightTokens.cyan,
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 184, child: _PulseChart()),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _Legend(color: SpotlightTokens.cyan, label: 'Sample activity'),
              _Legend(
                color: SpotlightTokens.magenta,
                label: 'Estimated opportunity flow',
              ),
              _Legend(
                color: SpotlightTokens.warning,
                label: 'Planning checkpoint',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseChart extends StatelessWidget {
  const _PulseChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PulsePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _PulsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = SpotlightTokens.border
      ..strokeWidth = 1;

    for (var index = 1; index <= 3; index++) {
      final y = size.height * index / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final activity = Path()
      ..moveTo(0, size.height * .72)
      ..cubicTo(
        size.width * .13,
        size.height * .64,
        size.width * .19,
        size.height * .77,
        size.width * .30,
        size.height * .55,
      )
      ..cubicTo(
        size.width * .43,
        size.height * .31,
        size.width * .55,
        size.height * .57,
        size.width * .66,
        size.height * .42,
      )
      ..cubicTo(
        size.width * .77,
        size.height * .28,
        size.width * .89,
        size.height * .40,
        size.width,
        size.height * .18,
      );

    final pipeline = Path()
      ..moveTo(0, size.height * .82)
      ..cubicTo(
        size.width * .14,
        size.height * .78,
        size.width * .28,
        size.height * .69,
        size.width * .40,
        size.height * .66,
      )
      ..cubicTo(
        size.width * .56,
        size.height * .63,
        size.width * .71,
        size.height * .55,
        size.width,
        size.height * .48,
      );

    final activityPaint = Paint()
      ..color = SpotlightTokens.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pipelinePaint = Paint()
      ..color = SpotlightTokens.magenta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(activity, activityPaint);
    canvas.drawPath(pipeline, pipelinePaint);

    final points = [
      Offset(size.width * .30, size.height * .55),
      Offset(size.width * .66, size.height * .42),
      Offset(size.width, size.height * .18),
    ];

    final point = Paint()
      ..color = SpotlightTokens.warning
      ..style = PaintingStyle.fill;

    for (final offset in points) {
      canvas.drawCircle(
        offset,
        8,
        Paint()..color = SpotlightTokens.warning.withValues(alpha: .16),
      );
      canvas.drawCircle(offset, 4.5, point);
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) => false;
}

class _ContributionPanel extends StatelessWidget {
  const _ContributionPanel();

  @override
  Widget build(BuildContext context) {
    const items = [
      _Contribution(
        label: 'Portfolio proof',
        detail: 'Sample readiness contribution',
        value: .72,
        color: SpotlightTokens.cyan,
      ),
      _Contribution(
        label: 'Opportunity pipeline',
        detail: 'Estimated active paths',
        value: .56,
        color: SpotlightTokens.magenta,
      ),
      _Contribution(
        label: 'Community activity',
        detail: 'Fixture-based returning attention',
        value: .41,
        color: SpotlightTokens.success,
      ),
    ];

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Where momentum comes from',
            subtitle:
                'Signals are sample-only until connected sources are verified.',
          ),
          const SizedBox(height: 14),
          ...items.map((item) => _ContributionRow(item: item)),
        ],
      ),
    );
  }
}

class _Contribution {
  const _Contribution({
    required this.label,
    required this.detail,
    required this.value,
    required this.color,
  });

  final String label;
  final String detail;
  final double value;
  final Color color;
}

class _ContributionRow extends StatelessWidget {
  const _ContributionRow({required this.item});

  final _Contribution item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: SpotlightTokens.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                item.detail,
                style: const TextStyle(
                  color: SpotlightTokens.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: item.value,
              minHeight: 7,
              backgroundColor: SpotlightTokens.bgElevated,
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementPanel extends StatelessWidget {
  const _MovementPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            title: 'Recent movement',
            subtitle: 'Planning notes, not live measurement.',
          ),
          SizedBox(height: 8),
          _MovementRow(
            icon: Icons.verified_outlined,
            color: SpotlightTokens.cyan,
            title: 'Proof profile strengthened',
            detail:
                'Sample note: featured work is better aligned to target opportunities.',
          ),
          _MovementRow(
            icon: Icons.forum_outlined,
            color: SpotlightTokens.success,
            title: 'Community response worth reviewing',
            detail:
                'Sample note: capture one audience insight before the next release.',
          ),
          _MovementRow(
            icon: Icons.route_outlined,
            color: SpotlightTokens.magenta,
            title: 'One relationship path is advancing',
            detail:
                'Estimated planning signal: prepare proof and availability context.',
          ),
        ],
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail();

  @override
  Widget build(BuildContext context) {
    return const Column(
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
                'Add a clear outcome to the proof asset most relevant to your strongest opportunity path.',
                style: TextStyle(
                  color: SpotlightTokens.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'That improves pitch readiness before reporting or payout data is connected.',
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
                title: 'What changed',
                subtitle: 'Sample signal digest',
              ),
              SizedBox(height: 10),
              _RailNote(
                icon: Icons.trending_up_rounded,
                color: SpotlightTokens.success,
                text: 'Featured proof coverage is moving toward readiness.',
              ),
              _RailNote(
                icon: Icons.hourglass_bottom_rounded,
                color: SpotlightTokens.warning,
                text: 'No verified payout source is connected yet.',
              ),
              _RailNote(
                icon: Icons.account_tree_outlined,
                color: SpotlightTokens.magenta,
                text: 'Three planning-only opportunity paths need review.',
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
                title: 'Upcoming commitments',
                subtitle: 'Planning state',
              ),
              SizedBox(height: 10),
              _Commitment(
                date: 'NEXT',
                title: 'Confirm next proof refresh',
                detail: 'Planning item · no external deadline connected.',
              ),
              _Commitment(
                date: 'LATER',
                title: 'Review payout readiness',
                detail: 'Planning item · no settlement data connected.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(18)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
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
  const _Eyebrow(this.text);

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

class _Status extends StatelessWidget {
  const _Status({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .7,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: SpotlightTokens.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SpotlightTokens.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SpotlightTokens.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 11,
                    height: 1.35,
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

class _RailNote extends StatelessWidget {
  const _RailNote({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
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

class _Commitment extends StatelessWidget {
  const _Commitment({
    required this.date,
    required this.title,
    required this.detail,
  });

  final String date;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: SpotlightTokens.bgElevated,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: SpotlightTokens.border),
            ),
            child: Text(
              date,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: SpotlightTokens.cyan,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: .7,
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
                  style: const TextStyle(
                    color: SpotlightTokens.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 11,
                    height: 1.3,
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
