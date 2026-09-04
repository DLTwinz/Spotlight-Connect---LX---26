import 'package:flutter/material.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';

enum CreatorWorkspaceKind {
  momentum,
  workflow,
  portfolio,
  community,
  programs,
  analytics,
  profile,
}

class CreatorWorkspacePage extends StatelessWidget {
  const CreatorWorkspacePage({super.key, required this.kind});

  final CreatorWorkspaceKind kind;

  _WorkspaceContent get _content {
    switch (kind) {
      case CreatorWorkspaceKind.momentum:
        return const _WorkspaceContent(
          eyebrow: 'SAMPLE MOMENTUM SIGNALS',
          title: 'Turn consistent signals into forward motion.',
          detail:
              'Use this planning view to identify the next creator action worth taking.',
          action: 'Review growth plan',
          actionIcon: Icons.trending_up_rounded,
          accent: SpotlightTokens.cyan,
          cards: [
            _WorkspaceCardData(
              label: 'Weekly trajectory',
              value: '+18%',
              detail: 'Sample improvement in recent creator activity.',
              icon: Icons.show_chart_rounded,
            ),
            _WorkspaceCardData(
              label: 'Opportunity readiness',
              value: 'Strong',
              detail: 'Portfolio and profile signals are ready for review.',
              icon: Icons.work_outline_rounded,
            ),
            _WorkspaceCardData(
              label: 'Relationship follow-ups',
              value: '3',
              detail: 'Sample high-context conversations to revisit.',
              icon: Icons.forum_outlined,
            ),
          ],
          nextSteps: [
            'Refresh one proof asset before your next pitch.',
            'Follow up with a collaborator while the work is top of mind.',
            'Review open opportunities with your strongest fit in mind.',
          ],
        );

      case CreatorWorkspaceKind.workflow:
        return const _WorkspaceContent(
          eyebrow: 'SAMPLE STUDIO WORKFLOW',
          title: 'Move creative work from intent to delivery.',
          detail:
              'A focused planning surface for producing and closing the next piece of work.',
          action: 'Start a session',
          actionIcon: Icons.play_arrow_rounded,
          accent: SpotlightTokens.purple,
          cards: [
            _WorkspaceCardData(
              label: 'Current focus',
              value: 'Launch reel',
              detail: 'Sample priority project for this production cycle.',
              icon: Icons.movie_creation_outlined,
            ),
            _WorkspaceCardData(
              label: 'Next milestone',
              value: 'Draft brief',
              detail: 'Define the audience, deliverable, and approval path.',
              icon: Icons.flag_outlined,
            ),
            _WorkspaceCardData(
              label: 'Work cadence',
              value: '2 blocks',
              detail: 'Sample protected production sessions this week.',
              icon: Icons.timer_outlined,
            ),
          ],
          nextSteps: [
            'Set a concrete deliverable for the next working block.',
            'Collect source assets before you begin production.',
            'Finish with a review note and a clear next handoff.',
          ],
        );

      case CreatorWorkspaceKind.portfolio:
        return const _WorkspaceContent(
          eyebrow: 'SAMPLE PORTFOLIO SIGNALS',
          title: 'Make your best evidence easy to trust.',
          detail:
              'Use this readiness view to keep proof aligned with the work you want next.',
          action: 'Plan proof update',
          actionIcon: Icons.add_photo_alternate_outlined,
          accent: SpotlightTokens.rose,
          cards: [
            _WorkspaceCardData(
              label: 'Portfolio readiness',
              value: '78%',
              detail: 'Sample completeness across profile, reels, and credits.',
              icon: Icons.verified_outlined,
            ),
            _WorkspaceCardData(
              label: 'Featured proof',
              value: '4 items',
              detail: 'Choose proof that matches your target work.',
              icon: Icons.collections_outlined,
            ),
            _WorkspaceCardData(
              label: 'Freshness check',
              value: '1 due',
              detail: 'Refresh your strongest recent work sample.',
              icon: Icons.update_rounded,
            ),
          ],
          nextSteps: [
            'Lead with work that matches your target opportunity category.',
            'Add one concise credit or outcome to each proof asset.',
            'Replace stale examples before sending your next pitch.',
          ],
        );

      case CreatorWorkspaceKind.community:
        return const _WorkspaceContent(
          eyebrow: 'SAMPLE COMMUNITY SIGNALS',
          title: 'Turn attention into durable relationships.',
          detail:
              'A planning view for deciding where your next engagement can matter most.',
          action: 'Open community plan',
          actionIcon: Icons.groups_rounded,
          accent: SpotlightTokens.success,
          cards: [
            _WorkspaceCardData(
              label: 'Member pulse',
              value: 'Healthy',
              detail: 'Sample view of participation and returning attention.',
              icon: Icons.favorite_outline_rounded,
            ),
            _WorkspaceCardData(
              label: 'Conversation prompts',
              value: '2',
              detail: 'Use a timely question to start meaningful discussion.',
              icon: Icons.chat_bubble_outline_rounded,
            ),
            _WorkspaceCardData(
              label: 'Recognition moments',
              value: '1',
              detail: 'Acknowledge a high-intent supporter contribution.',
              icon: Icons.workspace_premium_outlined,
            ),
          ],
          nextSteps: [
            'Publish one discussion prompt that invites a specific response.',
            'Recognize a meaningful supporter contribution.',
            'Capture a community insight to inform your next release.',
          ],
        );

      case CreatorWorkspaceKind.programs:
        return const _WorkspaceContent(
          eyebrow: 'SAMPLE PROGRAMS & SERVICES',
          title: 'Package creative value into repeatable offers.',
          detail:
              'A planning view for shaping how businesses and collaborators engage your work.',
          action: 'Create service outline',
          actionIcon: Icons.auto_awesome_mosaic_outlined,
          accent: SpotlightTokens.warning,
          cards: [
            _WorkspaceCardData(
              label: 'Offer clarity',
              value: 'In progress',
              detail: 'Define the outcome, audience, and delivery model.',
              icon: Icons.lightbulb_outline_rounded,
            ),
            _WorkspaceCardData(
              label: 'Service packages',
              value: '3',
              detail: 'Sample package set from focused to premium engagement.',
              icon: Icons.inventory_2_outlined,
            ),
            _WorkspaceCardData(
              label: 'Onboarding path',
              value: 'Draft',
              detail: 'Map the first conversation through kickoff.',
              icon: Icons.route_outlined,
            ),
          ],
          nextSteps: [
            'Name the client outcome before naming the deliverable.',
            'Define one clear boundary for each service package.',
            'Write the first three steps a client experiences after booking.',
          ],
        );

      case CreatorWorkspaceKind.analytics:
        return const _WorkspaceContent(
          eyebrow: 'SAMPLE PERFORMANCE VIEW',
          title: 'Understand the levers behind sustainable work.',
          detail:
              'Use this planning view to decide which activity deserves attention next.',
          action: 'Review performance view',
          actionIcon: Icons.bar_chart_rounded,
          accent: SpotlightTokens.magenta,
          cards: [
            _WorkspaceCardData(
              label: 'Opportunity funnel',
              value: '6 active',
              detail: 'Sample briefs and relationship paths under review.',
              icon: Icons.filter_alt_outlined,
            ),
            _WorkspaceCardData(
              label: 'Engagement signal',
              value: 'Rising',
              detail: 'Sample indication of response to recent work.',
              icon: Icons.insights_outlined,
            ),
            _WorkspaceCardData(
              label: 'Earnings readiness',
              value: 'Set up',
              detail:
                  'Complete payout and offer details before accepting work.',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ],
          nextSteps: [
            'Review the strongest relationship path before broad outreach.',
            'Compare recent proof assets against your highest-fit work.',
            'Keep payout and service details ready before negotiation.',
          ],
        );

      case CreatorWorkspaceKind.profile:
        return const _WorkspaceContent(
          eyebrow: 'SAMPLE PROFILE READINESS',
          title: 'Keep your professional surface ready.',
          detail:
              'A readiness view for the identity, proof, and preferences others encounter first.',
          action: 'Review profile plan',
          actionIcon: Icons.edit_outlined,
          accent: SpotlightTokens.cyanSoft,
          cards: [
            _WorkspaceCardData(
              label: 'Identity signals',
              value: 'Ready',
              detail: 'Name, positioning, and core creator category are clear.',
              icon: Icons.person_outline_rounded,
            ),
            _WorkspaceCardData(
              label: 'Visibility',
              value: 'Public',
              detail: 'Sample profile visibility for opportunity discovery.',
              icon: Icons.visibility_outlined,
            ),
            _WorkspaceCardData(
              label: 'Verification',
              value: 'Next step',
              detail: 'Add trust signals before higher-stakes opportunities.',
              icon: Icons.verified_user_outlined,
            ),
          ],
          nextSteps: [
            'State the kind of work you want in your first profile sentence.',
            'Review which proof assets are visible to businesses.',
            'Complete the next available verification step.',
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    final isWide = MediaQuery.sizeOf(context).width >= 1040;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WorkspaceHero(
            content: content,
            onPlan: () => _openPlanningSheet(context, content),
          ),
          const SizedBox(height: 16),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: _WorkspaceSignalGrid(content: content),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 7,
                  child: _WorkspaceNextActions(content: content),
                ),
              ],
            )
          else ...[
            _WorkspaceSignalGrid(content: content),
            const SizedBox(height: 16),
            _WorkspaceNextActions(content: content),
          ],
        ],
      ),
    );
  }
}

