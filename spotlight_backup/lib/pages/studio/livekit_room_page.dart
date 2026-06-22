import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:spotlight_connect/models/studio_session_model.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/services/studio_service.dart';
import 'package:spotlight_connect/theme.dart';

/// In-app LiveKit room experience.
///
/// - Host mode: publishes camera + mic.
/// - Viewer mode: subscribes only.
class LiveKitRoomPage extends StatefulWidget {
  const LiveKitRoomPage({super.key, required this.session, required this.hostMode});

  final StudioSessionModel session;
  final bool hostMode;

  @override
  State<LiveKitRoomPage> createState() => _LiveKitRoomPageState();
}

class _LiveKitRoomPageState extends State<LiveKitRoomPage> {
  Room? _room;
  bool _loading = true;
  String? _error;
  bool _canOpenSettings = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  void dispose() {
    final r = _room;
    _room = null;
    // Best-effort cleanup.
    try {
      r?.disconnect();
    } catch (e) {
      debugPrint('LiveKitRoomPage: disconnect on dispose failed: $e');
    }
    r?.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _loading = true;
      _error = null;
      _canOpenSettings = false;
    });

    try {
      final sessionRoom = (widget.session.livekitRoom ?? '').trim();
      if (sessionRoom.isEmpty) throw StateError('Missing LiveKit room name on session.');

      final auth = context.read<AppAuthProvider>();
      final u = auth.currentUser;
      if (u == null) throw StateError('Not signed in.');

      final isBroadcaster = u.userId == widget.session.broadcasterUserId;
      final effectiveHostMode = widget.hostMode || isBroadcaster;

      // Security: client-side `hostMode` is not authoritative.
      // Only the broadcaster (or an approved admin) can force host mode.
      if (widget.hostMode && !isBroadcaster && !auth.isAdmin) {
        throw StateError('Only the broadcaster can host this live room.');
      }

      final identity = u.userId;

      if (!kIsWeb && effectiveHostMode) {
        final statuses = await [Permission.camera, Permission.microphone].request();
        final cam = statuses[Permission.camera];
        final mic = statuses[Permission.microphone];
        final camOk = cam?.isGranted ?? false;
        final micOk = mic?.isGranted ?? false;
        if (!camOk || !micOk) {
          final permanentlyDenied = (cam?.isPermanentlyDenied ?? false) || (mic?.isPermanentlyDenied ?? false);
          if (permanentlyDenied) {
            throw const _PermissionError(
              message: 'Camera/microphone access is blocked. Enable permissions in Settings to go live.',
              canOpenSettings: true,
            );
          }
          throw const _PermissionError(message: 'Camera and microphone permissions are required to go live.');
        }
      }

      final localContext = context;
      if (!localContext.mounted) return;
      final studio = localContext.read<StudioService>();
      final token = await studio.createLiveKitToken(
        room: sessionRoom,
        participant: identity,
      );
      if (token == null || token.trim().isEmpty) {
        throw StateError('Failed to obtain LiveKit token.');
      }

      const liveKitUrl = String.fromEnvironment('SPOTLIGHT_LIVEKIT_URL');
      if (liveKitUrl.trim().isEmpty) throw StateError('Missing SPOTLIGHT_LIVEKIT_URL.');

      final room = Room();
      try {
        await room.connect(liveKitUrl.trim(), token);
      } catch (e) {
        throw StateError('Failed to connect to the live room. Please try again. ($e)');
      }

      if (effectiveHostMode) {
        try {
          final video = await LocalVideoTrack.createCameraTrack();
          await room.localParticipant?.publishVideoTrack(video);
          final mic = await LocalAudioTrack.create();
          await room.localParticipant?.publishAudioTrack(mic);
        } catch (e) {
          debugPrint('LiveKitRoomPage: publish tracks failed: $e');
        }
      }

      if (!mounted) return;
      setState(() {
        _room = room;
        _loading = false;
      });
    } catch (e) {
      debugPrint('LiveKitRoomPage: connect failed: $e');
      if (!mounted) return;
      setState(() {
        if (e is _PermissionError) {
          _error = e.message;
          _canOpenSettings = e.canOpenSettings;
        } else {
          _error = e.toString();
        }
        _loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = _room;

    final auth = context.read<AppAuthProvider>();
    final currentUserId = auth.currentUser?.userId;
    final isBroadcaster = currentUserId != null && currentUserId == widget.session.broadcasterUserId;
    final effectiveHostMode = widget.hostMode || isBroadcaster;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(effectiveHostMode ? 'Broadcast' : 'Live room', style: theme.textTheme.titleLarge?.bold),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
        ),
      ),
      body: Padding(
        padding: AppSpacing.paddingLg,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(
                    message: _error!,
                    onRetry: _connect,
                    secondaryActionLabel: _canOpenSettings ? 'Open settings' : null,
                    onSecondaryAction: _canOpenSettings
                        ? () async {
                            try {
                              await openAppSettings();
                            } catch (e) {
                              debugPrint('LiveKitRoomPage: openAppSettings failed: $e');
                            }
                          }
                        : null,
                  )
                : room == null
                    ? _ErrorState(message: 'Failed to initialize room.', onRetry: _connect)
                    : _LiveKitRoomBody(room: room, hostMode: effectiveHostMode, session: widget.session),
      ),
    );
  }
}

