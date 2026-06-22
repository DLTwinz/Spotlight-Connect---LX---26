import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonetizationService extends ChangeNotifier {
  List<dynamic> _cachedPlans = [];
  List<dynamic> get plans => _cachedPlans;
  Future<void> loadPlans() async {
    _cachedPlans = await Supabase.instance.client.from('plans').select();
    notifyListeners();
  }
  static const double platformFee = 0.05; 
  static const double agencyFee = 0.15;

  Future<void> ensureInitialized() async {}
  
  // Update these to accept the 'userId' or 'id' parameters the UI sends
  double totalEarnedUsd({String? userId}) => 0.0;
  double totalSpentUsd({String? userId}) => 0.0;
  
  List get transactions => [];
  Future<List<dynamic>> fetchPlans() async {
    final response = await Supabase.instance.client.from('plans').select();
    return response as List<dynamic>;
  }

  // Match the named parameters used in monetization_sheets.dart
  bool isSubscribed({String? subscriberUserId, String? creatorUserId}) => false;
  
  Future<void> subscribe({String? subscriberUserId, String? creatorUserId, String? planId}) async {}
  Future<void> cancelSubscription({String? subscriberUserId, String? creatorUserId}) async {}
  
  Future<void> tipCreator({
    required String fromUserId, 
    required String toUserId, 
    required double amountUsd, 
    String? note
  }) async {}

  // Payout profile methods
  Future<dynamic> getOrCreatePayoutProfile({String? userId, String? displayName}) async { return null; }
  Future<void> updatePayoutProfile({String? userId, String? displayName, String? payoutMethod, String? payoutHandle}) async {}

  static Map<String, double> calculateSplit(double totalAmount) {
    double spotlightCut = totalAmount * platformFee;
    double agencyCut = totalAmount * agencyFee;
  return {
      'talent_net': totalAmount - (spotlightCut + agencyCut),
    };
  }
}