import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabase = Supabase.instance.client;
  String _profileName = "OPERATOR";
  String _profileRole = "SYSTEM SYSTEM";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserMetadata();
  }

  Future<void> _loadUserMetadata() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final profile = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null && mounted) {
        setState(() {
          _profileName = (profile['display_name'] ?? 'SYSTEM NODE').toString().toUpperCase();
          _profileRole = (profile['role'] ?? 'GUEST PREVIEW').toString().toUpperCase();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF39FF14)))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ================= TOP MATRIX HEADER =================
                    _buildConsoleHeader(),
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
                            // 🎯 FIXED: Connected natively to the new '/fandom' routing path
                            onTap: () => context.push('/fandom'),
                          ),
                          _buildConsoleMenuCard(
                            title: 'SECURITY GATE',
                            subtitle: 'RLS & Token Claims',
                            icon: Icons.gpp_good_outlined,
                            accentColor: Colors.tealAccent,
                            onTap: () => _showDevelopmentToast('TOKEN CLAIMS & AUDIT LOGS SECURE'),
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

  Widget _buildConsoleHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _profileName,
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
                  'ACCESS PRIVILEGE LEVEL: $_profileRole',
                  style: const TextStyle(color: Color(0xFF39FF14), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.power_settings_new, color: Colors.redAccent, size: 22),
          onPressed: () async {
            await _supabase.auth.signOut();
            if (mounted) context.go('/');
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

  void _showDevelopmentToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
        backgroundColor: const Color(0xFFD4AF37),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}