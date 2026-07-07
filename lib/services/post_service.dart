import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService extends ChangeNotifier {
  final SupabaseClient _client;
  List<dynamic> _items = [];
  bool _isLoading = false;

  PostService({required SupabaseClient client}) : _client = client {
    ensureInitialized();
  }

  // UI expects both 'items' and 'posts' in different places
  List<dynamic> get items => _items;
  List<dynamic> get posts => _items;
  bool get isLoading => _isLoading;

  Future<void> ensureInitialized() async {}

  void streamLiveFeed() {}

  bool isLiked(String postId) => false;
  bool isReposted(String postId) => false;
  bool isSaved(String postId) => false;
  List<dynamic> commentsFor(String postId) => [];

  Future<void> toggleLike(String postId) async {}
  
  Future<void> toggleRepost({
    required String postId,
    required String reposterId,
    required String reposterDisplayName,
    required String reposterPrimaryRole,
  }) async {}

  Future<void> toggleSave(String postId) async {}

  Future<void> addComment({
    required String postId,
    required String authorId,
    required String authorDisplayName,
    required String authorPrimaryRole,
    required String text,
  }) async {}

  Future<void> loadMore() async {}

  Future<void> publishPost({required String content, required String creatorId, List<String>? assetUrls}) async {}
}
