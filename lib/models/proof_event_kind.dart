/// Canonical enum for proof/attribution event kinds.
///
/// All switch expressions on this type MUST handle every case.
/// Add new values here and fix any non_exhaustive_switch_expression
/// errors that the analyzer surfaces.
enum ProofEventKind {
  purchase,
  stream,
  share,
  referral,
  milestone,
  custom;

  String get displayLabel => switch (this) {
    ProofEventKind.purchase => 'Purchase',
    ProofEventKind.stream => 'Stream',
    ProofEventKind.share => 'Share',
    ProofEventKind.referral => 'Referral',
    ProofEventKind.milestone => 'Milestone',
    ProofEventKind.custom => 'Custom',
  };

  String get iconName => switch (this) {
    ProofEventKind.purchase => 'shopping_bag',
    ProofEventKind.stream => 'play_circle',
    ProofEventKind.share => 'share',
    ProofEventKind.referral => 'people',
    ProofEventKind.milestone => 'military_tech',
    ProofEventKind.custom => 'star',
  };
}
