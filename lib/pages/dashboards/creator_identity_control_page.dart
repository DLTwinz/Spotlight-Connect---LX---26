import 'package:flutter/material.dart';
import 'package:spotlight_connect/pages/dashboards/fixtures/identity_fixtures.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';

class CreatorIdentityControlPage extends StatefulWidget {
  const CreatorIdentityControlPage({super.key});

  @override
  State<CreatorIdentityControlPage> createState() =>
      _CreatorIdentityControlPageState();
}

class _CreatorIdentityControlPageState
    extends State<CreatorIdentityControlPage> {
  late final TextEditingController _name;
  late final TextEditingController _tagline;
  late final TextEditingController _bio;
  bool _publicProfile = true;
  bool _allowDirectContact = false;
  bool _showLocation = true;
  String _availability = 'Preview only';
  bool _notifyCollaborations = true;
  bool _notifyCommunity = false;
  bool _unsaved = false;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: IdentityFixtures.creatorName);
    _tagline = TextEditingController(text: IdentityFixtures.defaultTagline);
    _bio = TextEditingController(text: IdentityFixtures.defaultBio);
    for (final controller in [_name, _tagline, _bio]) {
      controller.addListener(_markUnsaved);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _tagline.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _markUnsaved() {
    if (_restoring || _unsaved) return;
    setState(() => _unsaved = true);
  }

  void _setUnsaved(VoidCallback change) {
    setState(() {
      change();
      _unsaved = true;
    });
  }

  void _save() {
    setState(() => _unsaved = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(IdentityFixtures.disclosure)),
    );
  }

  void _discard() {
    _restoring = true;
    setState(() {
      _name.text = IdentityFixtures.creatorName;
      _tagline.text = IdentityFixtures.defaultTagline;
      _bio.text = IdentityFixtures.defaultBio;
      _publicProfile = true;
      _allowDirectContact = false;
      _showLocation = true;
      _availability = 'Preview only';
      _notifyCollaborations = true;
      _notifyCommunity = false;
      _unsaved = false;
    });
    _restoring = false;
  }

  void _explain(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    return Semantics(
      label: 'Creator Identity and Control Center',
      child: ColoredBox(
        color: SpotlightTokens.bgPrimary,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _PreviewColumn(name: _name.text, tagline: _tagline.text, bio: _bio.text, publicProfile: _publicProfile)),
                          const SizedBox(width: 18),
                          Expanded(flex: 8, child: _buildControls()),
                        ],
                      )
                    : Column(
                        children: [
                          _PreviewColumn(name: _name.text, tagline: _tagline.text, bio: _bio.text, publicProfile: _publicProfile),
                          const SizedBox(height: 16),
                          _buildControls(),
                        ],
                      ),
              ),
            ),
            _Footer(unsaved: _unsaved, onSave: _save, onDiscard: _discard),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return _ControlsColumn(
      name: _name,
      tagline: _tagline,
      bio: _bio,
      publicProfile: _publicProfile,
      allowDirectContact: _allowDirectContact,
      showLocation: _showLocation,
      availability: _availability,
      notifyCollaborations: _notifyCollaborations,
      notifyCommunity: _notifyCommunity,
      onPublicProfile: (value) => _setUnsaved(() => _publicProfile = value),
      onDirectContact: (value) => _setUnsaved(() => _allowDirectContact = value),
      onShowLocation: (value) => _setUnsaved(() => _showLocation = value),
      onAvailability: (value) => _setUnsaved(() => _availability = value),
      onNotifyCollaborations: (value) => _setUnsaved(() => _notifyCollaborations = value),
      onNotifyCommunity: (value) => _setUnsaved(() => _notifyCommunity = value),
      onExplain: _explain,
    );
  }
}

