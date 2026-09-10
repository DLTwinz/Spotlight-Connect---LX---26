import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotlight_connect/core/routing/app_routes.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';

class CreatorStudioDest {
  const CreatorStudioDest({
    required this.label,
    required this.icon,
    required this.route,
    this.enabled = false,
  });

  final String label;
  final IconData icon;
  final String? route;
  final bool enabled;
}

class CreatorStudioShell extends StatelessWidget {
  const CreatorStudioShell({super.key, required this.child});

  final Widget child;

  static const destinations = <CreatorStudioDest>[
    CreatorStudioDest(
      label: 'Analytics',
      icon: Icons.bar_chart_rounded,
      route: AppRoutes.studioAnalytics,
      enabled: true,
    ),
    CreatorStudioDest(
      label: 'Identity',
      icon: Icons.person_outline_rounded,
      route: AppRoutes.studioIdentity,
      enabled: true,
    ),
    CreatorStudioDest(
      label: 'Community',
      icon: Icons.groups_outlined,
      route: null,
    ),
    CreatorStudioDest(
      label: 'Gravity Map',
      icon: Icons.hub_outlined,
      route: null,
    ),
    CreatorStudioDest(
      label: 'Portfolio',
      icon: Icons.collections_outlined,
      route: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1100;
    final location = GoRouterState.of(context).uri.path;
    final title = _titleFor(location);

    return Scaffold(
      backgroundColor: SpotlightTokens.bgPrimary,
      body: SafeArea(
        child: desktop
            ? Row(
                children: [
                  _Rail(location: location),
                  Expanded(
                    child: Column(
                      children: [
                        _TopBar(title: title),
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _TopBar(title: title, showMenu: true),
                  Expanded(child: child),
                ],
              ),
      ),
    );
  }

  static String _titleFor(String location) {
    if (location == AppRoutes.studioAnalytics || location == AppRoutes.studio) {
      return 'Analytics';
    }
    if (location == AppRoutes.studioIdentity) {
      return 'Identity';
    }
    return 'Creator Studio';
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Creator Studio navigation',
      container: true,
      child: Container(
        width: 248,
        margin: const EdgeInsets.fromLTRB(14, 14, 0, 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SpotlightTokens.bgSurface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(SpotlightTokens.radiusXl),
          border: Border.all(color: SpotlightTokens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Brand(),
            const SizedBox(height: SpotlightTokens.space24),
            Expanded(
              child: ListView.separated(
                itemCount: CreatorStudioShell.destinations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final dest = CreatorStudioShell.destinations[index];
                  final selected =
                      dest.route != null && location == dest.route;
                  return _RailItem(
                    dest: dest,
                    selected: selected,
                    onTap: dest.enabled && dest.route != null
                        ? () => context.go(dest.route!)
                        : null,
                  );
                },
              ),
            ),
            const Text(
              'Additional Creator Studio destinations will attach as routes land.',
              style: TextStyle(
                color: SpotlightTokens.textMuted,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.auto_awesome_rounded, color: SpotlightTokens.cyan),
        SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SPOTLIGHT',
              style: TextStyle(
                color: SpotlightTokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
            Text(
              'CREATOR STUDIO',
              style: TextStyle(
                color: SpotlightTokens.cyan,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.dest,
    required this.selected,
    required this.onTap,
  });

  final CreatorStudioDest dest;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = selected
        ? SpotlightTokens.cyan
        : enabled
        ? SpotlightTokens.textSecondary
        : SpotlightTokens.textMuted;

    return Semantics(
      button: enabled,
      enabled: enabled,
      selected: selected,
      label: dest.enabled ? dest.label : '${dest.label}, coming soon',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? SpotlightTokens.cyan.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? SpotlightTokens.cyan.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(dest.icon, size: 18, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dest.label,
                    style: TextStyle(
                      color: selected ? SpotlightTokens.textPrimary : color,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                if (!dest.enabled)
                  const Text(
                    'SOON',
                    style: TextStyle(
                      color: SpotlightTokens.textMuted,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, this.showMenu = false});

  final String title;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
      child: Row(
        children: [
          if (showMenu)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                tooltip: 'Creator Studio destinations',
                onPressed: () => _openDestinations(context),
                icon: const Icon(
                  Icons.menu_rounded,
                  color: SpotlightTokens.textSecondary,
                ),
              ),
            ),
          Expanded(
            child: Text(
              'Creator Studio: $title',
              style: const TextStyle(
                color: SpotlightTokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDestinations(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SpotlightTokens.bgSurface,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: CreatorStudioShell.destinations.map((dest) {
              return ListTile(
                enabled: dest.enabled && dest.route != null,
                leading: Icon(dest.icon, color: SpotlightTokens.cyan),
                title: Text(
                  dest.label,
                  style: const TextStyle(color: SpotlightTokens.textPrimary),
                ),
                subtitle: dest.enabled
                    ? null
                    : const Text(
                        'Coming soon',
                        style: TextStyle(color: SpotlightTokens.textMuted),
                      ),
                onTap: dest.enabled && dest.route != null
                    ? () {
                        Navigator.pop(context);
                        context.go(dest.route!);
                      }
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
