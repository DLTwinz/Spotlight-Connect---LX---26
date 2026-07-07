import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OpportunityService extends ChangeNotifier {
  final SupabaseClient _client;
  final dynamic _localCache;
  List<Map<String, dynamic>> _opportunities = [];
  bool _isLoading = false;

  OpportunityService({required SupabaseClient client, required dynamic localCache}) 
      : _client = client, 
        _localCache = localCache {
    fetchActiveOpportunities();
  }

  List<Map<String, dynamic>> get opportunities => _opportunities;
  bool get isLoading => _isLoading;

  Future<void> fetchActiveOpportunities() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _client
          .from('opportunities')
          .select('*, profiles(username, display_name, avatar_url)')
          .order('created_at', ascending: false);
      _opportunities = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('❌ FAILED TO FETCH PRODUCTION CAMPAIGNS: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCampaign({required String title, required String description, required int budgetCents, required String brandId}) async {
    try {
      await _client.from('opportunities').insert({
        'brand_id': brandId,
        'title': title,
        'description': description,
        'budget_cents': budgetCents,
        'status': 'open',
      });
      await fetchActiveOpportunities();
    } catch (e) {
      debugPrint('❌ PRODUCTION CAMPAIGN CREATION FAILURE: $e');
      rethrow;
    }
  }
}
