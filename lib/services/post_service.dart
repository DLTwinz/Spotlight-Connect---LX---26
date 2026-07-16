import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:spotlight_connect/models/comment_model.dart';
import 'package:spotlight_connect/models/post_model.dart';

class PostService extends ChangeNotifier {
  PostService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  final List<PostModel> _items = [];
  final Set<String> _likedPostIds = <String>{};
  final Set<String> _savedPostIds = <String>{};
  final Set<String> _repostedPostIds = <String>{};
  final Map<String, List<CommentModel>> _commentsByPostId =
      <String, List<CommentModel>>{};
  bool _isLoading = false;

  SupabaseClient get client => _client;
  List<PostModel> get posts => List.unmodifiable(_items);
  List<PostModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  Future<void> ensureInitialized() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final rows = await _client
          .from('posts')
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);

      final parsed = (rows as List)
          .map((row) => _mapRowToPost(row))
          .whereType<PostModel>()
          .toList();

      _items
        ..clear()
        ..addAll(parsed);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final start = _items.length;
      final end = start + 49;
      final rows = await _client
          .from('posts')
          .select('*')
          .order('created_at', ascending: false)
          .range(start, end);

      final parsed = (rows as List)
          .map((row) => _mapRowToPost(row))
          .whereType<PostModel>()
          .toList();

      _items.addAll(
        parsed.where((post) => !_items.any((p) => p.postId == post.postId)),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isLiked(String postId) => _likedPostIds.contains(postId);
  bool isSaved(String postId) => _savedPostIds.contains(postId);
  bool isReposted(String postId) => _repostedPostIds.contains(postId);

  List<CommentModel> commentsFor(String postId) =>
      List.unmodifiable(_commentsByPostId[postId] ?? const <CommentModel>[]);

  Future<void> toggleLike(String postId) async {
    final index = _items.indexWhere((p) => p.postId == postId);
    if (index == -1) return;

    final post = _items[index];
    final alreadyLiked = _likedPostIds.contains(postId);

    if (alreadyLiked) {
      _likedPostIds.remove(postId);
      _items[index] = post.copyWith(
        likeCount: post.likeCount > 0 ? post.likeCount - 1 : 0,
      );
    } else {
      _likedPostIds.add(postId);
      _items[index] = post.copyWith(likeCount: post.likeCount + 1);
    }
    notifyListeners();
  }

  Future<void> toggleSave(String postId) async {
    if (_savedPostIds.contains(postId)) {
      _savedPostIds.remove(postId);
    } else {
      _savedPostIds.add(postId);
    }
    notifyListeners();
  }

  Future<void> toggleRepost({
    required String postId,
    required String reposterId,
    required String reposterDisplayName,
    required String reposterPrimaryRole,
  }) async {
    final index = _items.indexWhere((p) => p.postId == postId);
    if (index == -1) return;

    final post = _items[index];
    final alreadyReposted = _repostedPostIds.contains(postId);

    if (alreadyReposted) {
      _repostedPostIds.remove(postId);
      _items[index] = post.copyWith(
        repostCount: post.repostCount > 0 ? post.repostCount - 1 : 0,
      );
      notifyListeners();
      return;
    }

    _repostedPostIds.add(postId);
    _items[index] = post.copyWith(repostCount: post.repostCount + 1);

    final repost = PostModel(
      postId: 'repost-${DateTime.now().microsecondsSinceEpoch}',
      authorId: reposterId,
      authorDisplayName: reposterDisplayName,
      authorPrimaryRole: reposterPrimaryRole,
      groupId: post.groupId,
      text: '',
      likeCount: 0,
      commentCount: 0,
      repostCount: 0,
      tags: post.tags,
      repostOfPostId: post.postId,
      repostOfAuthorDisplayName: post.authorDisplayName,
      repostOfAuthorPrimaryRole: post.authorPrimaryRole,
      repostOfText: post.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _items.insert(0, repost);
    notifyListeners();
  }

  Future<void> addComment({
    required String postId,
    required String authorId,
    required String authorDisplayName,
    required String authorPrimaryRole,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final comment = CommentModel(
      commentId: 'comment-${DateTime.now().microsecondsSinceEpoch}',
      postId: postId,
      authorId: authorId,
      authorDisplayName: authorDisplayName,
      authorPrimaryRole: authorPrimaryRole,
      text: trimmed,
      createdAt: DateTime.now(),
    );

    final list = List<CommentModel>.from(
      _commentsByPostId[postId] ?? const <CommentModel>[],
    )..add(comment);
    _commentsByPostId[postId] = list;

    final index = _items.indexWhere((p) => p.postId == postId);
    if (index != -1) {
      final post = _items[index];
      _items[index] = post.copyWith(commentCount: post.commentCount + 1);
    }

    notifyListeners();
  }

  PostModel? _mapRowToPost(Object? raw) {
    if (raw is! Map) return null;
    final row = Map<String, dynamic>.from(raw);

    return PostModel.tryFromJson({
      'postId': _asString(row['post_id'] ?? row['id']),
      'authorId': _asString(row['author_id']),
      'authorDisplayName': _asString(
        row['author_display_name'] ??
            row['display_name'] ??
            row['username'] ??
            'Spotlight User',
      ),
      'authorPrimaryRole': _asString(
        row['author_primary_role'] ?? row['primary_role'] ?? 'audience',
      ),
      'groupId': _asNullableString(row['group_id']),
      'text': _asString(row['text'] ?? row['body'] ?? ''),
      'likeCount': _asInt(row['like_count']),
      'commentCount': _asInt(row['comment_count']),
      'repostCount': _asInt(row['repost_count']),
      'tags': _asStringList(row['tags']),
      'repostOfPostId': _asNullableString(row['repost_of_post_id']),
      'repostOfAuthorDisplayName': _asNullableString(
        row['repost_of_author_display_name'],
      ),
      'repostOfAuthorPrimaryRole': _asNullableString(
        row['repost_of_author_primary_role'],
      ),
      'repostOfText': _asNullableString(row['repost_of_text']),
      'createdAt': _asDateTimeString(row['created_at']),
      'updatedAt': _asDateTimeString(row['updated_at'] ?? row['created_at']),
    });
  }

  String _asString(Object? value) {
    if (value == null) return '';
    return value.toString();
  }

  String? _asNullableString(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  List<String> _asStringList(Object? value) {
    if (value is List) {
      return value
          .whereType<Object>()
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  String _asDateTimeString(Object? value) {
    if (value is String && DateTime.tryParse(value) != null) return value;
    if (value is DateTime) return value.toIso8601String();
    return DateTime.now().toIso8601String();
  }
}
