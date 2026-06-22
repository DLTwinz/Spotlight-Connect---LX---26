import 'package:flutter/material.dart';

class EarlyAccessGatePage extends StatelessWidget {
  const EarlyAccessGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Welcome to SPOTLIGHT Connect",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
