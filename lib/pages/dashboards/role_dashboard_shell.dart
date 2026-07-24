import 'package:flutter/material.dart';
import 'package:spotlight_connect/theme.dart';
import 'package:spotlight_connect/models/dashboard_tab_spec.dart';

class RoleDashboardShell extends StatefulWidget {
  final String role;
  final List<DashboardTabSpec> tabs;

  const RoleDashboardShell({super.key, required this.role, required this.tabs});

  @override
  State<RoleDashboardShell> createState() => _RoleDashboardShellState();
}

class _RoleDashboardShellState extends State<RoleDashboardShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final accentColor = context.roleAccent(widget.role);
    final shellBackground = context.roleShellBackground(widget.role);
    final navBackground = context.roleNavBackground(widget.role);
    final navBorder = context.rolePanelBorder(widget.role);

    return Scaffold(
      backgroundColor: shellBackground,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [shellBackground, navBackground.withValues(alpha: 0.92)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: widget.tabs.map((tab) => tab.builder()).toList(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBackground,
          border: Border(top: BorderSide(color: navBorder, width: 1.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: navBackground,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: navBackground,
            selectedItemColor: accentColor,
            unselectedItemColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
            selectedFontSize: 10,
            unselectedFontSize: 10,
            iconSize: 22,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
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
