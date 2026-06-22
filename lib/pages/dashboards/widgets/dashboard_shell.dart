import 'package:flutter/material.dart';

class DashboardShell extends StatelessWidget {
  final List<Widget> children;

  const DashboardShell({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Switch layout based on width
        int crossAxisCount = constraints.maxWidth > 900 ? 3 : 1;
        
        return GridView.count(
          padding: const EdgeInsets.all(16.0),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: children,
        );
      },
    );
  }
}
