import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService extends ChangeNotifier {
  PostService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  final List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  SupabaseClient get client => _client;
  List<Map<String, dynamic>> get posts => List.unmodifiable(_items);
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);
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
      _items
        ..clear()
        ..addAll(List<Map<String, dynamic>>.from(rows as List));
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
      final rows = await _client
          .from('posts')
          .select('*')
          .order('created_at', ascending: false)
          .limit(50)
          .offset(_items.length);
      _items.addAll(List<Map<String, dynamic>>.from(rows as List));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