class _PreviewColumn extends StatelessWidget {
  const _PreviewColumn({required this.name, required this.tagline, required this.bio, required this.publicProfile});
  final String name;
  final String tagline;
  final String bio;
  final bool publicProfile;
  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(IdentityFixtures.pageEyebrow, style: TextStyle(color: SpotlightTokens.cyan, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
          const SizedBox(height: 8),
          const Text(IdentityFixtures.pageTitle, style: TextStyle(color: SpotlightTokens.textPrimary, fontSize: 24, fontWeight: FontWeight.w800, height: 1.15)),
          const SizedBox(height: 8),
          const Text(IdentityFixtures.pageSubhead, style: TextStyle(color: SpotlightTokens.textSecondary, fontSize: 13, height: 1.4)),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Semantics(
              label: 'Neutral public profile frame for Aria Voss',
              child: DecoratedBox(
                decoration: BoxDecoration(color: SpotlightTokens.bgElevated, borderRadius: BorderRadius.circular(22), border: Border.all(color: SpotlightTokens.border)),
                child: const Center(child: Text(IdentityFixtures.initials, style: TextStyle(color: SpotlightTokens.cyan, fontSize: 42, fontWeight: FontWeight.w800))),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(color: SpotlightTokens.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(IdentityFixtures.creatorRole, style: TextStyle(color: SpotlightTokens.textMuted, fontSize: 12)),
          const SizedBox(height: 8),
          Text(tagline, style: const TextStyle(color: SpotlightTokens.textSecondary, fontSize: 14, height: 1.35)),
          const SizedBox(height: 10),
          Text(bio, style: const TextStyle(color: SpotlightTokens.textSecondary, fontSize: 12, height: 1.45)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _SoftChip(label: publicProfile ? 'Public preview on' : 'Public preview off'),
            const _SoftChip(label: IdentityFixtures.locationLine),
            const _SoftChip(label: 'Fixture profile'),
          ]),
        ],
      ),
    );
  }
}

class _ControlsColumn extends StatelessWidget {
  const _ControlsColumn({
    required this.name, required this.tagline, required this.bio,
    required this.publicProfile, required this.allowDirectContact, required this.showLocation,
    required this.availability, required this.notifyCollaborations, required this.notifyCommunity,
    required this.onPublicProfile, required this.onDirectContact, required this.onShowLocation,
    required this.onAvailability, required this.onNotifyCollaborations, required this.onNotifyCommunity,
    required this.onExplain,
  });
  final TextEditingController name;
  final TextEditingController tagline;
  final TextEditingController bio;
  final bool publicProfile;
  final bool allowDirectContact;
  final bool showLocation;
  final String availability;
  final bool notifyCollaborations;
  final bool notifyCommunity;
  final ValueChanged<bool> onPublicProfile;
  final ValueChanged<bool> onDirectContact;
  final ValueChanged<bool> onShowLocation;
  final ValueChanged<String> onAvailability;
  final ValueChanged<bool> onNotifyCollaborations;
  final ValueChanged<bool> onNotifyCommunity;
  final ValueChanged<String> onExplain;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _NumberedSection(index: '01', title: 'Identity & positioning', child: Column(children: [
        _Field(label: 'Display name', controller: name),
        const SizedBox(height: 10),
        _Field(label: 'Tagline', controller: tagline),
        const SizedBox(height: 10),
        _Field(label: 'Public biography', controller: bio, maxLines: 4),
      ])),
      const SizedBox(height: 12),
      _NumberedSection(index: '02', title: 'Verification & proof', child: Column(children: [
        ...IdentityFixtures.proofItems.map(_StatusRow.new),
        const SizedBox(height: 8),
        _DisabledAction(label: 'Start verification review', reason: 'Review workflow unavailable in this build.', onTap: () => onExplain('Review workflow unavailable in this build. Not an identity-verification result.')),
      ])),
      const SizedBox(height: 12),
      _NumberedSection(index: '03', title: 'Connected accounts', child: Column(children: [
        ...IdentityFixtures.accounts.map((account) => _AccountRow(account: account, onTap: () => onExplain(account.detail))),
      ])),
      const SizedBox(height: 12),
      _NumberedSection(index: '04', title: 'Visibility & contact rules', child: Column(children: [
        _ToggleRow(label: 'Show public preview', value: publicProfile, onChanged: onPublicProfile),
        _ToggleRow(label: 'Allow direct contact requests', value: allowDirectContact, onChanged: onDirectContact),
        _ToggleRow(label: 'Show location line', value: showLocation, onChanged: onShowLocation),
      ])),
      const SizedBox(height: 12),
      _NumberedSection(index: '05', title: 'Availability & booking', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final option in const ['Preview only', 'Limited inquiry window', 'Not bookable here'])
            ChoiceChip(label: Text(option), selected: availability == option, onSelected: (_) => onAvailability(option)),
        ]),
        const SizedBox(height: 10),
        _DisabledAction(label: 'Connect booking system', reason: 'Booking-system connection is unavailable in this build.', onTap: () => onExplain('Booking-system connection is unavailable in this build.')),
      ])),
      const SizedBox(height: 12),
      _NumberedSection(index: '06', title: 'Notifications', child: Column(children: [
        _ToggleRow(label: 'Collaboration briefs', value: notifyCollaborations, onChanged: onNotifyCollaborations),
        _ToggleRow(label: 'Community activity', value: notifyCommunity, onChanged: onNotifyCommunity),
      ])),
      const SizedBox(height: 12),
      _NumberedSection(index: '07', title: 'Privacy & data', child: Column(children: [
        ...IdentityFixtures.privacyItems.map(_StatusRow.new),
        const SizedBox(height: 8),
        _DisabledAction(label: 'Request data export', reason: 'Privacy export is unavailable in this build.', onTap: () => onExplain('Privacy export is unavailable in this build.')),
      ])),
      const SizedBox(height: 14),
      const Text(IdentityFixtures.disclosure, style: TextStyle(color: SpotlightTokens.textMuted, fontSize: 11, height: 1.4)),
    ]);
  }
}

