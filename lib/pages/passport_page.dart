import 'package:flutter/material.dart';
import 'package:spotlight_connect/features/passport/passport_model.dart';

class PassportPage extends StatelessWidget {
  final FanPassport userPassport;

  const PassportPage({super.key, required this.userPassport});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Spotlight Identity
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'SPOTLIGHT PASSPORT',
          style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 1.5),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // The "Neon" Border ID Card
            Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF39FF14), width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    userPassport.fanName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  Text(
                    'LOYALTY LEVEL: ${userPassport.loyaltyLevel}',
                    style: const TextStyle(color: Color(0xFF39FF14)),
                  ),
                  const SizedBox(height: 10),
                  // This uses your Model's "isGoldTier" logic!
                  if (userPassport.isGoldTier)
                    const Text(
                      '✨ GOLD TIER ACCESS ✨',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
