import 'package:flutter/foundation.dart';

@immutable
class CommentModel {
  const CommentModel({
    required this.commentId,
    required this.postId,
    required this.authorId,
    required this.authorDisplayName,
    required this.authorPrimaryRole,
    required this.text,
    required this.createdAt,
  });

  final String commentId;
  final String postId;
  final String authorId;
  final String authorDisplayName;
  final String authorPrimaryRole;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'commentId': commentId,
    'postId': postId,
    'authorId': authorId,
    'authorDisplayName': authorDisplayName,
    'authorPrimaryRole': authorPrimaryRole,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  static CommentModel? tryFromJson(Object? raw) {
    try {
      if (raw is! Map) return null;
      final commentId = raw['commentId'];
      final postId = raw['postId'];
      final authorId = raw['authorId'];
      final authorDisplayName = raw['authorDisplayName'];
      final authorPrimaryRole = raw['authorPrimaryRole'];
      final text = raw['text'];
      final createdAt = raw['createdAt'];

      if (commentId is! String ||
          postId is! String ||
          authorId is! String ||
          authorDisplayName is! String ||
          authorPrimaryRole is! String ||
          text is! String ||
          createdAt is! String) {
        return null;
      }

      final parsedCreatedAt = DateTime.tryParse(createdAt);
      if (parsedCreatedAt == null) return null;

      return CommentModel(
        commentId: commentId,
        postId: postId,
        authorId: authorId,
        authorDisplayName: authorDisplayName,
        authorPrimaryRole: authorPrimaryRole,
        text: text,
        createdAt: parsedCreatedAt,
      );
    } catch (_) {
      return null;
    }
  }
}