class _WorkspaceHero extends StatelessWidget {
  const _WorkspaceHero({required this.content, required this.onPlan});

  final _WorkspaceContent content;
  final VoidCallback onPlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SpotlightTokens.border),
        gradient: LinearGradient(
          colors: [
            content.accent.withValues(alpha: 0.18),
            SpotlightTokens.bgSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content.eyebrow,
            style: TextStyle(
              color: content.accent,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: SpotlightTokens.textPrimary,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              content.detail,
              style: const TextStyle(
                color: SpotlightTokens.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onPlan,
            icon: Icon(content.actionIcon, size: 18),
            label: Text(content.action),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceSignalGrid extends StatelessWidget {
  const _WorkspaceSignalGrid({required this.content});

  final _WorkspaceContent content;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    return GridView.count(
      crossAxisCount: isWide ? 3 : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isWide ? 1.18 : 2.55,
      children: [
        for (final card in content.cards)
          _WorkspaceSignalCard(card: card, accent: content.accent),
      ],
    );
  }
}

class _WorkspaceSignalCard extends StatelessWidget {
  const _WorkspaceSignalCard({required this.card, required this.accent});

  final _WorkspaceCardData card;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(card.icon, color: accent, size: 22),
          const Spacer(),
          Text(
            card.label.toUpperCase(),
            style: const TextStyle(
              color: SpotlightTokens.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.value,
            style: const TextStyle(
              color: SpotlightTokens.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SpotlightTokens.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceNextActions extends StatelessWidget {
  const _WorkspaceNextActions({required this.content});

  final _WorkspaceContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEXT BEST ACTIONS',
            style: TextStyle(
              color: content.accent,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < content.nextSteps.length; index++) ...[
            _WorkspaceStep(
              number: index + 1,
              text: content.nextSteps[index],
              accent: content.accent,
            ),
            if (index < content.nextSteps.length - 1)
              const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _WorkspaceStep extends StatelessWidget {
  const _WorkspaceStep({
    required this.number,
    required this.text,
    required this.accent,
  });

  final int number;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            '$number',
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: SpotlightTokens.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkspaceContent {
  const _WorkspaceContent({
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.action,
    required this.actionIcon,
    required this.accent,
    required this.cards,
    required this.nextSteps,
  });

  final String eyebrow;
  final String title;
  final String detail;
  final String action;
  final IconData actionIcon;
  final Color accent;
  final List<_WorkspaceCardData> cards;
  final List<String> nextSteps;
}

class _WorkspaceCardData {
  const _WorkspaceCardData({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
}

Future<void> _openPlanningSheet(
  BuildContext context,
  _WorkspaceContent content,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final completed = <bool>[false, false, false];

      return StatefulBuilder(
        builder: (context, setSheetState) {
          final completedCount = completed.where((value) => value).length;
          final progress = completedCount / completed.length;

          return SafeArea(
            top: false,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.88,
              ),
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
              decoration: const BoxDecoration(
                color: SpotlightTokens.bgSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: SpotlightTokens.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'PLANNING SESSION',
                    style: TextStyle(
                      color: content.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.title,
                    style: const TextStyle(
                      color: SpotlightTokens.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use this checklist to focus your next actions. This planning state is not saved yet.',
                    style: TextStyle(
                      color: SpotlightTokens.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            color: content.accent,
                            backgroundColor: SpotlightTokens.bgElevated,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$completedCount/${completed.length}',
                        style: const TextStyle(
                          color: SpotlightTokens.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.separated(
                      itemCount: content.nextSteps.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          value: completed[index],
                          onChanged: (value) {
                            setSheetState(
                              () => completed[index] = value ?? false,
                            );
                          },
                          activeColor: content.accent,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            content.nextSteps[index],
                            style: TextStyle(
                              color: SpotlightTokens.textPrimary,
                              height: 1.35,
                              decoration: completed[index]
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Done for now'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
