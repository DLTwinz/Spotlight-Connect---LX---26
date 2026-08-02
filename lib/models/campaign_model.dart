import 'package:flutter/foundation.dart';

@immutable
class CampaignModel {
  const CampaignModel({
    required this.id,
    required this.ownerUserId,
    required this.title,
    required this.slug,
    required this.summary,
    required this.description,
    required this.objectiveType,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.primaryAudience,
    required this.primaryActions,
    required this.heroImageUrl,
    required this.priority,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerUserId;
  final String title;
  final String? slug;
  final String? summary;
  final String? description;
  final String? objectiveType;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? primaryAudience;
  final List<String> primaryActions;
  final String? heroImageUrl;
  final int priority;
  final String visibility;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static int _asInt(Object? v) => v is int ? v : int.tryParse('$v') ?? 0;

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    // Back-compat: Edge DTOs may use different column names.
    final owner = (json['owner_user_id'] ?? json['business_user_id'] ?? '')
        .toString();
    final startsAtRaw =
        (json['starts_at'] ?? json['start_at'] ?? json['start_date'] ?? '')
            .toString();
    final endsAtRaw =
        (json['ends_at'] ?? json['end_at'] ?? json['end_date'] ?? '')
            .toString();
    final priorityRaw = json['priority'] ?? json['featured_rank'] ?? 0;
    final visibility = (json['visibility'] ?? 'public').toString();

    final rawActions = json['primary_actions'];
    final actions = rawActions is List
        ? rawActions.map((e) => e.toString()).toList()
        : <String>[];
    return CampaignModel(
      id: (json['id'] ?? '').toString(),
      ownerUserId: owner,
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString().trim().isEmpty
          ? null
          : (json['slug'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString().trim().isEmpty
          ? null
          : (json['summary'] ?? '').toString(),
      description: (json['description'] ?? '').toString().trim().isEmpty
          ? null
          : (json['description'] ?? '').toString(),
      objectiveType: (json['objective_type'] ?? '').toString().trim().isEmpty
          ? null
          : (json['objective_type'] ?? '').toString(),
      status: (json['status'] ?? 'draft').toString(),
      startsAt: DateTime.tryParse(startsAtRaw),
      endsAt: DateTime.tryParse(endsAtRaw),
      primaryAudience:
          (json['primary_audience'] ?? '').toString().trim().isEmpty
          ? null
          : (json['primary_audience'] ?? '').toString(),
      primaryActions: actions,
      heroImageUrl: (json['hero_image_url'] ?? '').toString().trim().isEmpty
          ? null
          : (json['hero_image_url'] ?? '').toString(),
      priority: _asInt(priorityRaw),
      visibility: visibility,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_user_id': ownerUserId,
      'title': title,
      'slug': slug,
      'summary': summary,
      'description': description,
      'objective_type': objectiveType,
      'status': status,
      'starts_at': startsAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'primary_audience': primaryAudience,
      'primary_actions': primaryActions,
      'hero_image_url': heroImageUrl,
      'priority': priority,
      'visibility': visibility,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

@immutable
class CampaignListItemModel {
  const CampaignListItemModel({required this.campaign, required this.isJoined});

  final CampaignModel campaign;
  final bool isJoined;

  factory CampaignListItemModel.fromJoinedRow(Map<String, dynamic> row) {
    final cRaw = row['campaigns'] is Map
        ? Map<String, dynamic>.from(row['campaigns'] as Map)
        : row;
    // We treat “joined” as “the user has any user_missions row with campaign_id”.
    final joined =
        (row['joined'] == true) || (row['has_user_missions'] == true);
    return CampaignListItemModel(
      campaign: CampaignModel.fromJson(cRaw),
      isJoined: joined,
    );
  }
}
