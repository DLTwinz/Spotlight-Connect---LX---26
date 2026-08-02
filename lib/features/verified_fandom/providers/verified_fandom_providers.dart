import 'package:flutter/material.dart';
import 'package:spotlight_connect/features/verified_fandom/data/verified_fandom_client.dart';
import 'package:spotlight_connect/supabase/supabase_config.dart';

enum TrustLabel {
  verified,
  repeatSupporter,
  ambassadorCandidate,
  ambassador,
  captain,
  riskFlagged,
}

class VerifiedFandomProvider extends ChangeNotifier {
  // Initialize the client with SupabaseConfig.client
  late final VerifiedFandomClient client = VerifiedFandomClient(
    SupabaseConfig.client,
  );

  bool _isWriting = false;
  bool get isWriting => _isWriting;
  String? _lastError;
  String? get lastError => _lastError;
  DateTime? lastActionTime;

  TrustLabel get trustStatus => TrustLabel.verified;

  bool get isThrottled {
    if (lastActionTime == null) return false;
    return DateTime.now().difference(lastActionTime!).inMinutes < 5;
  }

  Future<bool> runWriteGuarded(Future<void> Function() operation) async {
    _isWriting = true;
    _lastError = null;
    notifyListeners();
    try {
      await operation();
      return true;
    } catch (e) {
      _lastError = e.toString();
      return false;
    } finally {
      _isWriting = false;
      notifyListeners();
    }
  }

  Future<void> addVerifiedStamp(String stampId) async {
    if (isThrottled) return;
    await runWriteGuarded(() async {
      final userId = client.supabase.auth.currentUser?.id ?? 'anon';
      // Call the verified_fandom_api edge function with add_stamp action
      await client.callAction(
        action: 'add_stamp',
        payload: {'stamp_id': stampId, 'user_id': userId},
      );
      lastActionTime = DateTime.now();
    });
  }
}
