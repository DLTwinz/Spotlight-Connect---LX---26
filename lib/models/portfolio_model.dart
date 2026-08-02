import 'package:flutter/foundation.dart';

enum PortfolioRole { talent, business }

@immutable
class PortfolioCredit {
  final String id;
  final String title;
  final String? subtitle;
  final int year;

  const PortfolioCredit({
    required this.id,
    required this.title,
    this.subtitle,
    required this.year,
  });

  factory PortfolioCredit.fromJson(Map<String, dynamic> json) =>
      PortfolioCredit(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        subtitle: json['subtitle']?.toString(),
        year: (json['year'] is num)
            ? (json['year'] as num).toInt()
            : int.tryParse((json['year'] ?? '').toString()) ??
                  DateTime.now().year,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'year': year,
  };
}

@immutable
class PortfolioModel {
  final String userId;
  final PortfolioRole role;
  final String headline;
  final String location;
  final List<String> genres;
  final List<String> skills;
  final int? dayRateUsd;
  final Map<String, String> links;
  final List<String> media;
  final List<PortfolioCredit> credits;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PortfolioModel({
    required this.userId,
    required this.role,
    required this.headline,
    required this.location,
    required this.genres,
    required this.skills,
    required this.dayRateUsd,
    required this.links,
    required this.media,
    required this.credits,
    required this.createdAt,
    required this.updatedAt,
  });

  PortfolioModel copyWith({
    PortfolioRole? role,
    String? headline,
    String? location,
    List<String>? genres,
    List<String>? skills,
    int? dayRateUsd,
    Map<String, String>? links,
    List<String>? media,
    List<PortfolioCredit>? credits,
    DateTime? updatedAt,
  }) => PortfolioModel(
    userId: userId,
    role: role ?? this.role,
    headline: headline ?? this.headline,
    location: location ?? this.location,
    genres: genres ?? this.genres,
    skills: skills ?? this.skills,
    dayRateUsd: dayRateUsd ?? this.dayRateUsd,
    links: links ?? this.links,
    media: media ?? this.media,
    credits: credits ?? this.credits,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] ?? 'talent').toString();
    return PortfolioModel(
      userId: (json['userId'] ?? '').toString(),
      role: roleStr == 'business'
          ? PortfolioRole.business
          : PortfolioRole.talent,
      headline: (json['headline'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      genres: (json['genres'] is List)
          ? (json['genres'] as List).map((e) => e.toString()).toList()
          : const <String>[],
      skills: (json['skills'] is List)
          ? (json['skills'] as List).map((e) => e.toString()).toList()
          : const <String>[],
      dayRateUsd: (json['dayRateUsd'] is num)
          ? (json['dayRateUsd'] as num).toInt()
          : int.tryParse((json['dayRateUsd'] ?? '').toString()),
      links: (json['links'] is Map)
          ? (json['links'] as Map).map(
              (k, v) => MapEntry(k.toString(), v.toString()),
            )
          : const <String, String>{},
      media: (json['media'] is List)
          ? (json['media'] as List).map((e) => e.toString()).toList()
          : const <String>[],
      credits: (json['credits'] is List)
          ? (json['credits'] as List)
                .whereType<Map>()
                .map(
                  (e) => PortfolioCredit.fromJson(
                    e.map((k, v) => MapEntry(k.toString(), v)),
                  ),
                )
                .toList()
          : const <PortfolioCredit>[],
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'role': role.name,
    'headline': headline,
    'location': location,
    'genres': genres,
    'skills': skills,
    'dayRateUsd': dayRateUsd,
    'links': links,
    'media': media,
    'credits': credits.map((c) => c.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
