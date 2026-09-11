import 'package:flutter/material.dart';
import 'package:spotlight_connect/pages/dashboards/fixtures/community_fixtures.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';

class CreatorCommunityPage extends StatefulWidget {
  const CreatorCommunityPage({super.key});

  @override
  State<CreatorCommunityPage> createState() => _CreatorCommunityPageState();
}

class _CreatorCommunityPageState extends State<CreatorCommunityPage> {
  String _filter = CommunityFixtures.activityFilters.first;
  String? _selectedCircle;
  String? _selectedActivity;
  String? _selectedMessage;
  bool _composerOpen = false;
  final TextEditingController _composer = TextEditingController();

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<CommunityActivityFixture> get _visibleActivity {
    if (_filter == 'All activity') return CommunityFixtures.activities;
    return CommunityFixtures.activities.where((row) {
      return switch (_filter) {
        'Love' => row.kind == CommunityActivityKind.love,
        'Comments' => row.kind == CommunityActivityKind.comment,
        'Shares' => row.kind == CommunityActivityKind.share,
        'Access' =>
          row.kind == CommunityActivityKind.access ||
              row.kind == CommunityActivityKind.membership,
        _ => true,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1180;
    return Semantics(
      label: 'Creator Community and Fandom',
      child: ColoredBox(
        color: SpotlightTokens.bgPrimary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${CommunityFixtures.creatorName}  ·  ${CommunityFixtures.creatorRole}',
                style: const TextStyle(
                  color: SpotlightTokens.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 17, child: _buildMain()),
                        const SizedBox(width: 16),
                        SizedBox(width: 320, child: _buildRail()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildMain(),
                        const SizedBox(height: 16),
                        _buildRail(),
                      ],
                    ),
              const SizedBox(height: 16),
              Text(
                CommunityFixtures.disclosure,
                style: const TextStyle(
                  color: SpotlightTokens.textMuted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      children: [
        const _Hero(),
        const SizedBox(height: 14),
        _ActivityPanel(
          filter: _filter,
          rows: _visibleActivity,
          selected: _selectedActivity,
          onFilter: (value) => setState(() => _filter = value),
          onSelect: (name) => setState(() => _selectedActivity = name),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final stack = constraints.maxWidth < 860;
            final circles = _CirclesPanel(
              selected: _selectedCircle,
              onSelect: (name) => setState(() => _selectedCircle = name),
              onUnavailable: _snack,
            );
            final events = _EventsPanel(onUnavailable: _snack);
            final messages = _MessagesPanel(
              selected: _selectedMessage,
              onSelect: (from) => setState(() => _selectedMessage = from),
              onUnavailable: _snack,
            );
            if (stack) {
              return Column(
                children: [
                  circles,
                  const SizedBox(height: 12),
                  events,
                  const SizedBox(height: 12),
                  messages,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: circles),
                const SizedBox(width: 12),
                Expanded(child: events),
                const SizedBox(width: 12),
                Expanded(child: messages),
              ],
            );
          },
        ),
        if (_composerOpen) ...[
          const SizedBox(height: 14),
          _Composer(
            controller: _composer,
            onClose: () => setState(() => _composerOpen = false),
            onPreview: () {
              _snack(CommunityFixtures.nextActionHint);
              setState(() {
                _composer.clear();
                _composerOpen = false;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildRail() {
    return Column(
      children: [
        const _PulsePanel(),
        const SizedBox(height: 12),
        _AlertsPanel(onUnavailable: _snack),
        const SizedBox(height: 12),
        _RecognitionPanel(onUnavailable: _snack),
        const SizedBox(height: 12),
        _SentimentPanel(
          onExplore: () => _snack(CommunityFixtures.sentimentCopy),
        ),
        const SizedBox(height: 12),
        _PrimaryAction(onPressed: () => setState(() => _composerOpen = true)),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                CommunityFixtures.pageEyebrow,
                style: TextStyle(
                  color: SpotlightTokens.cyan,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                CommunityFixtures.pageTitle,
                style: TextStyle(
                  color: SpotlightTokens.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                CommunityFixtures.pageSubhead,
                style: TextStyle(
                  color: SpotlightTokens.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              const _Cluster(),
              const SizedBox(height: 12),
              const Text(
                CommunityFixtures.healthLabel,
                style: TextStyle(
                  color: SpotlightTokens.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                CommunityFixtures.healthState,
                style: TextStyle(
                  color: SpotlightTokens.success,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                CommunityFixtures.healthDetail,
                style: TextStyle(
                  color: SpotlightTokens.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          );
          final media = const _HeroMedia();
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 14), media],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 16),
              SizedBox(width: 280, child: media),
            ],
          );
        },
      ),
    );
  }
}

class _HeroMedia extends StatelessWidget {
  const _HeroMedia();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SpotlightTokens.bgElevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: SpotlightTokens.border),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.graphic_eq_rounded,
                  color: SpotlightTokens.cyan,
                  size: 28,
                ),
                SizedBox(height: 8),
                Text(
                  CommunityFixtures.heroMediaCaption,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: SpotlightTokens.textMuted,
                    fontSize: 11,
                    height: 1.35,
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

class _Cluster extends StatelessWidget {
  const _Cluster();

  @override
  Widget build(BuildContext context) {
    const initials = <String>['LP', 'JE', 'MC', 'RB', 'LB'];
    return Row(
      children: [
        SizedBox(
          width: 148,
          height: 36,
          child: Stack(
            children: [
              for (var i = 0; i < initials.length; i++)
                Positioned(
                  left: i * 22.0,
                  child: _Initial(initials[i], size: 32),
                ),
            ],
          ),
        ),
        _SoftChip(label: CommunityFixtures.clusterOverflow),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            CommunityFixtures.clusterCaption,
            style: TextStyle(color: SpotlightTokens.textMuted, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({
    required this.filter,
    required this.rows,
    required this.selected,
    required this.onFilter,
    required this.onSelect,
  });

  final String filter;
  final List<CommunityActivityFixture> rows;
  final String? selected;
  final ValueChanged<String> onFilter;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Community activity',
                  style: TextStyle(
                    color: SpotlightTokens.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Flexible(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.end,
                  children: [
                    for (final option in CommunityFixtures.activityFilters)
                      ChoiceChip(
                        label: Text(option),
                        selected: filter == option,
                        onSelected: (_) => onFilter(option),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (rows.isEmpty)
            const Text(
              'No sample rows in this local filter.',
              style: TextStyle(color: SpotlightTokens.textMuted, fontSize: 12),
            ),
          for (final row in rows)
            _ActivityRow(
              row: row,
              selected: selected == row.name,
              onTap: () => onSelect(row.name),
            ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.row,
    required this.selected,
    required this.onTap,
  });

  final CommunityActivityFixture row;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? SpotlightTokens.cyan.withValues(alpha: 0.08)
            : SpotlightTokens.bgElevated,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(_iconFor(row.kind), color: SpotlightTokens.cyan, size: 18),
                const SizedBox(width: 10),
                _Initial(row.initials),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: row.name,
                              style: const TextStyle(
                                color: SpotlightTokens.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: ' ${row.action}',
                              style: const TextStyle(
                                color: SpotlightTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        row.quote,
                        style: const TextStyle(
                          color: SpotlightTokens.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        row.time,
                        style: const TextStyle(
                          color: SpotlightTokens.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const _MediaTile(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(CommunityActivityKind kind) {
    return switch (kind) {
      CommunityActivityKind.love => Icons.favorite_outline_rounded,
      CommunityActivityKind.comment => Icons.chat_bubble_outline_rounded,
      CommunityActivityKind.share => Icons.ios_share_rounded,
      CommunityActivityKind.access => Icons.lock_open_rounded,
      CommunityActivityKind.membership => Icons.workspace_premium_outlined,
    };
  }
}

class _CirclesPanel extends StatelessWidget {
  const _CirclesPanel({
    required this.selected,
    required this.onSelect,
    required this.onUnavailable,
  });

  final String? selected;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onUnavailable;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your circles',
            style: TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final circle in CommunityFixtures.circles)
            _SelectableRow(
              selected: selected == circle.name,
              onTap: () => onSelect(circle.name),
              child: Row(
                children: [
                  _Initial(circle.initials),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          circle.name,
                          style: const TextStyle(
                            color: SpotlightTokens.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${circle.members} · ${circle.active}',
                          style: const TextStyle(
                            color: SpotlightTokens.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          _TextAction(
            label: 'Create a new circle',
            onTap: () =>
                onUnavailable('Circle creation is unavailable in this build.'),
          ),
        ],
      ),
    );
  }
}

class _EventsPanel extends StatelessWidget {
  const _EventsPanel({required this.onUnavailable});

  final ValueChanged<String> onUnavailable;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming access & events',
            style: TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final event in CommunityFixtures.events)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateBadge(month: event.month, day: event.day),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: SpotlightTokens.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          event.detail,
                          style: const TextStyle(
                            color: SpotlightTokens.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          event.whenWhere,
                          style: const TextStyle(
                            color: SpotlightTokens.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          event.going,
                          style: const TextStyle(
                            color: SpotlightTokens.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          _TextAction(
            label: 'Create an event',
            onTap: () =>
                onUnavailable('Event creation is unavailable in this build.'),
          ),
        ],
      ),
    );
  }
}

class _MessagesPanel extends StatelessWidget {
  const _MessagesPanel({
    required this.selected,
    required this.onSelect,
    required this.onUnavailable,
  });

  final String? selected;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onUnavailable;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Messages that need you',
            style: TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final message in CommunityFixtures.messages)
            _SelectableRow(
              selected: selected == message.from,
              onTap: () => onSelect(message.from),
              child: Row(
                children: [
                  _Initial(message.initials),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.from,
                          style: const TextStyle(
                            color: SpotlightTokens.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          message.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SpotlightTokens.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          message.time,
                          style: const TextStyle(
                            color: SpotlightTokens.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          _TextAction(
            label: 'Go to messages',
            onTap: () =>
                onUnavailable('Live messaging is unavailable in this build.'),
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
          const Text(
            'Supporter Pulse',
            style: TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Example supporter pulse · past 7 days',
            style: TextStyle(color: SpotlightTokens.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 10),
          for (final row in CommunityFixtures.pulse)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: const TextStyle(
                        color: SpotlightTokens.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    row.value,
                    style: const TextStyle(
                      color: SpotlightTokens.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
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

class _AlertsPanel extends StatelessWidget {
  const _AlertsPanel({required this.onUnavailable});

  final ValueChanged<String> onUnavailable;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Relationship alerts',
            style: TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final alert in CommunityFixtures.alerts)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const _Initial('•', size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            color: SpotlightTokens.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          alert.detail,
                          style: const TextStyle(
                            color: SpotlightTokens.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => onUnavailable(alert.reason),
                    child: Text(alert.action),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecognitionPanel extends StatelessWidget {
  const _RecognitionPanel({required this.onUnavailable});

  final ValueChanged<String> onUnavailable;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recognition queue',
            style: TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in CommunityFixtures.recognitions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: SpotlightTokens.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item.detail,
                    style: const TextStyle(
                      color: SpotlightTokens.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          _TextAction(
            label: 'Issue a reward',
            onTap: () =>
                onUnavailable('Reward issuance is unavailable in this build.'),
          ),
        ],
      ),
    );
  }
}

class _SentimentPanel extends StatelessWidget {
  const _SentimentPanel({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            CommunityFixtures.sentimentTitle,
            style: TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: SpotlightTokens.magenta, width: 3),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: SpotlightTokens.magenta,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CommunityFixtures.sentimentState,
                      style: TextStyle(
                        color: SpotlightTokens.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      CommunityFixtures.sentimentScore,
                      style: TextStyle(
                        color: SpotlightTokens.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      CommunityFixtures.sentimentDelta,
                      style: TextStyle(
                        color: SpotlightTokens.success,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            CommunityFixtures.sentimentCopy,
            style: TextStyle(
              color: SpotlightTokens.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          _TextAction(label: "What's driving this?", onTap: onExplore),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: const Text(CommunityFixtures.nextAction),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onClose,
    required this.onPreview,
  });

  final TextEditingController controller;
  final VoidCallback onClose;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Local update preview',
            style: TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            CommunityFixtures.nextActionHint,
            style: TextStyle(color: SpotlightTokens.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 3,
            style: const TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Write a sample update. Nothing is published.',
              hintStyle: const TextStyle(color: SpotlightTokens.textMuted),
              filled: true,
              fillColor: SpotlightTokens.bgElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(onPressed: onClose, child: const Text('Close')),
              const Spacer(),
              FilledButton(
                onPressed: onPreview,
                child: const Text('Preview locally'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectableRow extends StatelessWidget {
  const _SelectableRow({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? SpotlightTokens.cyan.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(padding: const EdgeInsets.all(8), child: child),
        ),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(onPressed: onTap, child: Text(label)),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.month, required this.day});

  final String month;
  final String day;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Column(
        children: [
          Text(
            month,
            style: const TextStyle(
              color: SpotlightTokens.cyan,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            day,
            style: const TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 36,
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: const Icon(
        Icons.crop_landscape_rounded,
        size: 16,
        color: SpotlightTokens.textMuted,
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial(this.value, {this.size = 32});

  final String value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: SpotlightTokens.bgElevated,
        shape: BoxShape.circle,
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: SpotlightTokens.cyan,
          fontSize: size < 30 ? 10 : 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: SpotlightTokens.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SpotlightTokens.bgSurface,
      borderRadius: BorderRadius.circular(SpotlightTokens.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpotlightTokens.radiusLg),
          border: Border.all(color: SpotlightTokens.border),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
