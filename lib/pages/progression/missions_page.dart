import 'package:flutter/material.dart';

class MissionsPage extends StatelessWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Missions')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Missions page temporarily disabled during analyzer recovery.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
