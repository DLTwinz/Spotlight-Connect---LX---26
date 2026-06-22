import 'package:flutter/foundation.dart';

@immutable
class OpportunityModel {
  const OpportunityModel({
    required this.opportunityId,
    required this.postedByUserId,
    required this.postedByEmail,
    required this.postedByRole,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.compensation,
    required this.description,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final String opportunityId;
  final String postedByUserId;
  /// Email of the business/admin that posted the opportunity (used for local notifications).
  /// May be empty for seeded opportunities.
  final String postedByEmail;
  /// business | admin | seed
  final String postedByRole;
  final String title;
  final String company;
  final String location;
  /// Examples: Casting, Brand deal, Gig, Sponsorship, Collab
  final String type;
  final String compensation;
  final String description;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  OpportunityModel copyWith({
    String? opportunityId,
    String? postedByUserId,
    String? postedByEmail,
    String? postedByRole,
    String? title,
    String? company,
    String? location,
    String? type,
    String? compensation,
    String? description,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OpportunityModel(
      opportunityId: opportunityId ?? this.opportunityId,
      postedByUserId: postedByUserId ?? this.postedByUserId,
      postedByEmail: postedByEmail ?? this.postedByEmail,
      postedByRole: postedByRole ?? this.postedByRole,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      type: type ?? this.type,
      compensation: compensation ?? this.compensation,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'opportunityId': opportunityId,
      'postedByUserId': postedByUserId,
      'postedByEmail': postedByEmail,
      'postedByRole': postedByRole,
      'title': title,
      'company': company,
      'location': location,
      'type': type,
      'compensation': compensation,
      'description': description,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    return OpportunityModel(
      opportunityId: (json['opportunityId'] ?? '').toString(),
      postedByUserId: (json['postedByUserId'] ?? 'seed_business').toString(),
      postedByEmail: (json['postedByEmail'] ?? '').toString(),
      postedByRole: (json['postedByRole'] ?? 'seed').toString(),
      title: (json['title'] ?? '').toString(),
      company: (json['company'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      compensation: (json['compensation'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      tags: tagsRaw is List ? tagsRaw.map((e) => e.toString()).toList() : const <String>[],
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
