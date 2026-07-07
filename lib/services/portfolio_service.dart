import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PortfolioService extends ChangeNotifier {
  PortfolioService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  final List<Map<String, dynamic>> _localCache = [];

  SupabaseClient get client => _client;
  List<Map<String, dynamic>> get items => List.unmodifiable(_localCache);

  Future<void> ensureInitialized() async {
    final me = _client.auth.currentUser;
    if (me == null) return;
    final rows = await _client
        .from('portfolio_items')
        .select('*')
        .eq('user_id', me.id)
        .order('created_at', ascending: false);
    _localCache
      ..clear()
      ..addAll(List<Map<String, dynamic>>.from(rows as List));
    notifyListeners();
  }
}
