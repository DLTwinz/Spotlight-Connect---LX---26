import 'package:flutter/material.dart';
import 'package:spotlight_connect/pages/dashboards/fixtures/analytics_fixtures.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';

class CreatorAnalyticsEconomicsPage extends StatefulWidget {
  const CreatorAnalyticsEconomicsPage({super.key});

  @override
  State<CreatorAnalyticsEconomicsPage> createState() =>
      _CreatorAnalyticsEconomicsPageState();
}

enum _PulseRange { daily, weekly, cumulative }

class _CreatorAnalyticsEconomicsPageState
    extends State<CreatorAnalyticsEconomicsPage> {
  _PulseRange _range = _PulseRange.daily;

  List<AnalyticsPulsePoint> get _points {
    switch (_range) {
      case _PulseRange.daily:
        return AnalyticsFixtures.dailyPulse;
      case _PulseRange.weekly:
        return AnalyticsFixtures.weeklyPulse;
      case _PulseRange.cumulative:
        return AnalyticsFixtures.cumulativePulse;
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    return Semantics(
      label: 'Creator Analytics and Economics',
      child: ColoredBox(
        color: SpotlightTokens.bgPrimary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Hero(onReview: () => _snack('Review stays local. ${AnalyticsFixtures.disclosure}')),
              const SizedBox(height: 16),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 12, child: _MainColumn(range: _range, points: _points, onRange: (value) => setState(() => _range = value))),
                    const SizedBox(width: 16),
                    const Expanded(flex: 5, child: _RightRail()),
                  ],
                )
              else
                Column(
                  children: [
                    _MainColumn(range: _range, points: _points, onRange: (value) => setState(() => _range = value)),
                    const SizedBox(height: 16),
                    const _RightRail(),
                  ],
                ),
              const SizedBox(height: 16),
              const _Disclosure(),
            ],
          ),
        ),
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
      padding: const EdgeInsets.all(22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _NeutralPortrait(),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AnalyticsFixtures.pageEyebrow, style: TextStyle(color: SpotlightTokens.cyan, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                SizedBox(height: 8),
                Text(AnalyticsFixtures.pageTitle, style: TextStyle(color: SpotlightTokens.textPrimary, fontSize: 26, fontWeight: FontWeight.w800, height: 1.1)),
                SizedBox(height: 8),
                Text(AnalyticsFixtures.pageSubhead, style: TextStyle(color: SpotlightTokens.textSecondary, fontSize: 14, height: 1.4)),
                SizedBox(height: 10),
                Text('Mira Solis  \u00b7  Creator \u00b7 Analytics workspace', style: TextStyle(color: SpotlightTokens.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(onPressed: onReview, child: const Text('Review performance')),
        ],
      ),
    );
  }
}

class _NeutralPortrait extends StatelessWidget {
  const _NeutralPortrait();
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Neutral identity frame for Mira Solis',
      child: Container(
        width: 64, height: 64, alignment: Alignment.center,
        decoration: BoxDecoration(color: SpotlightTokens.bgElevated, borderRadius: BorderRadius.circular(18), border: Border.all(color: SpotlightTokens.border)),
        child: const Text('MS', style: TextStyle(color: SpotlightTokens.cyan, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _MainColumn extends StatelessWidget {
  const _MainColumn({required this.range, required this.points, required this.onRange});
  final _PulseRange range;
  final List<AnalyticsPulsePoint> points;
  final ValueChanged<_PulseRange> onRange;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const _KpiRow(), const SizedBox(height: 16),
      _PulsePanel(range: range, points: points, onRange: onRange),
      const SizedBox(height: 16), const _SourceMix(), const SizedBox(height: 16), const _ImpactGrid(),
    ]);
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 680;
      final cards = AnalyticsFixtures.kpis.map((kpi) => _KpiCard(kpi: kpi)).toList();
      if (compact) {
        return Column(children: [for (var i = 0; i < cards.length; i++) ...[if (i > 0) const SizedBox(height: 10), cards[i]]]);
      }
      return Row(children: [for (var i = 0; i < cards.length; i++) ...[if (i > 0) const SizedBox(width: 10), Expanded(child: cards[i])]]);
    });
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi});
  final AnalyticsKpiFixture kpi;
  @override
  Widget build(BuildContext context) {
    return _Panel(padding: const EdgeInsets.all(16), child: SizedBox(height: 128, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text(kpi.label, style: const TextStyle(color: SpotlightTokens.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.7)), const Spacer(), _StateChip(state: kpi.state)]),
      const Spacer(),
      Text(kpi.value, style: const TextStyle(color: SpotlightTokens.textPrimary, fontSize: 28, fontWeight: FontWeight.w800, height: 1)),
      const SizedBox(height: 6),
      Text(kpi.detail, style: const TextStyle(color: SpotlightTokens.textSecondary, fontSize: 11)),
    ])));
  }
}