class _NumberedSection extends StatelessWidget {
  const _NumberedSection({required this.index, required this.title, required this.child});
  final String index; final String title; final Widget child;
  @override
  Widget build(BuildContext context) {
    return _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(index, style: const TextStyle(color: SpotlightTokens.cyan, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(color: SpotlightTokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w700))),
      ]),
      const SizedBox(height: 12), child,
    ]));
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller, this.maxLines = 1});
  final String label; final TextEditingController controller; final int maxLines;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, maxLines: maxLines,
      style: const TextStyle(color: SpotlightTokens.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: SpotlightTokens.textMuted, fontSize: 12),
        filled: true, fillColor: SpotlightTokens.bgElevated,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SpotlightTokens.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SpotlightTokens.border)),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.label, required this.value, required this.onChanged});
  final String label; final bool value; final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: Text(label, style: const TextStyle(color: SpotlightTokens.textPrimary, fontSize: 13)), value: value, onChanged: onChanged);
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(this.item);
  final IdentityControlItem item;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.title, style: const TextStyle(color: SpotlightTokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(item.detail, style: const TextStyle(color: SpotlightTokens.textSecondary, fontSize: 11, height: 1.35)),
      ])),
      const SizedBox(width: 8), _SoftChip(label: item.state.label),
    ]));
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.account, required this.onTap});
  final IdentityAccountFixture account; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(account.network, style: const TextStyle(color: SpotlightTokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text('${account.status} \u00b7 ${account.detail}', style: const TextStyle(color: SpotlightTokens.textSecondary, fontSize: 11, height: 1.35)),
      ])),
      Flexible(child: TextButton(onPressed: onTap, child: Text(account.actionLabel, maxLines: 2, overflow: TextOverflow.ellipsis))),
    ]));
  }
}

class _DisabledAction extends StatelessWidget {
  const _DisabledAction({required this.label, required this.reason, required this.onTap});
  final String label; final String reason; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.centerLeft, child: OutlinedButton(onPressed: onTap, child: Text('$label \u2014 $reason')));
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.unsaved, required this.onSave, required this.onDiscard});
  final bool unsaved; final VoidCallback onSave; final VoidCallback onDiscard;
  @override
  Widget build(BuildContext context) {
    return Material(color: SpotlightTokens.bgSurface, child: SafeArea(top: false, child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
      child: Row(children: [
        Expanded(child: Text(unsaved ? 'Unsaved local preview changes' : 'No local changes', style: const TextStyle(color: SpotlightTokens.textSecondary, fontSize: 12))),
        TextButton(onPressed: onDiscard, child: const Text('Discard')),
        const SizedBox(width: 8),
        FilledButton(onPressed: unsaved ? onSave : null, child: const Text('Save changes')),
      ]),
    )));
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: SpotlightTokens.bgElevated, borderRadius: BorderRadius.circular(999), border: Border.all(color: SpotlightTokens.border)),
      child: Text(label, style: const TextStyle(color: SpotlightTokens.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
    );
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
