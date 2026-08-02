import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/providers/feature_flag_provider.dart';
import 'package:spotlight_connect/providers/progression_feature_policy_provider.dart';
import 'package:spotlight_connect/theme.dart';

class FeatureFlagsSheet extends StatefulWidget {
  const FeatureFlagsSheet({super.key});

  /// Opens the internal feature flags panel.
  ///
  /// By default this is blocked in release builds.
  ///
  /// Set [allowInRelease] to true only for admin-only entry points.
  static Future<void> show(
    BuildContext context, {
    bool allowInRelease = false,
  }) async {
    // Launch policy: keep feature flags invisible to normal users.
    if (kReleaseMode && !allowInRelease) {
      debugPrint('FeatureFlagsSheet blocked in release mode.');
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const FeatureFlagsSheet(),
    );
  }

  @override
  State<FeatureFlagsSheet> createState() => _FeatureFlagsSheetState();
}

class _FeatureFlagsSheetState extends State<FeatureFlagsSheet> {
  final _unlockCtrl = TextEditingController();
  bool _unlocking = false;
  String? _unlockError;

  @override
  void dispose() {
    _unlockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<FeatureFlagProvider>();
    final auth = context.watch<AppAuthProvider>();
    final isAdmin = auth.isAdmin;

    final canEdit = provider.editingUnlocked;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetHeader(canEdit: canEdit),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    children: [
                      Text(
                        'Toggle feature availability for QA/beta testing. These switches affect UI visibility only (not security).',
                        style: theme.textTheme.bodyMedium?.withColor(
                          theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const _ProgressionPolicyStatusCard(),
                      const SizedBox(height: AppSpacing.md),
                      for (final d in FeatureFlagProvider.descriptors)
                        _FeatureRow(
                          descriptor: d,
                          enabled: provider.isEnabled(d.feature),
                          canEdit: canEdit,
                          isAdmin: isAdmin,
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      _UnlockPanel(
                        canEdit: canEdit,
                        unlocking: _unlocking,
                        unlockError: _unlockError,
                        controller: _unlockCtrl,
                        onUnlock: () async {
                          setState(() {
                            _unlocking = true;
                            _unlockError = null;
                          });
                          try {
                            final ok = await context
                                .read<FeatureFlagProvider>()
                                .unlockEditing(_unlockCtrl.text);
                            if (!mounted) return;
                            if (!ok) {
                              setState(() => _unlockError = 'Invalid code.');
                            } else {
                              setState(() => _unlockCtrl.clear());
                            }
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _unlockError = e.toString());
                          } finally {
                            if (mounted) setState(() => _unlocking = false);
                          }
                        },
                        onLock: () async {
                          await context
                              .read<FeatureFlagProvider>()
                              .lockEditing();
                        },
                      ),
                      if (provider.lastError != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Warning: ${provider.lastError}',
                          style: theme.textTheme.bodySmall?.withColor(
                            theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ],
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

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.canEdit});

  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.22),
              ),
            ),
            child: Icon(Icons.tune, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Features', style: theme.textTheme.titleLarge?.bold),
                const SizedBox(height: 2),
                Text(
                  canEdit ? 'Editing unlocked' : 'Read-only (unlock to edit)',
                  style: theme.textTheme.bodySmall?.withColor(
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (canEdit)
            PopupMenuButton<String>(
              tooltip: 'Actions',
              splashRadius: 22,
              onSelected: (v) async {
                final provider = context.read<FeatureFlagProvider>();
                if (v == 'enable_all') {
                  await provider.setAllEnabled(true);
                } else if (v == 'disable_all') {
                  await provider.setAllEnabled(false);
                } else if (v == 'defaults') {
                  await provider.resetToDefaults();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'enable_all',
                  child: Text('Enable all'),
                ),
                const PopupMenuItem(
                  value: 'disable_all',
                  child: Text('Disable all'),
                ),
                const PopupMenuItem(
                  value: 'defaults',
                  child: Text('Reset to defaults'),
                ),
              ],
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.18,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.35,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.more_horiz,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.descriptor,
    required this.enabled,
    required this.canEdit,
    required this.isAdmin,
  });

  final AppFeatureDescriptor descriptor;
  final bool enabled;
  final bool canEdit;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Launch policy: the flags UI is primarily for QA.
    // Hide internal labels/badges unless editing is explicitly unlocked.
    final provider = context.watch<FeatureFlagProvider>();
    final showInternalLabels = provider.editingUnlocked;

    final adminLocked = descriptor.adminOnlyEdit && !isAdmin;
    final canToggle = canEdit && !adminLocked;
    final pillBg = enabled
        ? theme.colorScheme.primary.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerHighest;
    final pillFg = enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        descriptor.title,
                        style: theme.textTheme.titleSmall?.bold,
                      ),
                    ),
                    if (showInternalLabels && descriptor.betaTag != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: theme.colorScheme.surface,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                        child: Text(
                          descriptor.betaTag!,
                          style: theme.textTheme.labelSmall?.bold.withColor(
                            theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                if (showInternalLabels)
                  Text(
                    descriptor.description,
                    style: theme.textTheme.bodySmall
                        ?.withColor(theme.colorScheme.onSurfaceVariant)
                        .copyWith(height: 1.35),
                  ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: pillBg,
                      border: Border.all(color: pillFg.withValues(alpha: 0.28)),
                    ),
                    child: Text(
                      enabled ? 'Enabled' : 'Disabled',
                      style: theme.textTheme.labelSmall?.bold.withColor(pillFg),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Switch.adaptive(
            value: enabled,
            onChanged: canToggle
                ? (v) => context.read<FeatureFlagProvider>().setEnabled(
                    descriptor.feature,
                    v,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _UnlockPanel extends StatelessWidget {
  const _UnlockPanel({
    required this.canEdit,
    required this.unlocking,
    required this.unlockError,
    required this.controller,
    required this.onUnlock,
    required this.onLock,
  });

  final bool canEdit;
  final bool unlocking;
  final String? unlockError;
  final TextEditingController controller;
  final VoidCallback onUnlock;
  final VoidCallback onLock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Unlock editing',
                  style: theme.textTheme.titleSmall?.bold,
                ),
              ),
              if (canEdit)
                TextButton(
                  onPressed: onLock,
                  child: Text(
                    'Lock',
                    style: theme.textTheme.labelLarge?.bold.withColor(
                      theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            canEdit
                ? 'Editing is unlocked on this device.'
                : 'Enter your unlock code to enable feature toggles on this device.',
            style: theme.textTheme.bodySmall?.withColor(
              theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (!canEdit) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Unlock code',
                errorText: unlockError,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: unlocking ? null : onUnlock,
              child: unlocking
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      'Unlock',
                      style: theme.textTheme.labelLarge?.bold.withColor(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tip: unlock code is case-sensitive.',
              style: theme.textTheme.labelSmall?.withColor(
                theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressionPolicyStatusCard extends StatelessWidget {
  const _ProgressionPolicyStatusCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProgressionFeaturePolicyProvider>();
    final policy = provider.policy;

    final title = 'Server policy (Progression)';
    final subtitle = provider.isLoading
        ? 'Loading…'
        : 'Role: ${provider.roleKey} • Source: ${policy.source} • Loaded: ${_time(policy.loadedAt)}';

    final isOn = policy.progressionEnabled;
    final tint = isOn ? theme.colorScheme.primary : theme.colorScheme.error;
    final badgeText = isOn ? 'ON' : 'OFF';

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: tint.withValues(alpha: 0.12),
                  border: Border.all(color: tint.withValues(alpha: 0.22)),
                ),
                child: Icon(Icons.gpp_good_outlined, color: tint),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall?.bold),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.withColor(
                        theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: tint.withValues(alpha: 0.12),
                  border: Border.all(color: tint.withValues(alpha: 0.25)),
                ),
                child: Text(
                  badgeText,
                  style: theme.textTheme.labelSmall?.bold.withColor(tint),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniPill(label: 'Missions', enabled: policy.missionsEnabled),
              _MiniPill(label: 'Campaigns', enabled: policy.campaignsEnabled),
              _MiniPill(label: 'Rewards', enabled: policy.redemptionsEnabled),
              _MiniPill(label: 'Writes', enabled: policy.allowAnyWrite),
            ],
          ),
          if (provider.lastError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Last error: ${provider.lastError}',
              style: theme.textTheme.bodySmall?.withColor(
                theme.colorScheme.error,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () => context
                        .read<ProgressionFeaturePolicyProvider>()
                        .refresh(),
              icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
              label: Text(
                'Refresh server policy',
                style: theme.textTheme.labelLarge?.bold.withColor(
                  theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _time(DateTime dt) {
    final delta = DateTime.now().difference(dt);
    if (delta.inSeconds < 10) return 'just now';
    if (delta.inMinutes < 1) return '${delta.inSeconds}s ago';
    if (delta.inHours < 1) return '${delta.inMinutes}m ago';
    if (delta.inDays < 1) return '${delta.inHours}h ago';
    return '${delta.inDays}d ago';
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.enabled});
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    final bg = enabled
        ? tint.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.22);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: bg,
        border: Border.all(color: tint.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.bold.withColor(tint),
      ),
    );
  }
}
