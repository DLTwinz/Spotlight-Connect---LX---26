import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:spotlight_connect/models/dashboard_tab_spec.dart';
import 'package:spotlight_connect/theme.dart';

Widget _shellTabBadge(int? badge, {required Color accent}) {
  if (badge == null || badge <= 0) return const SizedBox.shrink();
  return Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: accent,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      badge > 99 ? '99+' : '$badge',
      style: const TextStyle(
        color: Color(0xFF07090F),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
    ),
  );
}

class RoleDashboardShell extends StatefulWidget {
  const RoleDashboardShell({
    super.key,
    required this.role,
    required this.tabs,
    this.title,
  });

  final String role;
  final List<DashboardTabSpec> tabs;
  final String? title;

  @override
  State<RoleDashboardShell> createState() => _RoleDashboardShellState();
}

class _RoleDashboardShellState extends State<RoleDashboardShell> {
  int _currentIndex = 0;

  @override
  void didUpdateWidget(covariant RoleDashboardShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      _currentIndex = 0;
    } else if (_currentIndex >= widget.tabs.length) {
      _currentIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = context.roleAccent(widget.role);
    final shellBackground = context.roleShellBackground(widget.role);
    final navBackground = context.roleNavBackground(widget.role);
    final panelBackground = context.rolePanelBackground(widget.role);
    final panelBorder = context.rolePanelBorder(widget.role);
    final primaryText = context.roleTextPrimary(widget.role);
    final subtleText = context.roleTextSubtle(widget.role);

    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 1100;
    final isTablet = size.width >= 760;

    return Scaffold(
      backgroundColor: shellBackground,
      body: Stack(
        children: [
          _ShellBackground(
            shellBackground: shellBackground,
            navBackground: navBackground,
            accentColor: accentColor,
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 20 : 12),
              child: isDesktop
                  ? Row(
                      children: [
                        SizedBox(
                          width: 264,
                          child: _DesktopSidebar(
                            role: widget.role,
                            tabs: widget.tabs,
                            currentIndex: _currentIndex,
                            accentColor: accentColor,
                            navBackground: navBackground,
                            panelBorder: panelBorder,
                            primaryText: primaryText,
                            subtleText: subtleText,
                            onTap: _onIndexChanged,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ShellMainFrame(
                            role: widget.role,
                            tabs: widget.tabs,
                            currentIndex: _currentIndex,
                            accentColor: accentColor,
                            panelBackground: panelBackground,
                            panelBorder: panelBorder,
                            primaryText: primaryText,
                            subtleText: subtleText,
                            isDesktop: true,
                            isTablet: true,
                            onTap: _onIndexChanged,
                          ),
                        ),
                      ],
                    )
                  : _ShellMainFrame(
                      role: widget.role,
                      tabs: widget.tabs,
                      currentIndex: _currentIndex,
                      accentColor: accentColor,
                      panelBackground: panelBackground,
                      panelBorder: panelBorder,
                      primaryText: primaryText,
                      subtleText: subtleText,
                      isDesktop: false,
                      isTablet: isTablet,
                      onTap: _onIndexChanged,
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : _MobileNavBar(
              role: widget.role,
              tabs: widget.tabs,
              currentIndex: _currentIndex,
              accentColor: accentColor,
              navBackground: navBackground,
              panelBorder: panelBorder,
              onTap: _onIndexChanged,
            ),
    );
  }

  void _onIndexChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }
}

class _ShellBackground extends StatelessWidget {
  final Color shellBackground;
  final Color navBackground;
  final Color accentColor;

  const _ShellBackground({
    required this.shellBackground,
    required this.navBackground,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: shellBackground),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  shellBackground,
                  navBackground.withValues(alpha: 0.96),
                  shellBackground,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -40,
          child: _GlowOrb(
            size: 240,
            color: accentColor.withValues(alpha: 0.16),
          ),
        ),
        Positioned(
          right: -50,
          top: 120,
          child: _GlowOrb(
            size: 220,
            color: SpotlightAccents.purple.withValues(alpha: 0.10),
          ),
        ),
        Positioned(
          bottom: -70,
          right: 180,
          child: _GlowOrb(
            size: 220,
            color: SpotlightAccents.cyan.withValues(alpha: 0.10),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.45,
            spreadRadius: size * 0.08,
          ),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final String role;
  final List<DashboardTabSpec> tabs;
  final int currentIndex;
  final Color accentColor;
  final Color navBackground;
  final Color panelBorder;
  final Color primaryText;
  final Color subtleText;
  final ValueChanged<int> onTap;

  const _DesktopSidebar({
    required this.role,
    required this.tabs,
    required this.currentIndex,
    required this.accentColor,
    required this.navBackground,
    required this.panelBorder,
    required this.primaryText,
    required this.subtleText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: navBackground.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: panelBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SidebarBrand(
                role: role,
                primaryText: primaryText,
                subtleText: subtleText,
                accentColor: accentColor,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withValues(alpha: 0.03),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.45),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${role.toUpperCase()} WORKSPACE',
                        style: TextStyle(
                          color: subtleText,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: tabs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    final selected = index == currentIndex;

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => onTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: selected
                              ? accentColor.withValues(alpha: 0.14)
                              : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? accentColor.withValues(alpha: 0.24)
                                : Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              tab.icon,
                              size: 19,
                              color: selected
                                  ? accentColor
                                  : primaryText.withValues(alpha: 0.72),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tab.label,
                                style: TextStyle(
                                  color: selected
                                      ? primaryText
                                      : primaryText.withValues(alpha: 0.78),
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                  _shellTabBadge(tab.badge, accent: accentColor),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.03),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security_rounded, color: accentColor, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Live shell routing active',
                        style: TextStyle(
                          color: subtleText,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  final String role;
  final Color primaryText;
  final Color subtleText;
  final Color accentColor;

  const _SidebarBrand({
    required this.role,
    required this.primaryText,
    required this.subtleText,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final roleTitle = switch (role.trim().toLowerCase()) {
      'talent' => 'Creator OS',
      'business' => 'Brand Suite',
      'audience' => 'Audience Hub',
      'admin' => 'Admin Console',
      _ => 'Workspace',
    };

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accentColor, accentColor.withValues(alpha: 0.65)],
            ),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.black,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SPOTLIGHT',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                roleTitle,
                style: TextStyle(
                  color: subtleText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShellMainFrame extends StatelessWidget {
  final String role;
  final List<DashboardTabSpec> tabs;
  final int currentIndex;
  final Color accentColor;
  final Color panelBackground;
  final Color panelBorder;
  final Color primaryText;
  final Color subtleText;
  final bool isDesktop;
  final bool isTablet;
  final ValueChanged<int> onTap;

  const _ShellMainFrame({
    required this.role,
    required this.tabs,
    required this.currentIndex,
    required this.accentColor,
    required this.panelBackground,
    required this.panelBorder,
    required this.primaryText,
    required this.subtleText,
    required this.isDesktop,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentTab = tabs[currentIndex];

    return Column(
      children: [
        _ShellHeader(
          role: role,
          currentTab: currentTab,
          accentColor: accentColor,
          primaryText: primaryText,
          subtleText: subtleText,
          isDesktop: isDesktop,
          isTablet: isTablet,
        ),
        const SizedBox(height: 14),
        if (!isDesktop) ...[
          _TopTabStrip(
            tabs: tabs,
            currentIndex: currentIndex,
            accentColor: accentColor,
            primaryText: primaryText,
            subtleText: subtleText,
            onTap: onTap,
          ),
          const SizedBox(height: 14),
        ],
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isDesktop ? 30 : 24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: panelBackground.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(isDesktop ? 30 : 24),
                  border: Border.all(color: panelBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 28,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: IndexedStack(
                  index: currentIndex,
                  children: [
                    for (final tab in tabs)
                      KeyedSubtree(
                        key: ValueKey<String>(tab.label),
                        child: tab.builder(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShellHeader extends StatelessWidget {
  final String role;
  final DashboardTabSpec currentTab;
  final Color accentColor;
  final Color primaryText;
  final Color subtleText;
  final bool isDesktop;
  final bool isTablet;

  const _ShellHeader({
    required this.role,
    required this.currentTab,
    required this.accentColor,
    required this.primaryText,
    required this.subtleText,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 22 : 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 46 : 40,
                height: isTablet ? 46 : 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: accentColor.withValues(alpha: 0.14),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.24),
                  ),
                ),
                child: Icon(currentTab.icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTab.label,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: isDesktop ? 24 : 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${role.toUpperCase()} ROUTING LAYER',
                      style: TextStyle(
                        color: subtleText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              if (isTablet) ...[
                _HeaderChip(label: 'Live', accentColor: accentColor),
                const SizedBox(width: 10),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: primaryText.withValues(alpha: 0.82),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final Color accentColor;

  const _HeaderChip({required this.label, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accentColor.withValues(alpha: 0.12),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: accentColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _TopTabStrip extends StatelessWidget {
  final List<DashboardTabSpec> tabs;
  final int currentIndex;
  final Color accentColor;
  final Color primaryText;
  final Color subtleText;
  final ValueChanged<int> onTap;

  const _TopTabStrip({
    required this.tabs,
    required this.currentIndex,
    required this.accentColor,
    required this.primaryText,
    required this.subtleText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final selected = index == currentIndex;

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: selected
                    ? accentColor.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.04),
                border: Border.all(
                  color: selected
                      ? accentColor.withValues(alpha: 0.24)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    tab.icon,
                    size: 18,
                    color: selected ? accentColor : subtleText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tab.label,
                    style: TextStyle(
                      color: selected ? primaryText : subtleText,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  _shellTabBadge(tab.badge, accent: accentColor),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MobileNavBar extends StatelessWidget {
  final String role;
  final List<DashboardTabSpec> tabs;
  final int currentIndex;
  final Color accentColor;
  final Color navBackground;
  final Color panelBorder;
  final ValueChanged<int> onTap;

  const _MobileNavBar({
    required this.role,
    required this.tabs,
    required this.currentIndex,
    required this.accentColor,
    required this.navBackground,
    required this.panelBorder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleTabs = tabs.length > 5 ? tabs.take(5).toList() : tabs;
    final selectedIndex = currentIndex >= visibleTabs.length ? 0 : currentIndex;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: navBackground.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: panelBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 22,
                  offset: const Offset(0, -2),
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
                currentIndex: selectedIndex,
                onTap: onTap,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: accentColor,
                unselectedItemColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                selectedFontSize: 10,
                unselectedFontSize: 10,
                iconSize: 22,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                items: visibleTabs.map((tab) {
                  return BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Icon(tab.icon),
                    ),
                    label: tab.label,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
