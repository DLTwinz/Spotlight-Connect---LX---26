import 'package:flutter/foundation.dart';

@immutable
class NotificationModel {
  const NotificationModel({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.body,
    required this.entityId,
    required this.createdAt,
    required this.read,
  });

  final String notificationId;

  /// like | comment | repost | opportunity_apply | opportunity_shortlist | role_approved | role_rejected
  final String type;
  final String title;
  final String body;
  final String? entityId;
  final DateTime createdAt;
  final bool read;

  NotificationModel copyWith({
    String? notificationId,
    String? type,
    String? title,
    String? body,
    String? entityId,
    DateTime? createdAt,
    bool? read,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      entityId: entityId ?? this.entityId,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'type': type,
      'title': title,
      'body': body,
      'entityId': entityId,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: (json['notificationId'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      entityId: (json['entityId'] ?? '').toString().trim().isEmpty
          ? null
          : (json['entityId'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      read: json['read'] == true,
    );
  }
}
