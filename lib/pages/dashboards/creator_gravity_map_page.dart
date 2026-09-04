import 'package:flutter/material.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';

class CreatorGravityMapPage extends StatefulWidget {
  const CreatorGravityMapPage({super.key});

  @override
  State<CreatorGravityMapPage> createState() => _CreatorGravityMapPageState();
}

class _CreatorGravityMapPageState extends State<CreatorGravityMapPage> {
  _MapFilter _filter = _MapFilter.all;
  _MapNode _selected = _MapNode.creator;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GravityMapHeader(
          filter: _filter,
          onFilterChanged: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: isWide
              ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _GravityCanvas(
                        filter: _filter,
                        selected: _selected,
                        onSelect: (node) => setState(() => _selected = node),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 300,
                      child: _GravityInspector(node: _selected),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: _GravityCanvas(
                        filter: _filter,
                        selected: _selected,
                        onSelect: (node) => setState(() => _selected = node),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GravityInspector(node: _selected),
                  ],
                ),
        ),
      ],
    );
  }
}

enum _MapFilter { all, people, brands, proof, communities }

enum _MapNode { creator, collaborator, brand, community, proof, supporters }

class _GravityMapHeader extends StatelessWidget {
  const _GravityMapHeader({
    required this.filter,
    required this.onFilterChanged,
  });

