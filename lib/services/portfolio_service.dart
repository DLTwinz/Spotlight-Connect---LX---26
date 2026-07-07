import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PortfolioService extends ChangeNotifier {
  final SupabaseClient _client;
  final dynamic _localCache;
  Map<String, dynamic>? _activePortfolio;

  PortfolioService({required SupabaseClient client, required dynamic localCache}) 
      : _client = client, 
        _localCache = localCache;

  Map<String, dynamic>? get activePortfolio => _activePortfolio;

  Future<void> loadCreatorPortfolio(String creatorId) async {
    try {
      final data = await _client
          .from('portfolios')
          .select('*, portfolio_items(*)')
          .eq('creator_id', creatorId)
          .maybeSingle();
      _activePortfolio = data;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ PORTFOLIO ATTR ENGINE ERROR: $e');
    }
  }
}
