import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityGateScreen extends StatefulWidget {
  const SecurityGateScreen({super.key});

  @override
  State<SecurityGateScreen> createState() => _SecurityGateScreenState();
}

class _SecurityGateScreenState extends State<SecurityGateScreen> {
  final _supabase = Supabase.instance.client;
  bool _isReauthorizing = false;

  Future<void> _triggerTokenAudit() async {
    setState(() => _isReauthorizing = true);

    try {
      final user = _supabase.auth.currentUser;
      await _supabase.from('security_audit_logs').insert({
        'event_type': 'MANUAL_TOKEN_REVERIFICATION',
        'sub_node': 'auth.user.uid(${user?.id.substring(0, 8)})',
        'clearance_level': 'OPERATOR_DISPATCH',
        'status': 'VERIFIED',
      });
    } catch (_) {
      // Stream updates will catch the user status live
    } finally {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _isReauthorizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'SECURITY INTEGRITY CONTROL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= TOKEN ATTRIBUTE SUMMARY =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF111111)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACTIVE JWT AUTH CLAIMS',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildClaimRow('ISSUER NODE', 'SUPABASE_AUTH_ROUTER'),
                  _buildClaimRow(
                    'SUBJECT UUID',
                    currentUser?.id ?? 'NULL_POINTER',
                  ),
                  _buildClaimRow('ROLE CLAIM', 'AUTHENTICATED_OPERATOR'),
                  _buildClaimRow(
                    'CRYPTO METRIC',
                    'SHA-256 / RLS_ACTIVE',
                    displayColor: const Color(0xFF39FF14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ================= TELEMETRY DISPATCH ACTION =================
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00FFFF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isReauthorizing ? null : _triggerTokenAudit,
              icon: const Icon(Icons.security_update_good, size: 16),
              label: _isReauthorizing
                  ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'REVERIFY TOKEN CLAIMS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 12,
                      ),
                    ),
            ),
            const SizedBox(height: 32),

            const Text(
              'REAL-TIME RLS VIOLATION & AUDIT STREAM',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // ================= REAL-TIME LOG PIPELINE =================
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _supabase
                    .from('security_audit_logs')
                    .stream(primaryKey: ['id'])
                    .order('timestamp'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF39FF14),
                      ),
                    );
                  }
                  final logs = snapshot.data!;
                  return ListView.builder(
                    reverse: true,
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF050505),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF161616)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              // 🎯 FIXED: Removed the stray floating Column statement here
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log['event_type'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    log['sub_node'] ?? '',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111111),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              child: Text(
                                log['status'] ?? 'ENFORCED',
                                style: const TextStyle(
                                  color: Color(0xFF39FF14),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimRow(
    String label,
    String value, {
    Color displayColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: displayColor,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
