// Minimal stub for MonetizationService to satisfy DI in main.dart.
// Replace with the real implementation when available.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonetizationService extends ChangeNotifier {
  MonetizationService({SupabaseClient? client});

  // Example API surface used in the app — expand as needed.
  Future<void> initialize() async {}
}
