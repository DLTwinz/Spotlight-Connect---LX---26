import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/models/dashboard_tab_spec.dart';
import 'package:spotlight_connect/pages/dashboards/role_dashboard_shell.dart';
import 'package:spotlight_connect/pages/dashboards/tabs/dashboard_tabs.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';

/// Admin entry — shared [RoleDashboardShell] chrome; command content preserved.
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardShell(
      role: 'admin',
      tabs: [
        DashboardTabSpec(
          label: 'Command',
          icon: Icons.terminal_outlined,
          builder: () => const _AdminCommandTab(),
        ),
        DashboardTabSpec(
          label: 'Profile',
          icon: Icons.person_outline,
          builder: () => const ProfileTab(role: 'admin'),
        ),
      ],
    );
  }
}

class _AdminCommandTab extends StatelessWidget {
  const _AdminCommandTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'SYSTEM COMMAND FLIGHT DECK',
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.30),
                ),
              ),
              child: Text(
                'ROOT AUTH',
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'GLOBAL PERSPECTIVE SHIFT PANEL',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'As an administrator, you are authorized to cross-examine other runtime environments. Mutating this configuration shifts your global session state context.',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        _RoleMutationCard(
          title: 'SHIFTOUT TO CREATOR MATRIX',
          subtitle: 'Impersonate Talent / Creator HUD workspace',
          targetRole: 'talent',
          accentColor: const Color(0xFF39FF14),
          icon: Icons.bolt,
          authProvider: authProvider,
        ),
        const SizedBox(height: 12),
        _RoleMutationCard(
          title: 'SHIFTOUT TO BRAND ENGINE',
          subtitle: 'Impersonate Business / Brand Impact suite',
          targetRole: 'business',
          accentColor: const Color(0xFFD4AF37),
          icon: Icons.analytics_outlined,
          authProvider: authProvider,
        ),
        const SizedBox(height: 12),
        _RoleMutationCard(
          title: 'SHIFTOUT TO CONSUMER NODE',
          subtitle: 'Impersonate Fan / Audience engagement layer',
          targetRole: 'audience',
          accentColor: Colors.cyanAccent,
          icon: Icons.people_outline,
          authProvider: authProvider,
        ),
        const SizedBox(height: 40),
        Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        const SizedBox(height: 20),
        Text(
          'INFRASTRUCTURE CRITICAL METRICS',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        const _SystemMetricRow('Database RLS Layer', 'ENFORCED (SUPABASE)'),
        const _SystemMetricRow('Active Auth Session', 'VALID (JWT SECURE)'),
        const _SystemMetricRow('Standard Account Mutations', 'HARD-LOCKED'),
      ],
    );
  }
}

class _RoleMutationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String targetRole;
  final Color accentColor;
  final IconData icon;
  final AppAuthProvider authProvider;

  const _RoleMutationCard({
    required this.title,
    required this.subtitle,
    required this.targetRole,
    required this.accentColor,
    required this.icon,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: accentColor.withValues(alpha: 0.1),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest,
            side: BorderSide(color: accentColor.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: authProvider.isLoading
              ? null
              : () async {
                  try {
                    await authProvider.setActiveRole(targetRole);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          content: Text(
                            'Context shifted to [${targetRole.toUpperCase()}] safely.',
                            style: TextStyle(color: accentColor),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: colorScheme.error,
                          content: Text('Mutation rejected: $e'),
                        ),
                      );
                    }
                  }
                },
          child: authProvider.isLoading
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(
                  'ENGAGE',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SystemMetricRow extends StatelessWidget {
  final String label;
  final String status;

  const _SystemMetricRow(this.label, this.status);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          Text(
            status,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
