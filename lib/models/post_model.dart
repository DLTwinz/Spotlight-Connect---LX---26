import 'package:flutter/foundation.dart';

@immutable
class PostModel {
  const PostModel({
    required this.postId,
    required this.authorId,
    required this.authorDisplayName,
    required this.authorPrimaryRole,
    this.groupId,
    required this.text,
    required this.likeCount,
    required this.commentCount,
    required this.repostCount,
    required this.tags,
    this.repostOfPostId,
    this.repostOfAuthorDisplayName,
    this.repostOfAuthorPrimaryRole,
    this.repostOfText,
    required this.createdAt,
    required this.updatedAt,
  });

  final String postId;
  final String authorId;
  final String authorDisplayName;
  final String authorPrimaryRole;
  final String? groupId;
  final String text;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final List<String> tags;

  /// If set, this post is a repost of another post.
  final String? repostOfPostId;
  final String? repostOfAuthorDisplayName;
  final String? repostOfAuthorPrimaryRole;
  final String? repostOfText;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel copyWith({
    String? postId,
    String? authorId,
    String? authorDisplayName,
    String? authorPrimaryRole,
    String? groupId,
    String? text,
    int? likeCount,
    int? commentCount,
    int? repostCount,
    List<String>? tags,
    String? repostOfPostId,
    String? repostOfAuthorDisplayName,
    String? repostOfAuthorPrimaryRole,
    String? repostOfText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorPrimaryRole: authorPrimaryRole ?? this.authorPrimaryRole,
      groupId: groupId ?? this.groupId,
      text: text ?? this.text,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      repostCount: repostCount ?? this.repostCount,
      tags: tags ?? this.tags,
      repostOfPostId: repostOfPostId ?? this.repostOfPostId,
      repostOfAuthorDisplayName:
          repostOfAuthorDisplayName ?? this.repostOfAuthorDisplayName,
      repostOfAuthorPrimaryRole:
          repostOfAuthorPrimaryRole ?? this.repostOfAuthorPrimaryRole,
      repostOfText: repostOfText ?? this.repostOfText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorDisplayName': authorDisplayName,
      'authorPrimaryRole': authorPrimaryRole,
      'groupId': groupId,
      'text': text,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'repostCount': repostCount,
      'tags': tags,
      'repostOfPostId': repostOfPostId,
      'repostOfAuthorDisplayName': repostOfAuthorDisplayName,
      'repostOfAuthorPrimaryRole': repostOfAuthorPrimaryRole,
      'repostOfText': repostOfText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final parsed = tryFromJson(json);
    if (parsed == null) {
      throw FormatException("Invalid PostModel JSON: $json");
    }
    return parsed;
  }

  static PostModel? tryFromJson(Object? raw) {
    try {
      if (raw is! Map) return null;
      final postId = raw['postId'];
      final authorId = raw['authorId'];
      final authorDisplayName = raw['authorDisplayName'];
      final authorPrimaryRole = raw['authorPrimaryRole'];
      final groupId = raw['groupId'];
      final text = raw['text'];
      final likeCount = raw['likeCount'];
      final commentCount = raw['commentCount'];
      final repostCount = raw['repostCount'];
      final tags = raw['tags'];
      final repostOfPostId = raw['repostOfPostId'];
      final repostOfAuthorDisplayName = raw['repostOfAuthorDisplayName'];
      final repostOfAuthorPrimaryRole = raw['repostOfAuthorPrimaryRole'];
      final repostOfText = raw['repostOfText'];
      final createdAt = raw['createdAt'];
      final updatedAt = raw['updatedAt'];

      if (postId is! String ||
          authorId is! String ||
          authorDisplayName is! String ||
          authorPrimaryRole is! String ||
          text is! String ||
          likeCount is! int ||
          commentCount is! int ||
          repostCount is! int ||
          createdAt is! String ||
          updatedAt is! String) {
        return null;
      }

      if (repostOfPostId != null && repostOfPostId is! String) return null;
      if (repostOfAuthorDisplayName != null &&
          repostOfAuthorDisplayName is! String)
        return null;
      if (repostOfAuthorPrimaryRole != null &&
          repostOfAuthorPrimaryRole is! String)
        return null;
      if (repostOfText != null && repostOfText is! String) return null;
      if (groupId != null && groupId is! String) return null;

      final parsedCreatedAt = DateTime.tryParse(createdAt);
      final parsedUpdatedAt = DateTime.tryParse(updatedAt);
      if (parsedCreatedAt == null || parsedUpdatedAt == null) return null;

      return PostModel(
        postId: postId,
        authorId: authorId,
        authorDisplayName: authorDisplayName,
        authorPrimaryRole: authorPrimaryRole,
        groupId: groupId as String?,
        text: text,
        likeCount: likeCount,
        commentCount: commentCount,
        repostCount: repostCount,
        tags: tags is List
            ? tags.whereType<String>().toList()
            : const <String>[],
        repostOfPostId: repostOfPostId as String?,
        repostOfAuthorDisplayName: repostOfAuthorDisplayName as String?,
        repostOfAuthorPrimaryRole: repostOfAuthorPrimaryRole as String?,
        repostOfText: repostOfText as String?,
        createdAt: parsedCreatedAt,
        updatedAt: parsedUpdatedAt,
      );
    } catch (_) {
      return null;
    }
  }
}
