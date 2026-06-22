import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:spotlight_connect/models/studio_session_model.dart';
import 'package:spotlight_connect/nav.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/services/studio_service.dart';
import 'package:spotlight_connect/theme.dart';

class LiveWatchSheet extends StatelessWidget {
  const LiveWatchSheet({super.key, required this.session});

  final StudioSessionModel session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.read<AppAuthProvider>();
    final currentUserId = auth.currentUser?.userId;
    final isBroadcaster = currentUserId != null && currentUserId == session.broadcasterUserId;
    final broadcaster = (session.broadcasterDisplayName ?? '').trim();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.live_tv, color: theme.colorScheme.onSurface),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Live session', style: theme.textTheme.titleLarge?.bold)),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(session.title, style: theme.textTheme.titleMedium?.bold),
            const SizedBox(height: AppSpacing.xs),
            Text(
              [
                if (broadcaster.isNotEmpty) 'by $broadcaster',
                _subtitle(session),
              ].join(' • '),
              style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
            ),
            if (isBroadcaster && session.status == 'live') ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                  onPressed: () async {
                    final ok = await showModalBottomSheet<bool>(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (context) {
                        final theme = Theme.of(context);
                        return SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.stop_circle_outlined, color: theme.colorScheme.error),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(child: Text('End live now?', style: theme.textTheme.titleLarge?.bold)),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'This will end the live session and remove it from Spotlight for viewers.',
                                  style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => context.pop(false),
                                        child: Text('Cancel', style: theme.textTheme.labelLarge?.withColor(theme.colorScheme.onSurface)),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: FilledButton.icon(
                                        style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                                        onPressed: () => context.pop(true),
                                        icon: Icon(Icons.call_end, color: theme.colorScheme.onError),
                                        label: Text('End', style: theme.textTheme.labelLarge?.bold.withColor(theme.colorScheme.onError)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    if (ok != true) return;
                    try {
                      final localContext = context;
                      if (!localContext.mounted) return;
                      final studioSvc = localContext.read<StudioService>();
                      await studioSvc.endSession(session.sessionId);
                      if (!localContext.mounted) return;
                      Navigator.of(localContext).pop();
                    } catch (e) {
                      debugPrint('LiveWatchSheet: endSession failed: $e');
                    }
                  },
                  icon: Icon(Icons.stop_circle_outlined, color: theme.colorScheme.onError),
                  label: Text('End live', style: theme.textTheme.labelLarge?.bold.withColor(theme.colorScheme.onError)),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            _Content(session: session),
          ],
        ),
      ),
    );
  }

  static String _subtitle(StudioSessionModel session) {
    switch (session.broadcastMethod) {
      case 'external':
        return 'Streaming from console via Twitch/YouTube (link-based).';
      case 'rtmp':
        return 'Streaming via OBS / encoder to RTMP (key-based).';
      case 'livekit':
        return 'Streaming from within the app (LiveKit).';
      default:
        return 'Streaming from within the app.';
    }
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.session});

  final StudioSessionModel session;

  @override
  Widget build(BuildContext context) {
    switch (session.broadcastMethod) {
      case 'external':
        return _ConsoleWatch(session: session);
      case 'rtmp':
        return _RtmpDetails(session: session);
      case 'livekit':
        return _LiveKitWatch(session: session);
      default:
        return _NativeStub(session: session);
    }
  }
}

class _LiveKitWatch extends StatelessWidget {
  const _LiveKitWatch({required this.session});

  final StudioSessionModel session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = (session.livekitRoom ?? '').trim();
    final enabled = room.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sensors, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Join in-app', style: theme.textTheme.titleMedium?.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            enabled ? 'Room: $room' : 'This session is missing a LiveKit room id.',
            style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: !enabled
                  ? null
                  : () {
                      context.pop();
                      context.push(AppRoutes.livekit, extra: {'session': session, 'hostMode': false});
                    },
              icon: Icon(Icons.play_arrow, color: theme.colorScheme.onPrimary),
              label: Text('Watch now', style: theme.textTheme.labelLarge?.bold.withColor(theme.colorScheme.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsoleWatch extends StatelessWidget {
  const _ConsoleWatch({required this.session});

  final StudioSessionModel session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = (session.externalStreamUrl ?? '').trim();
    final uri = Uri.tryParse(url);
    final isValid = uri != null && uri.hasScheme && uri.hasAuthority;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Watch link', style: theme.textTheme.titleMedium?.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SelectableText(
            url.isEmpty ? 'No link provided yet.' : url,
            style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: url.isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: url));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Link copied', style: theme.textTheme.bodyMedium)),
                            );
                          }
                        },
                  icon: Icon(Icons.copy, color: theme.colorScheme.onSurface),
                  label: Text('Copy', style: theme.textTheme.labelLarge?.withColor(theme.colorScheme.onSurface)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: !isValid
                      ? null
                      : () async {
                          final resolved = uri;
                          final ok = await canLaunchUrl(resolved);
                          if (!ok) return;
                          await launchUrl(resolved, mode: LaunchMode.externalApplication);
                        },
                  icon: Icon(Icons.open_in_new, color: theme.colorScheme.onPrimary),
                  label: Text('Open', style: theme.textTheme.labelLarge?.withColor(theme.colorScheme.onPrimary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tip: On PS5/PS4/Xbox, start streaming to Twitch/YouTube, then paste your live URL in SPOTLIGHT Studio.',
            style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant),
          )
        ],
      ),
    );
  }
}

class _RtmpDetails extends StatelessWidget {
  const _RtmpDetails({required this.session});

  final StudioSessionModel session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ingest = (session.rtmpIngestUrl ?? '').trim();
    final key = (session.rtmpStreamKey ?? '').trim();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_input_component, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('OBS / RTMP details', style: theme.textTheme.titleMedium?.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _KeyRow(label: 'RTMP ingest URL', value: ingest, obscure: false),
          const SizedBox(height: AppSpacing.sm),
          _KeyRow(label: 'Stream key', value: key, obscure: true),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Console workflow: use a capture card → OBS → paste these values into OBS “Stream”.',
            style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.label, required this.value, required this.obscure});

  final String label;
  final String value;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = obscure && value.isNotEmpty ? '${value.substring(0, value.length.clamp(0, 6))}••••••••' : value;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium?.withColor(theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xs),
                SelectableText(
                  value.isEmpty ? '—' : shown,
                  style: theme.textTheme.bodyMedium?.bold,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            tooltip: 'Copy',
            onPressed: value.isEmpty
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: value));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copied $label', style: theme.textTheme.bodyMedium)),
                      );
                    }
                  },
            icon: Icon(Icons.copy, color: theme.colorScheme.onSurface),
          )
        ],
      ),
    );
  }
}

class _NativeStub extends StatelessWidget {
  const _NativeStub({required this.session});

  final StudioSessionModel session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Streaming unavailable', style: theme.textTheme.titleMedium?.bold),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'In-app streaming isn\'t enabled in this build. You can still explore the session UI, but playback is disabled.',
            style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
