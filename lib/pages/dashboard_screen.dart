import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/supabase_auth_provider.dart';
import '../models/user_model.dart';
import 'dashboards/talent_business_dashboards.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Reactively listen to the single source of truth
    final authProvider = Provider.of<SupabaseAuthProvider>(context);
    final UserModel? user = authProvider.currentUser;

    // 2. Handle global bootstrap loading state cleanly
    if (authProvider.isLoading || user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF39FF14)),
        ),
      );
    }

    // 3. Dynamic Structural HUD Swapping based on Active Role
    final activeRole = user.activeRole.trim().toLowerCase();
    if (activeRole == 'talent') {
      return const TalentDashboard();
    } else if (activeRole == 'business') {
      return const BusinessDashboard();
    }

    // 4. Fallback Admin / Core System Console Layout
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ================= TOP MATRIX HEADER =================
              _buildConsoleHeader(context, user, authProvider),
              const SizedBox(height: 32),

              // ================= SYSTEM METRICS CARDS =================
              Row(
                children: [
                  Expanded(child: _buildMetricTile('VERIFIED FANS', '1,429', const Color(0xFF39FF14))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricTile('ACTIVE NODES', '98.4%', const Color(0xFFD4AF37))),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                'CORE SYSTEM APPLICATIONS',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // ================= FUNCTIONAL MODULE GRID =================
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildConsoleMenuCard(
                      title: 'ECOSYSTEM ENGINE',
                      subtitle: 'Feeds & Missions Log',
                      icon: Icons.layers_outlined,
                      accentColor: const Color(0xFF39FF14),
                      onTap: () => context.push('/ecosystem'),
                    ),
                    _buildConsoleMenuCard(
                      title: 'MESSAGING PIPELINE',
                      subtitle: 'Twilio Telemetry Matrix',
                      icon: Icons.dns_outlined,
                      accentColor: const Color(0xFFD4AF37),
                      onTap: () => context.push('/messaging'),
                    ),
                    _buildConsoleMenuCard(
                      title: 'FANDOM HUB',
                      subtitle: 'Community Core Group',
                      icon: Icons.groups_2_outlined,
                      accentColor: Colors.purpleAccent,
                      onTap: () => context.push('/fandom'),
                    ),
                    _buildConsoleMenuCard(
                      title: 'SECURITY GATE',
                      subtitle: 'RLS & Token Claims',
                      icon: Icons.gpp_good_outlined,
                      accentColor: Colors.tealAccent,
                      onTap: () => _showDevelopmentToast(context, 'TOKEN CLAIMS & AUDIT LOGS SECURE'),
                    ),
                  ],
                ),
              ),

              // ================= SYSTEM FOOTER DISCHARGE =================
              Center(
                child: Text(
                  'SPOTLIGHT CONNECT OS v1.0.0 // SECURE RUNTIME ENABLED',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 9, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsoleHeader(BuildContext context, UserModel user, SupabaseAuthProvider auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.displayName.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF39FF14), shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'ACCESS PRIVILEGE LEVEL: ${user.activeRole.toUpperCase()}',
                  style: const TextStyle(color: Color(0xFF39FF14), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.power_settings_new, color: Colors.redAccent, size: 22),
          onPressed: () async {
            await auth.logout();
            if (context.mounted) context.go('/');
          },
        ),
      ],
    );
  }

  Widget _buildMetricTile(String title, String data, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            data,
            style: TextStyle(color: accentColor, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF111111)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: accentColor, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDevelopmentToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
        backgroundColor: const Color(0xFFD4AF37),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}