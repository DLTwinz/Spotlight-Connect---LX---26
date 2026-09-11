class CommunityFixtures {
  static const disclosure =
      'Sample fixture community data. Activity, messages, events, access, recognition, and relationship signals are preview-only and do not represent live members or live delivery.';

  static const creatorName = 'Avery Nova';
  static const creatorRole = 'Creator';
  static const pageEyebrow = 'COMMUNITY';
  static const pageTitle = 'Your people, in motion';
  static const pageSubhead = 'Relationships are the real momentum.';
  static const healthLabel = 'Community health';
  static const healthState = 'Strong';
  static const healthDetail =
      'Sample fixture signal. Growing, active, and connected.';
  static const clusterOverflow = '+742';
  static const clusterCaption =
      'Sample supporter cluster. Not live member identities.';
  static const heroMediaCaption =
      'Reference performance still unavailable in this build.';
  static const nextAction = 'Share an update';
  static const nextActionHint =
      'Opens a local preview composer. Does not publish or notify anyone.';

  static const activityFilters = <String>[
    'All activity',
    'Love',
    'Comments',
    'Shares',
    'Access',
  ];

  static const activities = <CommunityActivityFixture>[
    CommunityActivityFixture(
      name: 'Lena Park',
      initials: 'LP',
      action: 'showed love on your update',
      quote: 'Studio session from last night. This one hit different.',
      time: '2h ago · sample',
      kind: CommunityActivityKind.love,
    ),
    CommunityActivityFixture(
      name: 'Jordan Ellis',
      initials: 'JE',
      action: 'commented',
      quote: 'The way this builds… chills every time.',
      time: '4h ago · sample',
      kind: CommunityActivityKind.comment,
    ),
    CommunityActivityFixture(
      name: 'Maya Chen',
      initials: 'MC',
      action: 'shared your track “Weightless”',
      quote: 'to her circle Indie Hearts',
      time: '6h ago · sample',
      kind: CommunityActivityKind.share,
    ),
    CommunityActivityFixture(
      name: 'Riley Brooks',
      initials: 'RB',
      action: 'unlocked Backstage Pass: Seoul',
      quote: 'Access tier · Inner Circle · fixture',
      time: 'Yesterday · sample',
      kind: CommunityActivityKind.access,
    ),
    CommunityActivityFixture(
      name: 'The Late Bloomers',
      initials: 'LB',
      action: 'renewed their membership',
      quote: '12 months · Inner Circle · fixture',
      time: 'Yesterday · sample',
      kind: CommunityActivityKind.membership,
    ),
  ];

  static const circles = <CommunityCircleFixture>[
    CommunityCircleFixture(
      name: 'Inner Circle',
      initials: 'IC',
      members: '642 sample members',
      active: '212 sample active now',
    ),
    CommunityCircleFixture(
      name: "Songwriters' Room",
      initials: 'SR',
      members: '183 sample members',
      active: '47 sample active now',
    ),
    CommunityCircleFixture(
      name: 'Visual Storytellers',
      initials: 'VS',
      members: '128 sample members',
      active: '29 sample active now',
    ),
  ];

  static const events = <CommunityEventFixture>[
    CommunityEventFixture(
      month: 'MAY',
      day: '24',
      title: 'NYC Intimate Session',
      detail: 'Sample access · Inner Circle',
      whenWhere: '6:30 PM ET · Brooklyn, NY',
      going: '32 sample going',
    ),
    CommunityEventFixture(
      month: 'JUN',
      day: '07',
      title: 'The Coastline Listening',
      detail: 'Sample access · All tiers',
      whenWhere: '7:00 PM PT · Los Angeles, CA',
      going: '118 sample going',
    ),
  ];

  static const messages = <CommunityMessageFixture>[
    CommunityMessageFixture(
      from: 'From Kai',
      initials: 'KA',
      preview: 'Loved the new demo—so proud of..',
      time: '2h ago · preview only',
    ),
    CommunityMessageFixture(
      from: 'From The Late Bloomers',
      initials: 'LB',
      preview: "Can't wait for the next session!",
      time: '5h ago · preview only',
    ),
    CommunityMessageFixture(
      from: 'From Nina',
      initials: 'NI',
      preview: 'Quick question about merch drop…',
      time: 'Yesterday · preview only',
    ),
  ];

  static const pulse = <CommunityPulseFixture>[
    CommunityPulseFixture(
      label: 'Sample active supporters',
      value: '1,246',
      delta: '↑ 12% fixture',
    ),
    CommunityPulseFixture(
      label: 'Sample new supporters',
      value: '89',
      delta: '↑ 18% fixture',
    ),
    CommunityPulseFixture(
      label: 'Sample retention (30 days)',
      value: '72%',
      delta: '↑ 6% fixture',
    ),
    CommunityPulseFixture(
      label: 'Sample inner-circle share',
      value: '48%',
      delta: 'Top tier · fixture',
    ),
  ];

  static const alerts = <CommunityAlertFixture>[
    CommunityAlertFixture(
      title: "Haven't heard from Alex in a while",
      detail: 'Last sample interaction 21 days ago',
      action: 'Reach out',
      reason: 'Messaging is unavailable in this build.',
    ),
    CommunityAlertFixture(
      title: "Sofia's birthday is this week",
      detail: 'May 18 · sample calendar row',
      action: 'Send love',
      reason: 'Recognition delivery is unavailable in this build.',
    ),
    CommunityAlertFixture(
      title: 'Maya unlocked 3 tiers',
      detail: 'Celebrate this milestone · fixture',
      action: 'Send note',
      reason: 'Notes are unavailable in this build.',
    ),
  ];

  static const recognitions = <CommunityRecognitionFixture>[
    CommunityRecognitionFixture(
      title: '7 sample birthdays this week',
      detail: 'Send a note or shoutout · preview only',
    ),
    CommunityRecognitionFixture(
      title: '3 sample anniversaries this week',
      detail: 'Celebrate their journey · preview only',
    ),
    CommunityRecognitionFixture(
      title: '5 sample reward opportunities',
      detail: 'Personalize their experience · not issuable here',
    ),
  ];

  static const sentimentTitle = 'How your community feels';
  static const sentimentState = 'Positive';
  static const sentimentScore = '92% sample overall sentiment';
  static const sentimentDelta = '↑ 8% vs last week · fixture';
  static const sentimentCopy =
      'Sample reading only. Your people are feeling inspired and connected in this preview. Keep sharing what feels real.';
}

