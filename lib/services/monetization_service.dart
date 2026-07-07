import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonetizationService extends ChangeNotifier {
  final SupabaseClient _client;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;

  MonetizationService({required SupabaseClient client}) : _client = client;

  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> fetchUserLedger(String profileId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _client
          .from('monetization_ledger')
          .select()
          .or('recipient_id.eq.$profileId,sender_id.eq.$profileId')
          .order('created_at', ascending: false);
      _transactions = List<Map<String, dynamic>>.from(data);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordTransaction({required String recipientId, required String senderId, required int amountCents, required String type}) async {
    try {
      await _client.from('monetization_ledger').insert({
        'recipient_id': recipientId,
        'sender_id': senderId,
        'amount_cents': amountCents,
        'transaction_type': type,
      });
    } catch (e) {
      debugPrint('❌ ESCROW/LEDGER TRANSMISSION ERROR: $e');
      rethrow;
    }
  }
}