class _PermissionError implements Exception {
  const _PermissionError({required this.message, this.canOpenSettings = false});

  final String message;
  final bool canOpenSettings;

  @override
  String toString() => message;
}

class _LiveKitRoomBody extends StatelessWidget {
  const _LiveKitRoomBody({required this.room, required this.hostMode, required this.session});

  final Room room;
  final bool hostMode;
  final StudioSessionModel session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(session.title, style: theme.textTheme.titleMedium?.bold),
        const SizedBox(height: AppSpacing.xs),
        Text(
          hostMode ? 'You are live in-app. Viewers can join instantly.' : 'You’re watching in-app.',
          style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
            ),
            child: _LiveKitStage(room: room),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            if (hostMode) ...[
              Expanded(
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
                                    Expanded(child: Text('End broadcast?', style: theme.textTheme.titleLarge?.bold)),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'This will immediately disconnect you and end the live session for everyone.',
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
                    } catch (e) {
                      debugPrint('LiveKitRoomPage: failed to end session: $e');
                    }
                    try {
                      await room.disconnect();
                    } catch (e) {
                      debugPrint('LiveKitRoomPage: disconnect failed: $e');
                    }
                    if (!context.mounted) return;
                    context.pop();
                  },
                  icon: Icon(Icons.stop_circle_outlined, color: theme.colorScheme.onError),
                  label: Text('End broadcast', style: theme.textTheme.labelLarge?.bold.withColor(theme.colorScheme.onError)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await room.disconnect();
                  } catch (e) {
                    debugPrint('LiveKitRoomPage: disconnect failed: $e');
                  }
                  final localContext = context;
                  if (localContext.mounted) localContext.pop();
                },
                icon: Icon(Icons.logout, color: theme.colorScheme.onSurface),
                label: Text(hostMode ? 'Leave room' : 'Leave', style: theme.textTheme.labelLarge?.withColor(theme.colorScheme.onSurface)),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry, this.secondaryActionLabel, this.onSecondaryAction});

  final String message;
  final VoidCallback onRetry;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text('Could not join room', style: theme.textTheme.titleMedium?.bold)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(message, style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (secondaryActionLabel != null && onSecondaryAction != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSecondaryAction,
                        icon: Icon(Icons.settings, color: theme.colorScheme.onSurface),
                        label: Text(secondaryActionLabel!, style: theme.textTheme.labelLarge?.withColor(theme.colorScheme.onSurface)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onRetry,
                      icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
                      label: Text('Retry', style: theme.textTheme.labelLarge?.bold.withColor(theme.colorScheme.onPrimary)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveKitStage extends StatefulWidget {
  const _LiveKitStage({required this.room});

  final Room room;

  @override
  State<_LiveKitStage> createState() => _LiveKitStageState();
}

class _LiveKitStageState extends State<_LiveKitStage> {
  late final EventsListener<RoomEvent> _listener;

  @override
  void initState() {
    super.initState();
    _listener = widget.room.createListener();
    _listener.on<RoomEvent>((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = widget.room;

    final tiles = <Widget>[];

    final local = room.localParticipant;
    if (local != null) {
      for (final pub in local.videoTrackPublications) {
        final track = pub.track;
        if (track == null) continue;
        tiles.add(_VideoTile(track: track, label: 'You'));
        break;
      }
    }

    for (final rp in room.remoteParticipants.values) {
      final rawName = rp.name.trim();
      final name = rawName.isEmpty ? rp.identity.trim() : rawName;
      for (final pub in rp.videoTrackPublications) {
        final track = pub.track;
        if (track == null) continue;
        tiles.add(_VideoTile(track: track, label: name.isEmpty ? 'Viewer' : name));
        break;
      }
    }

    if (tiles.isEmpty) {
      return Center(
        child: Text(
          'Waiting for video…',
          style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    return GridView.count(
      padding: const EdgeInsets.all(AppSpacing.md),
      crossAxisCount: tiles.length == 1 ? 1 : 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      children: tiles,
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.track, required this.label});

  final VideoTrack track;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
          VideoTrackRenderer(track),
          Positioned(
            left: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
              ),
              child: Text(label, style: theme.textTheme.labelMedium?.bold),
            ),
          ),
        ],
      ),
    );
  }
}