enum CommunityActivityKind { love, comment, share, access, membership }

class CommunityActivityFixture {
  const CommunityActivityFixture({
    required this.name,
    required this.initials,
    required this.action,
    required this.quote,
    required this.time,
    required this.kind,
  });

  final String name;
  final String initials;
  final String action;
  final String quote;
  final String time;
  final CommunityActivityKind kind;
}

class CommunityCircleFixture {
  const CommunityCircleFixture({
    required this.name,
    required this.initials,
    required this.members,
    required this.active,
  });

  final String name;
  final String initials;
  final String members;
  final String active;
}

class CommunityEventFixture {
  const CommunityEventFixture({
    required this.month,
    required this.day,
    required this.title,
    required this.detail,
    required this.whenWhere,
    required this.going,
  });

  final String month;
  final String day;
  final String title;
  final String detail;
  final String whenWhere;
  final String going;
}

class CommunityMessageFixture {
  const CommunityMessageFixture({
    required this.from,
    required this.initials,
    required this.preview,
    required this.time,
  });

  final String from;
  final String initials;
  final String preview;
  final String time;
}

class CommunityPulseFixture {
  const CommunityPulseFixture({
    required this.label,
    required this.value,
    required this.delta,
  });

  final String label;
  final String value;
  final String delta;
}

class CommunityAlertFixture {
  const CommunityAlertFixture({
    required this.title,
    required this.detail,
    required this.action,
    required this.reason,
  });

  final String title;
  final String detail;
  final String action;
  final String reason;
}

class CommunityRecognitionFixture {
  const CommunityRecognitionFixture({
    required this.title,
    required this.detail,
  });

  final String title;
  final String detail;
}
