import 'package:flutter/material.dart';
import 'package:spotlight_connect/pages/dashboards/creator_overview_page.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';
import 'package:spotlight_connect/pages/dashboards/creator_opportunities_page.dart';

class CreatorStudioShell extends StatefulWidget {
  const CreatorStudioShell({super.key});

  @override
  State<CreatorStudioShell> createState() => _CreatorStudioShellState();
}

class _CreatorStudioShellState extends State<CreatorStudioShell> {
  static const _items = <_StudioNavItem>[
    _StudioNavItem('Overview', Icons.home_rounded),
    _StudioNavItem('Momentum', Icons.insights_rounded),
    _StudioNavItem('Studio Workflow', Icons.account_tree_outlined),
    _StudioNavItem('Opportunities', Icons.work_outline_rounded),
    _StudioNavItem('Portfolio & Proof', Icons.collections_outlined),
    _StudioNavItem('Community', Icons.groups_outlined),
    _StudioNavItem('Gravity Map', Icons.hub_outlined),
    _StudioNavItem('Programs & Services', Icons.auto_awesome_mosaic_outlined),
    _StudioNavItem('Analytics & Economics', Icons.bar_chart_rounded),
    _StudioNavItem('Profile & Settings', Icons.person_outline_rounded),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1100;
    final selected = _items[_selectedIndex];

    return Scaffold(
      backgroundColor: SpotlightTokens.bgPrimary,
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  _CreatorRail(
                    items: _items,
                    selectedIndex: _selectedIndex,
                    onSelect: (index) => setState(() => _selectedIndex = index),
                  ),
                  Expanded(
                    child: _CreatorCanvas(
                      selectedIndex: _selectedIndex,
                      title: selected.label,
                    ),
                  ),
                ],
              )
            : _CreatorCanvas(
                selectedIndex: _selectedIndex,
                title: selected.label,
              ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex > 4 ? 4 : _selectedIndex,
              onDestinationSelected: (index) {
                const mobileIndexes = [0, 1, 2, 3, 9];
                setState(() => _selectedIndex = mobileIndexes[index]);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Overview',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights_rounded),
                  label: 'Momentum',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_tree_outlined),
                  selectedIcon: Icon(Icons.account_tree_rounded),
                  label: 'Studio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline_rounded),
                  selectedIcon: Icon(Icons.work_rounded),
                  label: 'Opportunities',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}

class _CreatorCanvas extends StatelessWidget {
  const _CreatorCanvas({required this.selectedIndex, required this.title});

  final int selectedIndex;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      child: Column(
        children: [
          _CreatorTopBar(title: title),
          const SizedBox(height: 18),
          Expanded(
            child: selectedIndex == 0
                ? const CreatorOverviewPage()
                : selectedIndex == 3
                ? const CreatorOpportunitiesPage()
                : _WorkspacePlaceholder(title: title),
          ),
        ],
      ),
    );
  }
}

