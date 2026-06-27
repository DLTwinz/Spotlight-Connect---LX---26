import 'package:flutter/material.dart';
import 'package:spotlight_connect/models/dashboard_tab_spec.dart';

class RoleDashboardShell extends StatefulWidget {
  final String role;
  final List<DashboardTabSpec> tabs;

  const RoleDashboardShell({
    super.key, 
    required this.role, 
    required this.tabs
  });

  @override
  State<RoleDashboardShell> createState() => _RoleDashboardShellState();
}

class _RoleDashboardShellState extends State<RoleDashboardShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final String activeRole = widget.role.trim().toLowerCase();
    final bool isTalent = activeRole == 'talent';
    
    // Theme accents synchronized across active workspaces
    final Color accentColor = isTalent ? const Color(0xFF39FF14) : const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: widget.tabs.map((tab) => tab.builder()).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF111111), width: 1.0),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: const Color(0xFF0A0A0A),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF0A0A0A),
            selectedItemColor: accentColor,
            unselectedItemColor: Colors.white.withValues(alpha: 0.3),
            selectedFontSize: 10,
            unselectedFontSize: 10,
            iconSize: 22,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, letterSpacing: 0.5),
            items: widget.tabs.map((tab) {
              return BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(tab.icon),
                ),
                label: tab.label.toUpperCase(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}