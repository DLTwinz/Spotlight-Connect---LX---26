import 'package:flutter/material.dart';
import 'package:spotlight_connect/models/dashboard_tab_spec.dart';

class RoleDashboardShell extends StatelessWidget {
  final String role;
  final List<DashboardTabSpec> tabs;

  const RoleDashboardShell({
    super.key, 
    required this.role, 
    required this.tabs
  });

  @override
  Widget build(BuildContext context) {
    // You likely have a TabController or Scaffold here that uses 'tabs'
    return Scaffold(
      appBar: AppBar(title: Text("${role.toUpperCase()} Dashboard")),
      body: Center(child: Text("Displaying ${tabs.length} tabs for $role")),
    );
  }
}