  final _MapFilter filter;
  final ValueChanged<_MapFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(SpotlightTokens.radiusXl),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RELATIONSHIP GRAVITY MAP',
            style: TextStyle(
              color: SpotlightTokens.cyan,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'See the relationships that move your work forward.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: SpotlightTokens.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Preview relationship map. Connect activity, collaborators, and proof to personalize this workspace.',
            style: TextStyle(color: SpotlightTokens.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in _MapFilter.values)
                ChoiceChip(
                  label: Text(_filterLabel(value)),
                  selected: filter == value,
                  onSelected: (_) => onFilterChanged(value),
                  selectedColor: SpotlightTokens.cyan.withValues(alpha: 0.18),
                  backgroundColor: SpotlightTokens.bgElevated,
                  labelStyle: TextStyle(
                    color: filter == value
                        ? SpotlightTokens.textPrimary
                        : SpotlightTokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: filter == value
                        ? SpotlightTokens.cyan.withValues(alpha: 0.45)
                        : SpotlightTokens.border,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _filterLabel(_MapFilter value) {
    switch (value) {
      case _MapFilter.all:
        return 'All connections';
      case _MapFilter.people:
        return 'People';
      case _MapFilter.brands:
        return 'Brands';
      case _MapFilter.proof:
        return 'Proof';
      case _MapFilter.communities:
        return 'Communities';
    }
  }
}

class _GravityCanvas extends StatelessWidget {
  const _GravityCanvas({
    required this.filter,
    required this.selected,
    required this.onSelect,
  });

  final _MapFilter filter;
  final _MapNode selected;
  final ValueChanged<_MapNode> onSelect;

  bool _visible(_MapNode node) {
    if (filter == _MapFilter.all || node == _MapNode.creator) return true;
    switch (filter) {
      case _MapFilter.people:
        return node == _MapNode.collaborator || node == _MapNode.supporters;
      case _MapFilter.brands:
        return node == _MapNode.brand;
      case _MapFilter.proof:
        return node == _MapNode.proof;
      case _MapFilter.communities:
        return node == _MapNode.community;
      case _MapFilter.all:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(SpotlightTokens.radiusXl),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              const Positioned.fill(child: _MapGrid()),
              Positioned.fill(
                child: CustomPaint(
                  painter: _ConnectionPainter(
                    showCollaborator: _visible(_MapNode.collaborator),
                    showBrand: _visible(_MapNode.brand),
                    showCommunity: _visible(_MapNode.community),
                    showProof: _visible(_MapNode.proof),
                    showSupporters: _visible(_MapNode.supporters),
                  ),
                ),
              ),
              if (_visible(_MapNode.creator))
                _MapNodeBubble(
                  alignment: const Alignment(0, 0),
                  icon: Icons.person_rounded,
                  label: 'You',
                  selected: selected == _MapNode.creator,
                  accent: SpotlightTokens.cyan,
                  onTap: () => onSelect(_MapNode.creator),
                ),
              if (_visible(_MapNode.collaborator))
                _MapNodeBubble(
                  alignment: const Alignment(-0.58, -0.42),
                  icon: Icons.videocam_outlined,
                  label: 'Maya',
                  selected: selected == _MapNode.collaborator,
                  accent: SpotlightTokens.magenta,
                  onTap: () => onSelect(_MapNode.collaborator),
                ),
              if (_visible(_MapNode.brand))
                _MapNodeBubble(
                  alignment: const Alignment(0.62, -0.36),
                  icon: Icons.business_center_outlined,
                  label: 'Northstar',
                  selected: selected == _MapNode.brand,
                  accent: SpotlightTokens.warning,
                  onTap: () => onSelect(_MapNode.brand),
                ),
              if (_visible(_MapNode.community))
                _MapNodeBubble(
                  alignment: const Alignment(-0.55, 0.48),
                  icon: Icons.groups_outlined,
                  label: 'Film Circle',
                  selected: selected == _MapNode.community,
                  accent: SpotlightTokens.purple,
                  onTap: () => onSelect(_MapNode.community),
                ),
              if (_visible(_MapNode.proof))
                _MapNodeBubble(
                  alignment: const Alignment(0.52, 0.48),
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Latest reel',
                  selected: selected == _MapNode.proof,
                  accent: SpotlightTokens.rose,
                  onTap: () => onSelect(_MapNode.proof),
                ),
              if (_visible(_MapNode.supporters))
                _MapNodeBubble(
                  alignment: const Alignment(0.08, 0.72),
                  icon: Icons.favorite_outline_rounded,
                  label: 'Supporters',
                  selected: selected == _MapNode.supporters,
                  accent: SpotlightTokens.success,
                  onTap: () => onSelect(_MapNode.supporters),
                ),
              Positioned(left: 16, bottom: 16, child: _MapLegend()),
              Positioned(
                right: 16,
                bottom: 16,
                child: FilledButton.tonalIcon(
                  onPressed: () => onSelect(_MapNode.creator),
                  icon: const Icon(Icons.center_focus_strong_rounded, size: 17),
                  label: const Text('Recenter'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapGrid extends StatelessWidget {
  const _MapGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SpotlightTokens.borderSubtle
      ..strokeWidth = 1;

    const step = 36.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}

class _ConnectionPainter extends CustomPainter {
  const _ConnectionPainter({
    required this.showCollaborator,
    required this.showBrand,
    required this.showCommunity,
    required this.showProof,
    required this.showSupporters,
  });

  final bool showCollaborator;
  final bool showBrand;
  final bool showCommunity;
  final bool showProof;
  final bool showSupporters;

  Offset _at(Size size, Alignment alignment) {
    return Offset(
      (alignment.x + 1) * size.width / 2,
      (alignment.y + 1) * size.height / 2,
    );
  }

  void _line(
    Canvas canvas,
    Offset from,
    Offset to,
    Color color, {
    bool dashed = false,
  }) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.62)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (!dashed) {
      canvas.drawLine(from, to, paint);
      return;
    }

    final direction = to - from;
    final length = direction.distance;
    final unit = direction / length;
    for (double distance = 0; distance < length; distance += 12) {
      final end = (distance + 6).clamp(0, length).toDouble();
      canvas.drawLine(from + unit * distance, from + unit * end, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = _at(size, const Alignment(0, 0));

    if (showCollaborator) {
      _line(
        canvas,
        center,
        _at(size, const Alignment(-0.58, -0.42)),
        SpotlightTokens.magenta,
      );
    }
    if (showBrand) {
      _line(
        canvas,
        center,
        _at(size, const Alignment(0.62, -0.36)),
        SpotlightTokens.warning,
      );
    }
    if (showCommunity) {
      _line(
        canvas,
        center,
        _at(size, const Alignment(-0.55, 0.48)),
        SpotlightTokens.purple,
      );
    }
    if (showProof) {
      _line(
        canvas,
        center,
        _at(size, const Alignment(0.52, 0.48)),
        SpotlightTokens.rose,
      );
    }
    if (showSupporters) {
      _line(
        canvas,
        center,
        _at(size, const Alignment(0.08, 0.72)),
        SpotlightTokens.success,
        dashed: true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) {
    return showCollaborator != oldDelegate.showCollaborator ||
        showBrand != oldDelegate.showBrand ||
        showCommunity != oldDelegate.showCommunity ||
        showProof != oldDelegate.showProof ||
        showSupporters != oldDelegate.showSupporters;
  }
}

class _MapNodeBubble extends StatelessWidget {
  const _MapNodeBubble({
    required this.alignment,
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.22)
                  : SpotlightTokens.bgElevated,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? accent : SpotlightTokens.border,
                width: selected ? 1.6 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.20),
                        blurRadius: 18,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected ? accent : SpotlightTokens.textSecondary,
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? SpotlightTokens.textPrimary
                        : SpotlightTokens.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgOverlay,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: SpotlightTokens.cyan, size: 9),
          SizedBox(width: 5),
          Text(
            'Direct',
            style: TextStyle(
              color: SpotlightTokens.textSecondary,
              fontSize: 10,
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.more_horiz, color: SpotlightTokens.textMuted, size: 17),
          SizedBox(width: 4),
          Text(
            'Emerging',
            style: TextStyle(
              color: SpotlightTokens.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _GravityInspector extends StatelessWidget {
  const _GravityInspector({required this.node});

  final _MapNode node;

  _NodeDetail get _detail {
    switch (node) {
      case _MapNode.creator:
        return const _NodeDetail(
          icon: Icons.person_rounded,
          accent: SpotlightTokens.cyan,
          kind: 'YOUR CREATOR NODE',
          title: 'Your professional graph',
          detail:
              'Your profile, proof, relationships, and activity form the center of this map.',
          action: 'Complete profile signals',
        );
      case _MapNode.collaborator:
        return const _NodeDetail(
          icon: Icons.videocam_outlined,
          accent: SpotlightTokens.magenta,
          kind: 'COLLABORATOR',
          title: 'Maya Chen',
          detail:
              'A direct creative relationship connected through shared production work.',
          action: 'Open collaborator context',
        );
      case _MapNode.brand:
        return const _NodeDetail(
          icon: Icons.business_center_outlined,
          accent: SpotlightTokens.warning,
          kind: 'BRAND PATH',
          title: 'Northstar Studios',
          detail:
              'A potential opportunity path connected through your commercial-work network.',
          action: 'Review warm path',
        );
      case _MapNode.community:
        return const _NodeDetail(
          icon: Icons.groups_outlined,
          accent: SpotlightTokens.purple,
          kind: 'COMMUNITY',
          title: 'Film Circle',
          detail:
              'A professional circle where recent activity can lead to collaborators and referrals.',
          action: 'View community activity',
        );
      case _MapNode.proof:
        return const _NodeDetail(
          icon: Icons.play_circle_outline_rounded,
          accent: SpotlightTokens.rose,
          kind: 'PROOF ASSET',
          title: 'Latest reel',
          detail:
              'A portfolio asset that can strengthen opportunity applications and discovery.',
          action: 'Review proof readiness',
        );
      case _MapNode.supporters:
        return const _NodeDetail(
          icon: Icons.favorite_outline_rounded,
          accent: SpotlightTokens.success,
          kind: 'SUPPORTER SIGNAL',
          title: 'Supporter circle',
          detail:
              'An emerging relationship cluster. Add activity and community context to deepen the signal.',
          action: 'Explore supporter context',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(SpotlightTokens.radiusXl),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(detail.icon, color: detail.accent, size: 30),
          const SizedBox(height: 16),
          Text(
            detail.kind,
            style: TextStyle(
              color: detail.accent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            detail.title,
            style: const TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detail.detail,
            style: const TextStyle(
              color: SpotlightTokens.textSecondary,
              height: 1.45,
            ),
          ),
          const Spacer(),
          const Divider(color: SpotlightTokens.border),
          const SizedBox(height: 12),
          const Text(
            'WHY IT MATTERS',
            style: TextStyle(
              color: SpotlightTokens.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Relationship intelligence becomes useful when it helps you choose a credible next action.',
            style: TextStyle(
              color: SpotlightTokens.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_rounded, size: 17),
              label: Text(detail.action),
            ),
          ),
        ],
      ),
    );
  }
}

class _NodeDetail {
  const _NodeDetail({
    required this.icon,
    required this.accent,
    required this.kind,
    required this.title,
    required this.detail,
    required this.action,
  });

  final IconData icon;
  final Color accent;
  final String kind;
  final String title;
  final String detail;
  final String action;
}
