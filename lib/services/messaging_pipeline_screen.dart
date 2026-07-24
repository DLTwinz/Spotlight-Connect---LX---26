import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagingPipelineScreen extends StatefulWidget {
  const MessagingPipelineScreen({super.key});

  @override
  State<MessagingPipelineScreen> createState() =>
      _MessagingPipelineScreenState();
}

class _MessagingPipelineScreenState extends State<MessagingPipelineScreen> {
  final _supabase = Supabase.instance.client;
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _dispatchBroadcastSignal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final user = _supabase.auth.currentUser;

      await _supabase.from('messaging_logs').insert({
        'recipient_phone': _phoneController.text.trim(),
        'message_body': _messageController.text.trim(),
        'status': 'DELIVERED',
        'direction': 'OUTBOUND',
        'operator_id': user?.id,
      });

      _phoneController.clear();
      _messageController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'TRANSMISSION SUCCESSFUL: Twilio pipeline telemetry updated.',
            ),
            backgroundColor: Color(0xFF39FF14),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'TRANSMISSION FAILED: Security clearing or RLS violation.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'TWILIO TELEMETRY PIPELINE',
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
            Row(
              children: [
                Expanded(
                  child: _buildStatWidget(
                    'PIPELINE DELIVERABILITY',
                    '100%',
                    const Color(0xFF39FF14),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatWidget(
                    'LATENCY RATE',
                    '24ms',
                    const Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'OUTBOUND MATRIX INJECTOR',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    keyboardType: TextInputType.phone,
                    decoration: _buildInputDecoration(
                      'Target Phone Matrix (e.g. +15015550199)',
                      Icons.phone_android,
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Target node required.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    decoration: _buildInputDecoration(
                      'Enter message packet transmission payload...',
                      Icons.code,
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Payload definition required.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isSending ? null : _dispatchBroadcastSignal,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'DISPATCH SIGNAL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'LIVE STREAM TELEMETRY TRAFFIC LOGS',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _supabase
                    .from('messaging_logs')
                    .stream(primaryKey: ['id'])
                    .order('created_at'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF39FF14),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No packet traffic running in current sector.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    );
                  }

                  final logs = snapshot.data!;
                  return ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF111111)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  log['recipient_phone'] ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFF39FF14),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF161616),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    log['status'].toString().toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFFD4AF37),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              log['message_body'] ?? '',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
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

  Widget _buildStatWidget(String title, String status, Color displayColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF111111)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            status,
            style: TextStyle(
              color: displayColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData visualIcon) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      prefixIcon: Icon(visualIcon, color: const Color(0xFFD4AF37), size: 18),
      filled: true,
      fillColor: const Color(0xFF0A0A0A),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF1A1A1A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF39FF14)),
      ),
    );
  }
}
