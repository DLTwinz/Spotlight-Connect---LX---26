import 'package:flutter/foundation.dart';

@immutable
class GroupModel {
  const GroupModel({
    required this.groupId,
    required this.name,
    required this.description,
    required this.createdByUserId,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
  });

  final String groupId;
  final String name;
  final String description;
  final String createdByUserId;
  final String visibility; // public | private
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupModel copyWith({
    String? groupId,
    String? name,
    String? description,
    String? createdByUserId,
    String? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupModel(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'name': name,
      'description': description,
      'createdByUserId': createdByUserId,
      'visibility': visibility,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Supabase row mapping (snake_case DB columns).
  Map<String, dynamic> toSupabaseJson() => {
    'id': groupId,
    'name': name,
    'description': description,
    'created_by_user_id': createdByUserId,
    'visibility': visibility,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  static GroupModel? fromSupabaseRow(Object? raw) {
    try {
      if (raw is! Map) return null;
      final id = raw['id']?.toString();
      final name = raw['name']?.toString();
      final description = raw['description']?.toString();
      final createdByUserId = raw['created_by_user_id']?.toString();
      final visibility = raw['visibility']?.toString();
      final createdAtRaw = raw['created_at']?.toString();
      final updatedAtRaw = raw['updated_at']?.toString();

      if (id == null ||
          name == null ||
          description == null ||
          createdByUserId == null ||
          visibility == null ||
          createdAtRaw == null ||
          updatedAtRaw == null) {
        return null;
      }
      final createdAt = DateTime.tryParse(createdAtRaw);
      final updatedAt = DateTime.tryParse(updatedAtRaw);
      if (createdAt == null || updatedAt == null) return null;

      return GroupModel(
        groupId: id,
        name: name,
        description: description,
        createdByUserId: createdByUserId,
        visibility: visibility,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (_) {
      return null;
    }
  }

  static GroupModel? tryFromJson(Object? raw) {
    try {
      if (raw is! Map) return null;
      final groupId = raw['groupId'];
      final name = raw['name'];
      final description = raw['description'];
      final createdByUserId = raw['createdByUserId'];
      final visibility = raw['visibility'];
      final createdAt = raw['createdAt'];
      final updatedAt = raw['updatedAt'];

      if (groupId is! String ||
          name is! String ||
          description is! String ||
          createdByUserId is! String ||
          visibility is! String ||
          createdAt is! String ||
          updatedAt is! String) {
        return null;
      }

      final parsedCreatedAt = DateTime.tryParse(createdAt);
      final parsedUpdatedAt = DateTime.tryParse(updatedAt);
      if (parsedCreatedAt == null || parsedUpdatedAt == null) return null;

      return GroupModel(
        groupId: groupId,
        name: name,
        description: description,
        createdByUserId: createdByUserId,
        visibility: visibility,
        createdAt: parsedCreatedAt,
        updatedAt: parsedUpdatedAt,
      );
    } catch (_) {
      return null;
    }
  }
}

@immutable
class GroupMembershipModel {
  const GroupMembershipModel({
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  final String groupId;
  final String userId;
  final String role; // owner | admin | member
  final DateTime joinedAt;

  GroupMembershipModel copyWith({
    String? groupId,
    String? userId,
    String? role,
    DateTime? joinedAt,
  }) {
    return GroupMembershipModel(
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseJson() => {
    'group_id': groupId,
    'user_id': userId,
    'role': role,
    'joined_at': joinedAt.toIso8601String(),
  };

  static GroupMembershipModel? fromSupabaseRow(Object? raw) {
    try {
      if (raw is! Map) return null;
      final groupId = raw['group_id']?.toString();
      final userId = raw['user_id']?.toString();
      final role = raw['role']?.toString();
      final joinedAtRaw = raw['joined_at']?.toString();
      if (groupId == null ||
          userId == null ||
          role == null ||
          joinedAtRaw == null)
        return null;
      final joinedAt = DateTime.tryParse(joinedAtRaw);
      if (joinedAt == null) return null;
      return GroupMembershipModel(
        groupId: groupId,
        userId: userId,
        role: role,
        joinedAt: joinedAt,
      );
    } catch (_) {
      return null;
    }
  }

  static GroupMembershipModel? tryFromJson(Object? raw) {
    try {
      if (raw is! Map) return null;
      final groupId = raw['groupId'];
      final userId = raw['userId'];
      final role = raw['role'];
      final joinedAt = raw['joinedAt'];
      if (groupId is! String ||
          userId is! String ||
          role is! String ||
          joinedAt is! String)
        return null;
      final parsedJoinedAt = DateTime.tryParse(joinedAt);
      if (parsedJoinedAt == null) return null;
      return GroupMembershipModel(
        groupId: groupId,
        userId: userId,
        role: role,
        joinedAt: parsedJoinedAt,
      );
    } catch (_) {
      return null;
    }
  }
}
