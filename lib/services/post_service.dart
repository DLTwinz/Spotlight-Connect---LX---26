import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotlight_connect/models/comment_model.dart';
import 'package:spotlight_connect/models/post_model.dart';

class PostService extends ChangeNotifier {
  bool _isLoading = false;
  List<PostModel> _posts = [];

  bool get isLoading => _isLoading;
  List<PostModel> get posts => _posts;
  List<PostModel> get items => _posts;

  bool isLiked(String id) => false;
  bool isReposted(String id) => false;
  bool isSaved(String id) => false;

  Future<void> toggleLike(String id) async { notifyListeners(); }
  
  Future<void> toggleRepost({required String postId, required String reposterId, required String reposterDisplayName, required String reposterPrimaryRole}) async { 
    notifyListeners(); 
  }

  Future<void> toggleSave(String id) async { notifyListeners(); }

  List<CommentModel> commentsFor(String id) => [];
  
  Future<void> addComment({required String postId, required String authorId, required String authorDisplayName, required String authorPrimaryRole, required String text}) async { 
    notifyListeners(); 
  }

  Future<void> ensureInitialized() async {}

  Future<void> loadMore() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final raw = await Supabase.instance.client.from('posts').select('*').limit(20);
      _posts = (raw as List).map((row) => PostModel.fromJson(row as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