class _PulsePanel extends StatelessWidget {
  const _PulsePanel({required this.range, required this.points, required this.onRange});
  final _PulseRange range;
  final List<AnalyticsPulsePoint> points;
  final ValueChanged<_PulseRange> onRange;
  @override
  Widget build(BuildContext context) {
    return _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: _SectionTitle(title: 'Economic Pulse', subtitle: 'Fixture activity and pipeline sample')),
        _RangeChip(label: 'Daily', selected: range == _PulseRange.daily, onTap: () => onRange(_PulseRange.daily)),
        const SizedBox(width: 6),
        _RangeChip(label: 'Weekly', selected: range == _PulseRange.weekly, onTap: () => onRange(_PulseRange.weekly)),
        const SizedBox(width: 6),
        _RangeChip(label: 'Cumulative', selected: range == _PulseRange.cumulative, onTap: () => onRange(_PulseRange.cumulative)),
      ]),
      const SizedBox(height: 16),
      SizedBox(height: 220, child: Semantics(label: 'Economic pulse chart, fixture sample', child: CustomPaint(painter: _PulsePainter(points: points), child: const SizedBox.expand()))),
      const SizedBox(height: 10),
      const Wrap(spacing: 16, children: [_Legend(color: SpotlightTokens.cyan, label: 'Activity'), _Legend(color: SpotlightTokens.magenta, label: 'Pipeline')]),
    ]));
  }
}

class _PulsePainter extends CustomPainter {
  const _PulsePainter({required this.points});
  final List<AnalyticsPulsePoint> points;
  @override
  void paint(Canvas canvas, Size size) {
    const left = 36.0; const bottom = 22.0; const top = 8.0;
    final plot = Rect.fromLTRB(left, top, size.width, size.height - bottom);
    final grid = Paint()..color = SpotlightTokens.border..strokeWidth = 1;
    const yLabels = ['8K', '6K', '4K', '2K', '0'];
    const textStyle = TextStyle(color: SpotlightTokens.textMuted, fontSize: 10);
    for (var i = 0; i < yLabels.length; i++) {
      final y = plot.top + plot.height * i / (yLabels.length - 1);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      final tp = TextPainter(text: TextSpan(text: yLabels[i], style: textStyle), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }
    Offset pointOf(int index, double value) {
      final t = points.length == 1 ? 0.0 : index / (points.length - 1);
      return Offset(plot.left + plot.width * t, plot.bottom - plot.height * value);
    }
    Path lineOf(double Function(AnalyticsPulsePoint p) read) {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final offset = pointOf(i, read(points[i]));
        if (i == 0) { path.moveTo(offset.dx, offset.dy); } else { path.lineTo(offset.dx, offset.dy); }
      }
      return path;
    }
    final activityLine = lineOf((p) => p.activity);
    final fill = Path.from(activityLine)..lineTo(plot.right, plot.bottom)..lineTo(plot.left, plot.bottom)..close();
    canvas.drawPath(fill, Paint()..color = SpotlightTokens.cyan.withValues(alpha: 0.12));
    canvas.drawPath(activityLine, Paint()..color = SpotlightTokens.cyan..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    canvas.drawPath(lineOf((p) => p.pipeline), Paint()..color = SpotlightTokens.magenta..style = PaintingStyle.stroke..strokeWidth = 1.6..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    for (var i = 0; i < points.length; i++) {
      final tp = TextPainter(text: TextSpan(text: points[i].label, style: textStyle), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(pointOf(i, 0).dx - tp.width / 2, plot.bottom + 6));
    }
  }
  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) => oldDelegate.points != points;
}

class _SourceMix extends StatelessWidget {
  const _SourceMix();
  @override
  Widget build(BuildContext context) {
    return _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionTitle(title: 'Where it came from', subtitle: 'Fixture source mix'),
      const SizedBox(height: 14),
      ...AnalyticsFixtures.sources.map((source) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [
        Expanded(child: Text(source.label, style: const TextStyle(color: SpotlightTokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600))),
        _StateChip(state: source.state), const SizedBox(width: 10),
        SizedBox(width: 160, child: ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: source.share, minHeight: 7, backgroundColor: SpotlightTokens.bgElevated, valueColor: const AlwaysStoppedAnimation<Color>(SpotlightTokens.cyan)))),
      ]))),
    ]));
  }
}

