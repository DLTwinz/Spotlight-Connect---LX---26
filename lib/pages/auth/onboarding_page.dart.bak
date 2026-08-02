import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/theme.dart';
import 'package:spotlight_connect/nav.dart';
import 'package:spotlight_connect/widgets/app_back_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _usernameCtrl = TextEditingController();
  String? _selectedRole; // null = audience, 'talent', 'business'
  bool _busy = false;

  Future<void> _submit() async {
    if (_busy) return;
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a username')));
      return;
    }

    final auth = context.read<AppAuthProvider>();

    try {
      setState(() => _busy = true);
      await auth.completeOnboarding(username, _selectedRole);
      if (!mounted) return;
      // Let redirect guards place the user correctly based on profile/role state.
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Onboarding failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final user = auth.currentUser;
    final isAlreadyApprovedForSelected =
        _selectedRole != null &&
        (user?.approvedRoles.contains(_selectedRole) ?? false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        automaticallyImplyLeading: false,
        leading: AppBackButton(
          enabled: !auth.isLoading,
          fallbackLocation: AppRoutes.root,
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome to SPOTLIGHT Connect',
                  style: Theme.of(context).textTheme.headlineMedium?.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Set up your professional identity to get started.',
                  style: Theme.of(context).textTheme.bodyLarge?.withColor(
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                TextField(
                  controller: _usernameCtrl,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.alternate_email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                Text(
                  'Choose Your Experience',
                  style: Theme.of(context).textTheme.titleLarge?.bold,
                ),
                const SizedBox(height: AppSpacing.md),

                _buildRoleOption(
                  title: 'Audience & Community',
                  description:
                      'Join immediately. View content, streams, and engage with creators and businesses.',
                  icon: Icons.people_alt_outlined,
                  value: null,
                  isSelected: _selectedRole == null,
                  onTap: _busy
                      ? null
                      : () => setState(() => _selectedRole = null),
                ),
                const SizedBox(height: AppSpacing.md),

                _buildRoleOption(
                  title: 'Talent / Creator',
                  description:
                      'Apply to broadcast, monetize, and access creator studio tools. Requires admin approval.',
                  icon: Icons.mic_none_outlined,
                  value: 'talent',
                  isSelected: _selectedRole == 'talent',
                  onTap: _busy
                      ? null
                      : () => setState(() => _selectedRole = 'talent'),
                ),
                const SizedBox(height: AppSpacing.md),

                _buildRoleOption(
                  title: 'Business / Agency',
                  description:
                      'Apply to scout talent, post campaigns, and manage projects. Requires admin approval.',
                  icon: Icons.business_center_outlined,
                  value: 'business',
                  isSelected: _selectedRole == 'business',
                  onTap: _busy
                      ? null
                      : () => setState(() => _selectedRole = 'business'),
                ),

                const SizedBox(height: AppSpacing.xxl),

                ElevatedButton(
                  onPressed: _busy ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: AppSpacing.verticalMd,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: _busy
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          _selectedRole == null
                              ? 'Complete setup'
                              : (isAlreadyApprovedForSelected
                                    ? 'Complete setup'
                                    : 'Submit application'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String title,
    required String description,
    required IconData icon,
    required String? value,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // No-splash interaction (matches app-wide modern style).
    final enabled = onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.bold.withColor(
                        isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.withColor(
                        colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isSelected && value != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: colorScheme.secondary.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: Text(
                          'Review expected: 24–48 hours',
                          style: theme.textTheme.labelSmall?.bold.withColor(
                            colorScheme.secondary,
                          ),
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
    );
  }
}
