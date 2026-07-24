import 'package:flutter/foundation.dart';

@immutable
class StoryModel {
  const StoryModel({
    required this.storyId,
    required this.authorId,
    required this.authorDisplayName,
    required this.authorPrimaryRole,
    required this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.backgroundSeed,
  });

  final String storyId;
  final String authorId;
  final String authorDisplayName;
  final String authorPrimaryRole;
  final String caption;
  final DateTime createdAt;
  final DateTime expiresAt;

  /// Local-only UI helper: a stable int used to generate a background gradient.
  final int? backgroundSeed;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'storyId': storyId,
    'authorId': authorId,
    'authorDisplayName': authorDisplayName,
    'authorPrimaryRole': authorPrimaryRole,
    'caption': caption,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'backgroundSeed': backgroundSeed,
  };

  /// Supabase row mapping (snake_case DB columns).
  Map<String, dynamic> toSupabaseJson() => {
    'id': storyId,
    'author_id': authorId,
    'author_display_name': authorDisplayName,
    'author_primary_role': authorPrimaryRole,
    'caption': caption,
    'created_at': createdAt.toIso8601String(),
    'expires_at': expiresAt.toIso8601String(),
    'background_seed': backgroundSeed,
  };

  static StoryModel? fromSupabaseRow(Object? raw) {
    if (raw is! Map) return null;
    try {
      final id = raw['id']?.toString();
      final authorId = raw['author_id']?.toString();
      final authorDisplayName = raw['author_display_name']?.toString();
      final authorPrimaryRole = raw['author_primary_role']?.toString();
      final caption = raw['caption']?.toString();
      final createdAtRaw = raw['created_at']?.toString();
      final expiresAtRaw = raw['expires_at']?.toString();

      if (id == null ||
          authorId == null ||
          authorDisplayName == null ||
          authorPrimaryRole == null ||
          caption == null ||
          createdAtRaw == null ||
          expiresAtRaw == null) {
        return null;
      }
      final createdAt = DateTime.tryParse(createdAtRaw);
      final expiresAt = DateTime.tryParse(expiresAtRaw);
      if (createdAt == null || expiresAt == null) return null;

      final seed = raw['background_seed'];
      return StoryModel(
        storyId: id,
        authorId: authorId,
        authorDisplayName: authorDisplayName,
        authorPrimaryRole: authorPrimaryRole,
        caption: caption,
        createdAt: createdAt,
        expiresAt: expiresAt,
        backgroundSeed: seed is int
            ? seed
            : (seed is num ? seed.toInt() : null),
      );
    } catch (_) {
      return null;
    }
  }

  static StoryModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    try {
      final storyId = json['storyId'];
      final authorId = json['authorId'];
      final authorDisplayName = json['authorDisplayName'];
      final authorPrimaryRole = json['authorPrimaryRole'];
      final caption = json['caption'];
      final createdAtRaw = json['createdAt'];
      final expiresAtRaw = json['expiresAt'];

      if (storyId is! String ||
          authorId is! String ||
          authorDisplayName is! String ||
          authorPrimaryRole is! String ||
          caption is! String) {
        return null;
      }
      if (createdAtRaw is! String || expiresAtRaw is! String) return null;

      final createdAt = DateTime.tryParse(createdAtRaw);
      final expiresAt = DateTime.tryParse(expiresAtRaw);
      if (createdAt == null || expiresAt == null) return null;

      final seed = json['backgroundSeed'];
      return StoryModel(
        storyId: storyId,
        authorId: authorId,
        authorDisplayName: authorDisplayName,
        authorPrimaryRole: authorPrimaryRole,
        caption: caption,
        createdAt: createdAt,
        expiresAt: expiresAt,
        backgroundSeed: seed is int ? seed : null,
      );
    } catch (_) {
      return null;
    }
  }

  StoryModel copyWith({
    String? storyId,
    String? authorId,
    String? authorDisplayName,
    String? authorPrimaryRole,
    String? caption,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? backgroundSeed,
  }) {
    return StoryModel(
      storyId: storyId ?? this.storyId,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorPrimaryRole: authorPrimaryRole ?? this.authorPrimaryRole,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      backgroundSeed: backgroundSeed ?? this.backgroundSeed,
    );
  }
}
