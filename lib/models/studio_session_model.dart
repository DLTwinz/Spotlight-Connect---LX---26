import 'package:flutter/foundation.dart';

@immutable
class StudioSessionModel {
  const StudioSessionModel({
    required this.sessionId,
    required this.title,
    required this.scheduledFor,
    required this.status,
    required this.broadcastMethod,
    this.broadcasterUserId,
    this.broadcasterDisplayName,
    this.externalStreamUrl,
    this.rtmpIngestUrl,
    this.rtmpStreamKey,
    this.livekitRoom,
    required this.createdAt,
    required this.updatedAt,
  });

  final String sessionId;
  final String title;
  final DateTime scheduledFor;

  /// scheduled | live | ended
  final String status;

  /// external | rtmp
  final String broadcastMethod;

  /// The user who started the broadcast (used for UI like “by @name” and host actions).
  final String? broadcasterUserId;

  /// Best-effort display name of the broadcaster.
  final String? broadcasterDisplayName;
  final String? externalStreamUrl;
  final String? rtmpIngestUrl;
  final String? rtmpStreamKey;

  /// LiveKit room name (required when [broadcastMethod] == 'livekit').
  final String? livekitRoom;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudioSessionModel copyWith({
    String? sessionId,
    String? title,
    DateTime? scheduledFor,
    String? status,
    String? broadcastMethod,
    String? broadcasterUserId,
    String? broadcasterDisplayName,
    String? externalStreamUrl,
    String? rtmpIngestUrl,
    String? rtmpStreamKey,
    String? livekitRoom,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudioSessionModel(
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      status: status ?? this.status,
      broadcastMethod: broadcastMethod ?? this.broadcastMethod,
      broadcasterUserId: broadcasterUserId ?? this.broadcasterUserId,
      broadcasterDisplayName:
          broadcasterDisplayName ?? this.broadcasterDisplayName,
      externalStreamUrl: externalStreamUrl ?? this.externalStreamUrl,
      rtmpIngestUrl: rtmpIngestUrl ?? this.rtmpIngestUrl,
      rtmpStreamKey: rtmpStreamKey ?? this.rtmpStreamKey,
      livekitRoom: livekitRoom ?? this.livekitRoom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'title': title,
      'scheduledFor': scheduledFor.toIso8601String(),
      'status': status,
      'broadcastMethod': broadcastMethod,
      'broadcasterUserId': broadcasterUserId,
      'broadcasterDisplayName': broadcasterDisplayName,
      'externalStreamUrl': externalStreamUrl,
      'rtmpIngestUrl': rtmpIngestUrl,
      'rtmpStreamKey': rtmpStreamKey,
      'livekitRoom': livekitRoom,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Supabase row mapping (snake_case) for `public.live_sessions`.
  Map<String, dynamic> toSupabaseJson() {
    return {
      'session_id': sessionId,
      'title': title,
      'scheduled_for': scheduledFor.toIso8601String(),
      'status': status,
      'broadcast_method': broadcastMethod,
      'broadcaster_user_id': broadcasterUserId,
      'broadcaster_display_name': broadcasterDisplayName,
      'external_stream_url': externalStreamUrl,
      'rtmp_ingest_url': rtmpIngestUrl,
      'rtmp_stream_key': rtmpStreamKey,
      'livekit_room': livekitRoom,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StudioSessionModel.fromJson(Map<String, dynamic> json) {
    return StudioSessionModel(
      sessionId: (json['sessionId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      scheduledFor:
          DateTime.tryParse((json['scheduledFor'] ?? '').toString()) ??
          DateTime.now(),
      status: (json['status'] ?? 'scheduled').toString(),
      broadcastMethod: (json['broadcastMethod'] ?? 'external').toString(),
      broadcasterUserId: json['broadcasterUserId']?.toString(),
      broadcasterDisplayName: json['broadcasterDisplayName']?.toString(),
      externalStreamUrl: json['externalStreamUrl']?.toString(),
      rtmpIngestUrl: json['rtmpIngestUrl']?.toString(),
      rtmpStreamKey: json['rtmpStreamKey']?.toString(),
      livekitRoom: json['livekitRoom']?.toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  factory StudioSessionModel.fromSupabaseRow(Map<String, dynamic> row) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return StudioSessionModel(
      sessionId: (row['session_id'] ?? '').toString(),
      title: (row['title'] ?? '').toString(),
      scheduledFor: parseDate(row['scheduled_for']),
      status: (row['status'] ?? 'scheduled').toString(),
      broadcastMethod: (row['broadcast_method'] ?? 'external').toString(),
      broadcasterUserId: row['broadcaster_user_id']?.toString(),
      broadcasterDisplayName: row['broadcaster_display_name']?.toString(),
      externalStreamUrl: row['external_stream_url']?.toString(),
      rtmpIngestUrl: row['rtmp_ingest_url']?.toString(),
      rtmpStreamKey: row['rtmp_stream_key']?.toString(),
      livekitRoom: row['livekit_room']?.toString(),
      createdAt: parseDate(row['created_at']),
      updatedAt: parseDate(row['updated_at']),
    );
  }
}
