import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/models/progression_feature_policy_model.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/supabase/supabase_config.dart';
import 'package:spotlight_connect/theme.dart';
import 'package:spotlight_connect/features/verified_fandom/providers/verified_fandom_providers.dart';

class AdminFeatureControlsTab extends StatefulWidget {
  const AdminFeatureControlsTab({super.key});

  @override
  State<AdminFeatureControlsTab> createState() => _AdminFeatureControlsTabState();
}

class _AdminFeatureControlsTabState extends State<AdminFeatureControlsTab> {
  static const String _defaultOwnerEmail = 'bakertwin9@gmail.com';
  static const _roleKeys = <String>['audience', 'talent', 'business', 'admin'];
  static const _flagKeys = <String>[
    'progression_enabled',
    'missions_enabled',
    'campaigns_enabled',
    'redemptions_enabled',
    'profiles_progression_enabled',
    'momentum_enabled',
    'badges_enabled',
    'storefront_enabled',
    'mission_claims_enabled',
    'reward_fulfillment_enabled',
    'public_profile_progression_enabled',
    'self_profile_progression_enabled',
    'kill_progression_write_paths',
    'kill_mission_claims',
    'kill_redemptions',
    'kill_behavior_event_ingest',
    'kill_campaign_joins',
    'kill_storefront_actions',
  ];

  static const _killSwitchKeys = <String>[
    'kill_progression_write_paths',
    'kill_mission_claims',
    'kill_redemptions',
    'kill_behavior_event_ingest',
    'kill_campaign_joins',
    'kill_storefront_actions',
  ];

  String _selectedRoleKey = 'audience';
  bool _loading = true;
  String? _error;

  Map<String, bool> _policyFlags = <String, bool>{};
  Map<String, bool> _killSwitches = <String, bool>{};

  bool get _canControl {
    final auth = context.read<AppAuthProvider>();
    final user = auth.currentUser;
    if (user == null) return false;
    if (!user.isAdmin) return false;
    const envOwnerEmail = String.fromEnvironment('SPOTLIGHT_ADMIN_OWNER_EMAIL');
    final ownerEmail = envOwnerEmail.trim().isEmpty ? _defaultOwnerEmail : envOwnerEmail;
    return user.email.trim().toLowerCase() == ownerEmail.trim().toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    if (!_canControl) {
      setState(() {
        _loading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final policy = await _loadPolicyForRole(_selectedRoleKey);
      final killSwitches = await _loadKillSwitches();
      if (!mounted) return;
      setState(() {
        _policyFlags = policy;
        _killSwitches = killSwitches;
      });
    } catch (e, st) {
      debugPrint('AdminFeatureControlsTab: load failed: $e\n$st');
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Map<String, bool>> _loadPolicyForRole(String roleKey) async {
    final client = SupabaseConfig.client;
    final row = await client.from('feature_policies').select('policy').eq('role_key', roleKey).maybeSingle();
    final policy = (row == null ? null : row['policy']);
    final out = <String, bool>{};
    if (policy is Map) {
      for (final k in _flagKeys) {
        final v = policy[k];
        if (v is bool) out[k] = v;
        if (v is num) out[k] = v != 0;
        if (v is String) out[k] = v.toLowerCase() == 'true';
      }
    }
    // Defaults when missing.
    for (final k in _flagKeys) {
      out.putIfAbsent(k, () => ProgressionFeaturePolicy.safeFallback().flags[k] ?? false);
    }
    return out;
  }

  Future<Map<String, bool>> _loadKillSwitches() async {
    final client = SupabaseConfig.client;
    final rows = await client.from('kill_switches').select('key,is_enabled').inFilter('key', _killSwitchKeys);
    final out = <String, bool>{for (final k in _killSwitchKeys) k: false};

    for (final r in (rows as List)) {
      if (r is! Map) continue;
      final key = (r['key'] ?? '').toString();
      if (key.isEmpty) continue;
      final enabled = r['is_enabled'];
      if (enabled is bool) out[key] = enabled;
    }
    return out;
  }

  Future<void> _savePolicyFlag(String key, bool enabled) async {
    final vf = context.read<VerifiedFandomProvider>();
    
    // Using the specific API signature to update a flag directly
    final success = await vf.runWriteGuarded(() async {
      await vf.client.setFeaturePolicy(
        policyKey: '${_selectedRoleKey}_$key', 
        enabled: enabled,
        reason: 'Admin dashboard toggle via Flutter',
      );
    });

    if (success) {
      setState(() => _policyFlags[key] = enabled);
      // Removed provider.refresh() if it doesn't exist, otherwise add back if applicable
    } else if (vf.lastError != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vf.lastError!), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  Future<void> _saveKillSwitch(String key, bool enabled) async {
    final vf = context.read<VerifiedFandomProvider>();
    
    final success = await vf.runWriteGuarded(() async {
      await vf.client.setKillSwitch(
        switchKey: key,
        enabled: enabled,
        reason: 'Admin dashboard toggle via Flutter',
      );
    });

    if (success) {
      setState(() => _killSwitches[key] = enabled);
    } else if (vf.lastError != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vf.lastError!), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vf = context.watch<VerifiedFandomProvider>();
    final isProcessing = _loading || vf.isWriting;

    if (!_canControl) {
      const envOwnerEmail = String.fromEnvironment('SPOTLIGHT_ADMIN_OWNER_EMAIL');
      final ownerEmail = envOwnerEmail.trim().isEmpty ? _defaultOwnerEmail : envOwnerEmail;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings_outlined, size: 44, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text('Admin controls are restricted.', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'This panel is locked to the owner account only.\n\nOwner: $ownerEmail',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Text('Feature Controls', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text('Server-authoritative toggles (Supabase).', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onErrorContainer)),
            ),
          if (_error != null) const SizedBox(height: 12),
          _ControlCard(
            title: 'Kill switches',
            subtitle: 'Emergency stop controls (writes + sensitive actions).',
            trailing: isProcessing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : null,
            child: Column(
              children: [
                for (final k in _killSwitchKeys)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _killSwitches[k] ?? false,
                    onChanged: isProcessing ? null : (v) => _saveKillSwitch(k, v),
                    title: Text(k),
                    subtitle: Text('Stored via API: $k', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ControlCard(
            title: 'Progression policy',
            subtitle: 'Enable/disable MRCP surfaces per role.',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: _selectedRoleKey,
                  items: _roleKeys.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: isProcessing
                      ? null
                      : (v) async {
                          if (v == null) return;
                          setState(() => _selectedRoleKey = v);
                          final flags = await _loadPolicyForRole(v);
                          if (!mounted) return;
                          setState(() => _policyFlags = flags);
                        },
                ),
              ],
            ),
            child: Column(
              children: [
                for (final k in _flagKeys)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _policyFlags[k] ?? false,
                    onChanged: isProcessing
                        ? null
                        : (v) => _savePolicyFlag(k, v),
                    title: Text(k),
                    subtitle: Text('feature_policies.role_key=$_selectedRoleKey', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Owner-only: set SPOTLIGHT_ADMIN_OWNER_EMAIL to change the owner email.',
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ControlCard extends StatelessWidget {
  const _ControlCard({required this.title, required this.subtitle, required this.child, this.trailing});
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
