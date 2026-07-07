import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService extends ChangeNotifier {
  PostService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client; // ignore: unused_field
<<<<<<< HEAD
  final List<Map<String, dynamic>> _items = [];
=======
  final List<dynamic> _items = [];
>>>>>>> de0a337 (fix: resolve all 20 compile errors and 30+ static analysis warnings)
  bool _isLoading = false; // ignore: prefer_final_fields

  SupabaseClient get client => _client;
  List<Map<String, dynamic>> get posts => List.unmodifiable(_items);
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
}
