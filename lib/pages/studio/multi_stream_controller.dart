import 'package:flutter/material.dart';
import 'package:spotlight_connect/theme.dart';

/// Multi-Platform Stream Controller for managing simultaneous broadcasts.
///
/// This is the central nervous system of the studio production engine.
/// Creators coordinate simultaneous streams to Twitch, YouTube, and Kick
/// with real-time synchronization and platform-specific optimizations.
class MultiStreamController extends StatefulWidget {
  const MultiStreamController({super.key});

  @override
  State<MultiStreamController> createState() => _MultiStreamControllerState();
}

class _MultiStreamControllerState extends State<MultiStreamController> {
  bool _isLive = false;
  bool _twitchActive = true;
  bool _youtubeActive = true;
  bool _kickActive = false;
  String _statusMessage = 'STUDIO IDLE • READY FOR INGEST';
  DateTime? _liveStartTime;

  void _toggleLiveStatus() {
    setState(() {
      _isLive = !_isLive;
      if (_isLive) {
        _liveStartTime = DateTime.now();
        _statusMessage = 'RTMP RELAY ACTIVE • SIMULCASTING';
      } else {
        _liveStartTime = null;
        _statusMessage = 'STUDIO IDLE • READY FOR INGEST';
      }
    });
  }

  String _formatStreamDuration() {
    if (_liveStartTime == null) return '00:00:00';
    final now = DateTime.now();
    final duration = now.difference(_liveStartTime!);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MULTI-PLATFORM BROADCAST CONTROL',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF39FF14),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Simultaneously broadcast to Twitch, YouTube, and Kick with unified controls',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),

          // Main control panel
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: _isLive ? const Color(0xFF39FF14).withValues(alpha: 0.4) : const Color(0xFF1A1A1A),
                width: _isLive ? 1.5 : 1.0,
              ),
              boxShadow: _isLive
                  ? [BoxShadow(color: const Color(0xFF39FF14).withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2)]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Studio Header
                _buildStudioHeader(theme),
                const SizedBox(height: 24),

                // Live Viewport Preview
                _buildLiveViewportPreview(),
                const SizedBox(height: 24),

                // Platform Toggle Section
                _buildPlatformToggleSection(theme),
                const SizedBox(height: 32),

                // Broadcast Control Button
                _buildBroadcastTriggerButton(),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Stream Statistics Panel
          _buildStreamStatisticsPanel(theme),

          const SizedBox(height: 24),

          // Platform-Specific Settings
          _buildPlatformSettingsPanel(theme),

          const SizedBox(height: 24),

          // Failsafe & Compliance Info
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.05),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Live broadcasts are monitored in real-time. Ensure compliance with platform ToS and content policies.',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange.withValues(alpha: 0.8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRODUCTION STUDIO ENGINE',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _statusMessage,
              style: TextStyle(
                color: _isLive ? const Color(0xFF39FF14) : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (_isLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.5), blurRadius: 8)],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'LIVE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLiveViewportPreview() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _isLive ? const Color(0xFF39FF14) : Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam,
              size: 64,
              color: _isLive ? const Color(0xFF39FF14) : Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            if (_isLive)
              Text(
                'STREAMING • ${_formatStreamDuration()}',
                style: const TextStyle(
                  color: Color(0xFF39FF14),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              )
            else
              Text(
                'CAMERA PREVIEW',
                style: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformToggleSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SIMULCAST TARGET SYNC',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildPlatformSwitch(
                'TWITCH',
                _twitchActive,
                (v) => setState(() => _twitchActive = v),
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPlatformSwitch(
                'YOUTUBE',
                _youtubeActive,
                (v) => setState(() => _youtubeActive = v),
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPlatformSwitch(
                'KICK',
                _kickActive,
                (v) => setState(() => _kickActive = v),
                const Color(0xFF10FF00),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlatformSwitch(String name, bool val, Function(bool) onChange, Color platformColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: val ? platformColor.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.2),
          width: val ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              color: val ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          SizedBox(
            width: 40,
            height: 24,
            child: Switch(
              value: val,
              onChanged: onChange,
              activeThumbColor: platformColor,
              activeTrackColor: platformColor.withValues(alpha: 0.2),
              inactiveThumbColor: Colors.grey.withValues(alpha: 0.5),
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastTriggerButton() {
    final activeCount = [_twitchActive, _youtubeActive, _kickActive].where((x) => x).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _isLive ? Colors.red : const Color(0xFF39FF14),
              foregroundColor: _isLive ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            onPressed: _toggleLiveStatus,
            child: Text(
              _isLive ? '⏹ DISCONNECT BROADCAST ARRAY' : '● LAUNCH LIVE STREAM MATRIX',
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14),
            ),
          ),
        ),
        if (!_isLive && activeCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Broadcasting to $activeCount platform${activeCount > 1 ? 's' : ''}',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildStreamStatisticsPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STREAM PERFORMANCE METRICS',
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFF39FF14),
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Total Viewers', '0', Colors.blue),
          const SizedBox(height: 12),
          _buildStatRow('Avg. Bitrate', '6.5 Mbps', Colors.orange),
          const SizedBox(height: 12),
          _buildStatRow('Chat Activity', '0 msg/min', Colors.green),
          const SizedBox(height: 12),
          _buildStatRow('Stream Health', '100%', const Color(0xFF39FF14)),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformSettingsPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLATFORM-SPECIFIC CONFIGURATION',
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildPlatformConfig('TWITCH', 'Bitrate: 6 Mbps | Resolution: 1080p60'),
          const SizedBox(height: 12),
          _buildPlatformConfig('YOUTUBE', 'Bitrate: 5.5 Mbps | Resolution: 1080p30'),
          const SizedBox(height: 12),
          _buildPlatformConfig('KICK', 'Bitrate: 8 Mbps | Resolution: 1440p60'),
        ],
      ),
    );
  }

  Widget _buildPlatformConfig(String platform, String config) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            platform,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            config,
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
