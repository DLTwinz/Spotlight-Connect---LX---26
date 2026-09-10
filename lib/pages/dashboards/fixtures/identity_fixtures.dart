class IdentityFixtureState {
  const IdentityFixtureState(this.label);

  final String label;

  static const fixture = IdentityFixtureState('Fixture');
  static const unavailable = IdentityFixtureState('Unavailable');
  static const local = IdentityFixtureState('Local preview');
}

class IdentityAccountFixture {
  const IdentityAccountFixture({
    required this.network,
    required this.status,
    required this.detail,
    required this.actionLabel,
    required this.enabled,
  });

  final String network;
  final String status;
  final String detail;
  final String actionLabel;
  final bool enabled;
}

class IdentityControlItem {
  const IdentityControlItem({
    required this.title,
    required this.detail,
    required this.state,
  });

  final String title;
  final String detail;
  final IdentityFixtureState state;
}

class IdentityFixtures {
  static const disclosure =
      'Sample fixture settings. Changes are local to this preview and do not update identity, privacy, verification, connected accounts, availability, or data preferences.';

  static const creatorName = 'Aria Voss';
  static const creatorRole = 'Creator \u00b7 Identity workspace';
  static const pageEyebrow = 'IDENTITY';
  static const pageTitle = 'Creator Identity & Control Center';
  static const pageSubhead = 'Decide how the world sees you, and who can reach you.';
  static const initials = 'AV';
  static const locationLine = 'Los Angeles \u00b7 Visual artist';
  static const defaultTagline = 'Quiet work. Precise presence.';
  static const defaultBio =
      'Fixture biography for Aria Voss. Used only to preview public-profile hierarchy. Not a live profile record.';

  static const accounts = <IdentityAccountFixture>[
    IdentityAccountFixture(
      network: 'Instagram',
      status: 'Not connected',
      detail: 'Connection setup unavailable in this build.',
      actionLabel: 'Connect account \u2014 coming soon',
      enabled: false,
    ),
    IdentityAccountFixture(
      network: 'YouTube',
      status: 'Example account state',
      detail: 'Fixture status; not a live platform connection.',
      actionLabel: 'Sample connection',
      enabled: false,
    ),
    IdentityAccountFixture(
      network: 'Website',
      status: 'Not connected',
      detail: 'Public site linking is not wired in this preview.',
      actionLabel: 'Add site \u2014 coming soon',
      enabled: false,
    ),
  ];

  static const proofItems = <IdentityControlItem>[
    IdentityControlItem(
      title: 'Sample verification workflow',
      detail:
          'Fixture proof status. Not an identity-verification result and not a government-ID review.',
      state: IdentityFixtureState.fixture,
    ),
    IdentityControlItem(
      title: 'Portfolio proof trail',
      detail: 'Selected-work references stay on Portfolio. This row is preview-only.',
      state: IdentityFixtureState.local,
    ),
  ];

  static const privacyItems = <IdentityControlItem>[
    IdentityControlItem(
      title: 'Data export',
      detail: 'Privacy export is unavailable in this build.',
      state: IdentityFixtureState.unavailable,
    ),
    IdentityControlItem(
      title: 'Session and security center',
      detail: 'Active-session management is not included in this preview.',
      state: IdentityFixtureState.unavailable,
    ),
  ];
}