class _ImpactGrid extends StatelessWidget {
  const _ImpactGrid();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final stacked = constraints.maxWidth < 720;
      final campaign = _ListPanel(title: 'Campaign impact', rows: AnalyticsFixtures.campaigns);
      final program = _ListPanel(title: 'Program health', rows: AnalyticsFixtures.programs);
      final portfolio = _ListPanel(title: 'Portfolio performance', rows: AnalyticsFixtures.portfolio);
      if (stacked) return Column(children: [campaign, const SizedBox(height: 12), program, const SizedBox(height: 12), portfolio]);
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: campaign), const SizedBox(width: 12), Expanded(child: program), const SizedBox(width: 12), Expanded(child: portfolio)]);
    });
  }
}

class _ListPanel extends StatelessWidget {
  const _ListPanel({required this.title, required this.rows});
  final String title;
  final List<AnalyticsRowFixture> rows;
  @override
  Widget build(BuildContext context) {
    return _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(title: title, subtitle: 'Fixture sample'), const SizedBox(height: 10),
      ...rows.map((row) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(row.title, style: const TextStyle(color: SpotlightTokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(row.detail, style: const TextStyle(color: SpotlightTokens.textSecondary, fontSize: 11, height: 1.3)),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(row.metric, style: const TextStyle(color: SpotlightTokens.cyanSoft, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4), _StateChip(state: row.state),
        ]),
      ]))),
    ]));
  }
}

class _RightRail extends StatelessWidget {
  const _RightRail();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle(title: 'Quick Insights', subtitle: 'Fixture recommendations'),
        const SizedBox(height: 10),
        ...AnalyticsFixtures.insights.map((insight) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(insight, style: const TextStyle(color: SpotlightTokens.textSecondary, fontSize: 12, height: 1.4)))),
      ])),
      const SizedBox(height: 16),
      const _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionTitle(title: 'Data Confidence Key', subtitle: 'Fixture visual states only'),
        SizedBox(height: 10),
        _KeyRow(state: AnalyticsFixtureState.verified, detail: 'Internal fixture marked stable'),
        _KeyRow(state: AnalyticsFixtureState.estimated, detail: 'Modeled sample, not a payout'),
        _KeyRow(state: AnalyticsFixtureState.pending, detail: 'Incomplete sample path'),
      ])),
    ]);
  }
}

class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.state, required this.detail});
  final AnalyticsFixtureState state;
  final String detail;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
      _StateChip(state: state), const SizedBox(width: 8),
      Expanded(child: Text(detail, style: const TextStyle(color: SpotlightTokens.textSecondary, fontSize: 11))),
    ]));
  }
}

class _Disclosure extends StatelessWidget {
  const _Disclosure();
  @override
  Widget build(BuildContext context) {
    return const Text(AnalyticsFixtures.disclosure, style: TextStyle(color: SpotlightTokens.textMuted, fontSize: 11, height: 1.4));
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.state});
  final AnalyticsFixtureState state;
  @override
  Widget build(BuildContext context) {
    final color = switch (state.label) { 'Verified' => SpotlightTokens.success, 'Pending' => SpotlightTokens.warning, _ => SpotlightTokens.magenta };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Text(state.label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({required this.label, required this.selected, required this.onTap});
  final String label; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Semantics(button: true, selected: selected, label: '$label pulse range', child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? SpotlightTokens.cyan.withValues(alpha: 0.16) : SpotlightTokens.bgElevated,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? SpotlightTokens.cyan : SpotlightTokens.border),
        ),
        child: Text(label, style: TextStyle(color: selected ? SpotlightTokens.cyan : SpotlightTokens.textSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    ));
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color; final String label;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 2, color: color), const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: SpotlightTokens.textSecondary, fontSize: 11)),
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title; final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: SpotlightTokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 3),
      Text(subtitle, style: const TextStyle(color: SpotlightTokens.textMuted, fontSize: 11)),
    ]);
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child; final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: padding,
      decoration: BoxDecoration(color: SpotlightTokens.bgSurface, borderRadius: BorderRadius.circular(SpotlightTokens.radiusLg), border: Border.all(color: SpotlightTokens.border)),
      child: child,
    );
  }
}
