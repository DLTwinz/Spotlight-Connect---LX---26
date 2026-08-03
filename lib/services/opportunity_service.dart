import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OpportunityService extends ChangeNotifier {
  final SupabaseClient _client;
  final dynamic _localCache; // ignore: unused_field
  List<Map<String, dynamic>> _opportunities = [];
  bool _isLoading = false;
  String? _lastError;

  OpportunityService({
    required SupabaseClient client,
    required dynamic localCache,
  })  : _client = client,
        _localCache = localCache {
    fetchActiveOpportunities();
  }

  List<Map<String, dynamic>> get opportunities => _opportunities;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<void> fetchActiveOpportunities() async {
    if (_isLoading) return;
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final data = await _client
          .from('opportunities')
          .select(
            'id, title, description, status, business_user_id, '
            'category, compensation_type, location_type, '
            'published_at, created_at, updated_at, approval_required',
          )
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 8));
      _opportunities = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      _lastError = e.toString();
      debugPrint('❌ FAILED TO FETCH OPPORTUNITIES: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// First instrumented workflow via SECURITY DEFINER RPC.
  Future<void> applyToOpportunity({
    required String opportunityId,
    String? pitch,
    String roleContext = 'talent',
  }) async {
    await _client.rpc('apply_to_opportunity', params: {
      'p_opportunity_id': opportunityId,
      'p_pitch': pitch,
    });
  }

  Future<void> createCampaign({
    required String title,
    required String description,
    required String brandId,
    String category = 'general',
    String compensationType = 'paid',
    String locationType = 'remote',
  }) async {
    try {
      await _client.from('opportunities').insert({
        'business_user_id': brandId,
        'title': title,
        'description': description,
        'status': 'open',
        'category': category,
        'compensation_type': compensationType,
        'location_type': locationType,
        'approval_required': true,
      });
      await fetchActiveOpportunities();
    } catch (e) {
      debugPrint('❌ CAMPAIGN CREATE FAILED: $e');
      rethrow;
    }
  }
}
