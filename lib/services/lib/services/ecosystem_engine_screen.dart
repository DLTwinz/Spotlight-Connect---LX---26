import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EcosystemEngineScreen extends StatelessWidget {
  const EcosystemEngineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'ECOSYSTEM FEEDS & MISSIONS LOG',
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'LIVE SYSTEM EVENT TELEMETRY',
              style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase.from('ecosystem_feeds').stream(primaryKey: ['id']).order('created_at'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF39FF14)));
                  }
                  final items = snapshot.data!;
                  return ListView.builder(
                    reverse: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final log = items[index];
                      final category = log['category'] ?? 'MISSION';
                      
                      Color categoryColor = const Color(0xFF39FF14);
                      if (category == 'ALERT') categoryColor = Colors.redAccent;
                      if (category == 'RECOGNITION') categoryColor = const Color(0xFFD4AF37);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF111111)),
                        ),
                        // 🎯 FIXED: Stray syntax removed here cleanly
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: categoryColor),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(color: categoryColor, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ),
                                if (log['xp_value'] != null && log['xp_value'] > 0)
                                  Text(
                                    '+${log['xp_value']} XP',
                                    style: const TextStyle(color: Color(0xFF00FFFF), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              log['title'] ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              log['details'] ?? '',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, height: 1.4),
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
}