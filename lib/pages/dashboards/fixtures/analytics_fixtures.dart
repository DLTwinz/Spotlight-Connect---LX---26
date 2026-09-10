class AnalyticsFixtureState {
  const AnalyticsFixtureState(this.label);

  final String label;

  static const verified = AnalyticsFixtureState('Verified');
  static const estimated = AnalyticsFixtureState('Estimated');
  static const pending = AnalyticsFixtureState('Pending');
}

class AnalyticsKpiFixture {
  const AnalyticsKpiFixture({
    required this.label,
    required this.value,
    required this.detail,
    required this.state,
  });

  final String label;
  final String value;
  final String detail;
  final AnalyticsFixtureState state;
}

class AnalyticsPulsePoint {
  const AnalyticsPulsePoint(this.label, this.activity, this.pipeline);

  final String label;
  final double activity;
  final double pipeline;
}

class AnalyticsSourceMix {
  const AnalyticsSourceMix({
    required this.label,
    required this.share,
    required this.state,
  });

  final String label;
  final double share;
  final AnalyticsFixtureState state;
}

class AnalyticsRowFixture {
  const AnalyticsRowFixture({
    required this.title,
    required this.detail,
    required this.metric,
    required this.state,
  });

  final String title;
  final String detail;
  final String metric;
  final AnalyticsFixtureState state;
}

class AnalyticsFixtures {
  static const disclosure =
      'Sample fixture data. Not live financial, payout, settlement, tax, or connected-source data.';

  static const creatorName = 'Mira Solis';
  static const creatorRole = 'Creator · Analytics workspace';
  static const pageEyebrow = 'ANALYTICS';
  static const pageTitle = 'Creator Analytics & Economics';
  static const pageSubhead = 'See what is moving your world';

  static const kpis = <AnalyticsKpiFixture>[
    AnalyticsKpiFixture(
      label: 'REPORTED EARNINGS',
      value: '\$12.4K',
      detail: 'Fixture sample · 30-day window',
      state: AnalyticsFixtureState.estimated,
    ),
    AnalyticsKpiFixture(
      label: 'PIPELINE',
      value: '\$8.1K',
      detail: 'Fixture sample · open conversations',
      state: AnalyticsFixtureState.pending,
    ),
    AnalyticsKpiFixture(
      label: 'SUPPORTER QUALITY',
      value: '72',
      detail: 'Fixture sample · returning attention',
      state: AnalyticsFixtureState.verified,
    ),
  ];

  static const dailyPulse = <AnalyticsPulsePoint>[
    AnalyticsPulsePoint('May 1', 0.28, 0.18),
    AnalyticsPulsePoint('May 8', 0.42, 0.26),
    AnalyticsPulsePoint('May 15', 0.38, 0.33),
    AnalyticsPulsePoint('May 22', 0.61, 0.41),
    AnalyticsPulsePoint('May 31', 0.74, 0.48),
  ];

  static const weeklyPulse = <AnalyticsPulsePoint>[
    AnalyticsPulsePoint('W1', 0.32, 0.20),
    AnalyticsPulsePoint('W2', 0.44, 0.29),
    AnalyticsPulsePoint('W3', 0.58, 0.37),
    AnalyticsPulsePoint('W4', 0.70, 0.46),
  ];

  static const cumulativePulse = <AnalyticsPulsePoint>[
    AnalyticsPulsePoint('May 1', 0.20, 0.14),
    AnalyticsPulsePoint('May 8', 0.34, 0.22),
    AnalyticsPulsePoint('May 15', 0.49, 0.31),
    AnalyticsPulsePoint('May 22', 0.63, 0.40),
    AnalyticsPulsePoint('May 31', 0.78, 0.52),
  ];

  static const sources = <AnalyticsSourceMix>[
    AnalyticsSourceMix(
      label: 'Campaigns',
      share: 0.38,
      state: AnalyticsFixtureState.estimated,
    ),
    AnalyticsSourceMix(
      label: 'Programs',
      share: 0.27,
      state: AnalyticsFixtureState.pending,
    ),
    AnalyticsSourceMix(
      label: 'Portfolio',
      share: 0.21,
      state: AnalyticsFixtureState.verified,
    ),
    AnalyticsSourceMix(
      label: 'Community',
      share: 0.14,
      state: AnalyticsFixtureState.estimated,
    ),
  ];

  static const campaigns = <AnalyticsRowFixture>[
    AnalyticsRowFixture(
      title: 'Spring residency brief',
      detail: 'Collaboration sample · brand conversation',
      metric: '+18%',
      state: AnalyticsFixtureState.estimated,
    ),
    AnalyticsRowFixture(
      title: 'City-lights short',
      detail: 'Campaign sample · cut-down performance',
      metric: '+11%',
      state: AnalyticsFixtureState.pending,
    ),
  ];

  static const programs = <AnalyticsRowFixture>[
    AnalyticsRowFixture(
      title: 'Mentorship circle',
      detail: 'Program sample · conversion to booked work',
      metric: '34%',
      state: AnalyticsFixtureState.estimated,
    ),
    AnalyticsRowFixture(
      title: 'Studio office hours',
      detail: 'Program sample · repeat attendance',
      metric: '61%',
      state: AnalyticsFixtureState.verified,
    ),
  ];

  static const portfolio = <AnalyticsRowFixture>[
    AnalyticsRowFixture(
      title: 'Selected work reel',
      detail: 'Portfolio sample · inbound conversation rate',
      metric: '22%',
      state: AnalyticsFixtureState.estimated,
    ),
    AnalyticsRowFixture(
      title: 'Still series: After Hours',
      detail: 'Portfolio sample · save-to-inquiry path',
      metric: '9%',
      state: AnalyticsFixtureState.pending,
    ),
  ];

  static const insights = <String>[
    'Fixture: short-form proof is carrying more conversation quality than long-form this window.',
    'Fixture: two pending briefs need availability confirmation before the next pulse rise.',
    'Fixture: returning supporters cluster around Thursday drops.',
  ];
}
