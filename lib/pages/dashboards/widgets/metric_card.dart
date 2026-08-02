import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(trend, style: TextStyle(color: Colors.green[700])),
          ],
        ),
      ),
    );
  }
}
