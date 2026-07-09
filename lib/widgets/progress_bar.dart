import 'package:flutter/material.dart';

/// Minimal ProgressBar placeholder. Replace with actual progress bar UI.
class ProgressBar extends StatelessWidget {
  final double value;
  final double max;
  const ProgressBar({super.key, required this.value, this.max = 1.0});

  @override
  Widget build(BuildContext context) {
    final pct = (max <= 0) ? 0.0 : (value / max).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(value: pct),
    );
  }
}