class _CreatorRail extends StatelessWidget {
  const _CreatorRail({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_StudioNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      margin: const EdgeInsets.fromLTRB(14, 14, 0, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Column(
        children: [
          const _BrandBlock(),
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 34,
            backgroundColor: SpotlightTokens.purple,
            child: Text(
              'AJ',
              style: TextStyle(
                color: SpotlightTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Avery Jordan',
            style: TextStyle(
              color: SpotlightTokens.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Filmmaker · LA',
            style: TextStyle(
              color: SpotlightTokens.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) => _RailItem(
                item: items[index],
                selected: selectedIndex == index,
                onTap: () => onSelect(index),
              ),
            ),
          ),
          const _MomentumCard(),
          const SizedBox(height: 10),
          const _RailFooter(
            icon: Icons.dark_mode_outlined,
            label: 'Focus mode',
          ),
          const SizedBox(height: 6),
          const _RailFooter(
            icon: Icons.settings_outlined,
            label: 'Studio settings',
          ),
        ],
      ),
    );
  }
}

class _CreatorTopBar extends StatelessWidget {
  const _CreatorTopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Row(
      children: [
        if (isWide)
          Expanded(
            child: Text(
              title == 'Overview'
                  ? 'Creator Studio: Integrated Creator OS Overview'
                  : 'Creator Studio: $title',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: SpotlightTokens.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        if (isWide) const SizedBox(width: 20),
        Expanded(
          flex: isWide ? 0 : 1,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: SpotlightTokens.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SpotlightTokens.border),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: SpotlightTokens.textSecondary,
                  size: 19,
                ),
                SizedBox(width: 10),
                Text(
                  'Search your studio...',
                  style: TextStyle(
                    color: SpotlightTokens.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (isWide)
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Quick Create'),
          ),
        const SizedBox(width: 8),
        const _HeaderIcon(icon: Icons.notifications_none_rounded),
        const SizedBox(width: 8),
        if (isWide) const _HeaderIcon(icon: Icons.mail_outline_rounded),
      ],
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.auto_awesome_rounded, color: SpotlightTokens.cyan),
        SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SPOTLIGHT',
              style: TextStyle(
                color: SpotlightTokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
            Text(
              'CREATOR STUDIO',
              style: TextStyle(
                color: SpotlightTokens.cyan,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _StudioNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? SpotlightTokens.cyan
        : SpotlightTokens.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? SpotlightTokens.cyan.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? SpotlightTokens.cyan.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: selected
                        ? SpotlightTokens.textPrimary
                        : SpotlightTokens.textSecondary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MomentumCard extends StatelessWidget {
  const _MomentumCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MOMENTUM SCORE',
            style: TextStyle(
              color: SpotlightTokens.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '82',
                style: TextStyle(
                  color: SpotlightTokens.textPrimary,
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  '/100',
                  style: TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Text(
            '↑ 12 pts this week',
            style: TextStyle(
              color: SpotlightTokens.success,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RailFooter extends StatelessWidget {
  const _RailFooter({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: SpotlightTokens.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: SpotlightTokens.textSecondary),
          const SizedBox(width: 9),
          Text(
            label,
            style: const TextStyle(
              color: SpotlightTokens.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        border: Border.all(color: SpotlightTokens.border),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: SpotlightTokens.textSecondary, size: 20),
    );
  }
}

class _WorkspacePlaceholder extends StatelessWidget {
  const _WorkspacePlaceholder({required this.title});

  final String title;

  _WorkspaceSpec get _spec {
    switch (title) {
      case 'Momentum':
        return const _WorkspaceSpec(
          eyebrow: 'CREATOR PULSE',
          headline: 'Turn your strongest signal into your next move.',
          description:
              'See where attention is building, what is converting, and the one action most likely to compound your momentum.',
          primaryAction: 'Review momentum plan',
          actionIcon: Icons.bolt_rounded,
          scoreLabel: 'Momentum score',
          scoreValue: '74',
          scoreDetail: '+8 this week',
          metricOneLabel: 'Profile views',
          metricOneValue: '1,284',
          metricTwoLabel: 'Warm signals',
          metricTwoValue: '18',
          sections: [
            _WorkspaceSectionData(
              'This week’s best moves',
              Icons.auto_awesome_rounded,
              [
                'Refresh your featured reel while visibility is rising',
                'Follow up with 3 collaborators who viewed your profile',
                'Share one proof asset from your latest project',
              ],
            ),
            _WorkspaceSectionData('Signal watch', Icons.insights_rounded, [
              'Short-form film work is drawing the most interest',
              'Two saved opportunities fit your current availability',
              'Your strongest discovery window is Thursday afternoon',
            ]),
          ],
        );

      case 'Studio Workflow':
        return const _WorkspaceSpec(
          eyebrow: 'ACTIVE WORK',
          headline: 'Keep creative work moving without losing the thread.',
          description:
              'A focused command center for deliverables, feedback, deadlines, approvals, and the small actions that protect your reputation.',
          primaryAction: 'Plan this week',
          actionIcon: Icons.calendar_month_rounded,
          scoreLabel: 'On-track work',
          scoreValue: '5',
          scoreDetail: '2 due this week',
          metricOneLabel: 'Open tasks',
          metricOneValue: '12',
          metricTwoLabel: 'Awaiting review',
          metricTwoValue: '3',
          sections: [
            _WorkspaceSectionData('Next up', Icons.checklist_rounded, [
              'Confirm shot list for the brand film — due today',
              'Upload revised treatment for client feedback',
              'Send collaborator call sheet for Friday',
            ]),
            _WorkspaceSectionData(
              'Waiting on others',
              Icons.hourglass_top_rounded,
              [
                'Client approval on final edit direction',
                'Talent release signature from Maya Chen',
                'Deposit confirmation for September booking',
              ],
            ),
          ],
        );

      case 'Opportunities':
        return const _WorkspaceSpec(
          eyebrow: 'MATCHED WORK',
          headline: 'Find the opportunities worth your attention.',
          description:
              'Prioritize high-fit briefs, track active applications, and move quickly while the strongest opportunities are still open.',
          primaryAction: 'Browse matches',
          actionIcon: Icons.explore_rounded,
          scoreLabel: 'Match quality',
          scoreValue: '86%',
          scoreDetail: 'High-fit this week',
          metricOneLabel: 'New matches',
          metricOneValue: '14',
          metricTwoLabel: 'Active applications',
          metricTwoValue: '4',
          sections: [
            _WorkspaceSectionData(
              'High-fit opportunities',
              Icons.stars_rounded,
              [
                'Director needed for a short-form lifestyle campaign',
                'Creator partnership: behind-the-scenes mini-series',
                'Cinematographer for a three-day Los Angeles production',
              ],
            ),
            _WorkspaceSectionData(
              'Application pipeline',
              Icons.account_tree_rounded,
              [
                '2 applications awaiting a client response',
                '1 interview or availability check to schedule',
                '1 saved brief closes within the next 48 hours',
              ],
            ),
          ],
        );

      case 'Portfolio & Proof':
        return const _WorkspaceSpec(
          eyebrow: 'CREDIBILITY ENGINE',
          headline: 'Make your proof easy to trust and impossible to miss.',
          description:
              'Keep the assets that win work current: featured projects, testimonials, case studies, rates, capabilities, and shareable proof.',
          primaryAction: 'Update portfolio',
          actionIcon: Icons.collections_bookmark_rounded,
          scoreLabel: 'Portfolio strength',
          scoreValue: '82%',
          scoreDetail: 'Strong foundation',
          metricOneLabel: 'Featured assets',
          metricOneValue: '9',
          metricTwoLabel: 'Proof gaps',
          metricTwoValue: '2',
          sections: [
            _WorkspaceSectionData(
              'Recommended upgrades',
              Icons.upgrade_rounded,
              [
                'Add one outcome-led case study from recent client work',
                'Request a testimonial from your latest collaborator',
                'Replace your oldest featured reel with current work',
              ],
            ),
            _WorkspaceSectionData('Ready to share', Icons.ios_share_rounded, [
              'Creator one-sheet with selected work and capabilities',
              'Film and commercial reel for new opportunity responses',
              'Rate card and availability summary for warm leads',
            ]),
          ],
        );

      case 'Community':
        return const _WorkspaceSpec(
          eyebrow: 'RELATIONSHIP CAPITAL',
          headline: 'Build the relationships that create repeat work.',
          description:
              'Stay close to collaborators, clients, peers, and communities where trust turns into referrals, partnerships, and better projects.',
          primaryAction: 'Open community',
          actionIcon: Icons.groups_rounded,
          scoreLabel: 'Relationship health',
          scoreValue: '71',
          scoreDetail: 'Growing steadily',
          metricOneLabel: 'Warm connections',
          metricOneValue: '36',
          metricTwoLabel: 'New conversations',
          metricTwoValue: '7',
          sections: [
            _WorkspaceSectionData('Stay in motion', Icons.forum_rounded, [
              'Reply to two collaborator check-ins',
              'Welcome three new contacts from your recent project',
              'Share a useful production resource with your circle',
            ]),
            _WorkspaceSectionData('Community signals', Icons.campaign_rounded, [
              'A producer in your network is staffing next month',
              'Your filmmaking group has two active collaboration calls',
              'Three peers recently engaged with your featured work',
            ]),
          ],
        );

      case 'Gravity Map':
        return const _WorkspaceSpec(
          eyebrow: 'NETWORK INTELLIGENCE',
          headline: 'See where trust, access, and opportunity converge.',
          description:
              'Use your relationship graph to identify warm paths, strategic connectors, and communities that can pull your next project closer.',
          primaryAction: 'Explore connections',
          actionIcon: Icons.hub_rounded,
          scoreLabel: 'Network gravity',
          scoreValue: '68',
          scoreDetail: '3 strong paths found',
          metricOneLabel: 'Strategic connectors',
          metricOneValue: '8',
          metricTwoLabel: 'Warm introductions',
          metricTwoValue: '5',
          sections: [
            _WorkspaceSectionData('Best warm paths', Icons.route_rounded, [
              'Reconnect with a producer connected to two target brands',
              'Ask your recent director collaborator for one introduction',
              'Join the upcoming local creator production meetup',
            ]),
            _WorkspaceSectionData(
              'Network opportunities',
              Icons.radar_rounded,
              [
                'Your commercial-work cluster is growing fastest',
                'Three second-degree contacts match your next target role',
                'One trusted connector can unlock two active briefs',
              ],
            ),
          ],
        );

      case 'Programs & Services':
        return const _WorkspaceSpec(
          eyebrow: 'CREATOR ADVANTAGE',
          headline: 'Use the support designed to accelerate your next chapter.',
          description:
              'Access programs, practical services, expert support, and growth pathways that help turn ambition into reliable progress.',
          primaryAction: 'Explore programs',
          actionIcon: Icons.auto_awesome_mosaic_rounded,
          scoreLabel: 'Growth path',
          scoreValue: '3',
          scoreDetail: 'Programs recommended',
          metricOneLabel: 'Available services',
          metricOneValue: '11',
          metricTwoLabel: 'Saved resources',
          metricTwoValue: '4',
          sections: [
            _WorkspaceSectionData(
              'Recommended for you',
              Icons.recommend_rounded,
              [
                'Portfolio review for filmmakers preparing for brand work',
                'Negotiation support for your next paid collaboration',
                'Creator growth cohort focused on repeatable client pipelines',
              ],
            ),
            _WorkspaceSectionData(
              'Practical support',
              Icons.handshake_rounded,
              [
                'Contract and invoicing resources for independent creators',
                'Availability planning and project pricing guidance',
                'Production-ready templates for briefs and project scopes',
              ],
            ),
          ],
        );

      case 'Analytics & Economics':
        return const _WorkspaceSpec(
          eyebrow: 'CREATOR ECONOMICS',
          headline: 'Make decisions from traction, not guesswork.',
          description:
              'Translate attention, activity, conversion, and revenue signals into a clearer picture of what is working—and what deserves your time.',
          primaryAction: 'Review performance',
          actionIcon: Icons.query_stats_rounded,
          scoreLabel: 'Business health',
          scoreValue: '76',
          scoreDetail: '+6 this month',
          metricOneLabel: 'Pipeline value',
          metricOneValue: r'$8.4k',
          metricTwoLabel: 'Response rate',
          metricTwoValue: '31%',
          sections: [
            _WorkspaceSectionData(
              'What is working',
              Icons.trending_up_rounded,
              [
                'Profile discovery improved after your last proof update',
                'Warm outreach is converting better than cold applications',
                'Film and branded-content work leads your current pipeline',
              ],
            ),
            _WorkspaceSectionData('Watch next', Icons.visibility_rounded, [
              'Follow up on opportunities where intent remains active',
              'Reduce time between inquiry and first response',
              'Package your strongest services around proven demand',
            ]),
          ],
        );

      case 'Profile & Settings':
        return const _WorkspaceSpec(
          eyebrow: 'DISCOVERY FOUNDATION',
          headline: 'Make it easy for the right people to choose you.',
          description:
              'Strengthen the profile, availability, capabilities, and privacy choices that determine how you appear across the Spotlight ecosystem.',
          primaryAction: 'Edit profile',
          actionIcon: Icons.edit_outlined,
          scoreLabel: 'Profile readiness',
          scoreValue: '88%',
          scoreDetail: 'Nearly complete',
          metricOneLabel: 'Search readiness',
          metricOneValue: 'High',
          metricTwoLabel: 'Open updates',
          metricTwoValue: '3',
          sections: [
            _WorkspaceSectionData(
              'Finish these updates',
              Icons.task_alt_rounded,
              [
                'Add current availability for the next 60 days',
                'Confirm your preferred project categories and rates',
                'Choose a new featured work sample for discovery',
              ],
            ),
            _WorkspaceSectionData(
              'Visibility controls',
              Icons.shield_outlined,
              [
                'Profile is visible to approved opportunity partners',
                'Your location is displayed as Los Angeles, California',
                'Notifications are enabled for high-fit opportunity matches',
              ],
            ),
          ],
        );

      default:
        return const _WorkspaceSpec(
          eyebrow: 'CREATOR STUDIO',
          headline: 'A focused place to move your creative career forward.',
          description:
              'Organize the information, relationships, projects, and opportunities that matter most to your next step.',
          primaryAction: 'Get started',
          actionIcon: Icons.arrow_forward_rounded,
          scoreLabel: 'Studio status',
          scoreValue: 'Ready',
          scoreDetail: 'Build your next move',
          metricOneLabel: 'Priority items',
          metricOneValue: '0',
          metricTwoLabel: 'Open actions',
          metricTwoValue: '0',
          sections: [
            _WorkspaceSectionData('Start here', Icons.rocket_launch_outlined, [
              'Set your next goal and choose the work that matters most.',
            ]),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = _spec;
    final isWide = MediaQuery.sizeOf(context).width >= 840;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WorkspaceHero(spec: spec),
            const SizedBox(height: 18),
            if (isWide)
              Row(
                children: [
                  Expanded(
                    child: _WorkspaceMetricCard(
                      label: spec.scoreLabel,
                      value: spec.scoreValue,
                      detail: spec.scoreDetail,
                      icon: Icons.bolt_rounded,
                      accent: SpotlightTokens.purple,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _WorkspaceMetricCard(
                      label: spec.metricOneLabel,
                      value: spec.metricOneValue,
                      detail: 'Current studio snapshot',
                      icon: Icons.visibility_outlined,
                      accent: Colors.lightBlueAccent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _WorkspaceMetricCard(
                      label: spec.metricTwoLabel,
                      value: spec.metricTwoValue,
                      detail: 'Actionable right now',
                      icon: Icons.auto_awesome_rounded,
                      accent: Colors.orangeAccent,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _WorkspaceMetricCard(
                    label: spec.scoreLabel,
                    value: spec.scoreValue,
                    detail: spec.scoreDetail,
                    icon: Icons.bolt_rounded,
                    accent: SpotlightTokens.purple,
                  ),
                  const SizedBox(height: 12),
                  _WorkspaceMetricCard(
                    label: spec.metricOneLabel,
                    value: spec.metricOneValue,
                    detail: 'Current studio snapshot',
                    icon: Icons.visibility_outlined,
                    accent: Colors.lightBlueAccent,
                  ),
                  const SizedBox(height: 12),
                  _WorkspaceMetricCard(
                    label: spec.metricTwoLabel,
                    value: spec.metricTwoValue,
                    detail: 'Actionable right now',
                    icon: Icons.auto_awesome_rounded,
                    accent: Colors.orangeAccent,
                  ),
                ],
              ),
            const SizedBox(height: 18),
            for (final section in spec.sections) ...[
              _WorkspaceSection(section: section),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkspaceSpec {
  const _WorkspaceSpec({
    required this.eyebrow,
    required this.headline,
    required this.description,
    required this.primaryAction,
    required this.actionIcon,
    required this.scoreLabel,
    required this.scoreValue,
    required this.scoreDetail,
    required this.metricOneLabel,
    required this.metricOneValue,
    required this.metricTwoLabel,
    required this.metricTwoValue,
    required this.sections,
  });

  final String eyebrow;
  final String headline;
  final String description;
  final String primaryAction;
  final IconData actionIcon;
  final String scoreLabel;
  final String scoreValue;
  final String scoreDetail;
  final String metricOneLabel;
  final String metricOneValue;
  final String metricTwoLabel;
  final String metricTwoValue;
  final List<_WorkspaceSectionData> sections;
}

class _WorkspaceSectionData {
  const _WorkspaceSectionData(this.title, this.icon, this.items);

  final String title;
  final IconData icon;
  final List<String> items;
}

class _WorkspaceHero extends StatelessWidget {
  const _WorkspaceHero({required this.spec});

  final _WorkspaceSpec spec;

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
            SpotlightTokens.purple.withValues(alpha: 0.17),
            SpotlightTokens.bgSurface,
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
            spec.eyebrow,
            style: const TextStyle(
              color: SpotlightTokens.purple,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            spec.headline,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: SpotlightTokens.textPrimary,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(
              spec.description,
              style: const TextStyle(
                color: SpotlightTokens.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {},
            icon: Icon(spec.actionIcon),
            label: Text(spec.primaryAction),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceMetricCard extends StatelessWidget {
  const _WorkspaceMetricCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;

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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: SpotlightTokens.textPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 11,
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

class _WorkspaceSection extends StatelessWidget {
  const _WorkspaceSection({required this.section});

  final _WorkspaceSectionData section;

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
          Row(
            children: [
              Icon(section.icon, color: SpotlightTokens.purple, size: 20),
              const SizedBox(width: 9),
              Text(
                section.title,
                style: const TextStyle(
                  color: SpotlightTokens.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in section.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: SpotlightTokens.purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: SpotlightTokens.textSecondary,
                        height: 1.35,
                      ),
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

class _StudioNavItem {
  const _StudioNavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
