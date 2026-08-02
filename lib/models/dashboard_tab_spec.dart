import 'package:flutter/material.dart';

class DashboardTabSpec {
  final String label;
  final IconData icon;
  final Widget Function() builder;
  final int? badge;

  const DashboardTabSpec({
    required this.label,
    required this.icon,
    required this.builder,
    this.badge,
  });
}
