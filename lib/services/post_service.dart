import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotlight_connect/models/post_model.dart';
import 'package:spotlight_connect/models/comment_model.dart';

class PostService extends ChangeNotifier {
  PostService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  bool _isLoading = false;
  List<PostModel> _posts = [];

  bool get isLoading => _isLoading;
  List<PostModel> get posts => _posts;
  List<PostModel> get items => _posts;

  bool isLiked(String id) => false;
  bool isReposted(String id) => false;
  bool isSaved(String id) => false;

  Future<void> toggleLike(String id) async {
    // TODO: Implement like behavior
    notifyListeners();
  }

  Future<void> toggleRepost({required String postId, required String reposterId, required String reposterDisplayName, required String reposterPrimaryRole}) async {
    // TODO: Implement repost behavior
    notifyListeners();
  }

  Future<void> toggleSave(String id) async {
    // TODO: Implement save behavior
    notifyListeners();
  }

  List<CommentModel> commentsFor(String id) => [];

  Future<void> addComment({required String postId, required String authorId, required String authorDisplayName, required String authorPrimaryRole, required String text}) async {
    // TODO: Implement add comment
    notifyListeners();
  }

  Future<void> ensureInitialized() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final rows = await _client.from('posts').select('*').order('created_at', ascending: false).limit(50);
      _posts = (rows as List).map((row) => PostModel.fromJson(row as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('PostService ensureInitialized failed: $e');
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
      final rows = await _client.from('posts').select('*').order('created_at', ascending: false).range(_posts.length, _posts.length + 20 - 1);
      final more = (rows as List).map((row) => PostModel.fromJson(row as Map<String, dynamic>)).toList();
      _posts = [..._posts, ...more];
    } catch (e) {
      debugPrint('PostService loadMore failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
