import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:spotlight_connect/nav.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/providers/feature_flag_provider.dart';
import 'package:spotlight_connect/providers/progression_feature_policy_provider.dart';
import 'package:spotlight_connect/providers/supabase_auth_provider.dart';
import 'package:spotlight_connect/services/group_service.dart';
import 'package:spotlight_connect/services/message_service.dart';
import 'package:spotlight_connect/services/mission_composer_services.dart';
import 'package:spotlight_connect/services/notification_service.dart';
import 'package:spotlight_connect/services/opportunity_service.dart';
import 'package:spotlight_connect/services/portfolio_service.dart';
import 'package:spotlight_connect/services/post_service.dart';
import 'package:spotlight_connect/services/story_service.dart';
import 'package:spotlight_connect/services/studio_service.dart';
import 'package:spotlight_connect/services/progression_service.dart';
import 'package:spotlight_connect/storage/key_value_store.dart';

// Production Environment Guard Rails
abstract class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL_HERE', 
  );
  static const String supabaseKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY_HERE',
  );

  static void validate() {
    if (supabaseUrl.isEmpty || 
        supabaseKey.isEmpty || 
        supabaseUrl == 'YOUR_SUPABASE_URL_HERE' || 
        supabaseKey == 'YOUR_SUPABASE_ANON_KEY_HERE') {
      throw Exception('PRODUCTION BOOT DENIED: Live Supabase credentials are empty or misconfigured.');
    }
  }
}

void main() async {
  // Ensure engine bindings are alive before running async setups
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enforce credentials check
  EnvConfig.validate();

  // Establish live persistent database socket connections
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    publishableKey: EnvConfig.supabaseKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppAuthProvider _authProvider;
  late final FeatureFlagProvider _featureFlagProvider;
  late final ProgressionFeaturePolicyProvider _progressionFeaturePolicyProvider;
  late final GoRouter _router;
  late final SupabaseClient _dbClient;

  @override
  void initState() {
    super.initState();
    // Capture the active production client instance
    _dbClient = Supabase.instance.client;

    // Core Security & Routing Engine Architecture
    _authProvider = SupabaseAuthProvider();
    _featureFlagProvider = FeatureFlagProvider(store: createKeyValueStore());
    _progressionFeaturePolicyProvider = ProgressionFeaturePolicyProvider(authProvider: _authProvider);
    _router = AppRouter.createRouter(_authProvider);

    // Initialize synchronous production configurations
    Future.microtask(_featureFlagProvider.ensureInitialized);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // System Identity & Authorization Dependencies
        ChangeNotifierProvider<AppAuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<FeatureFlagProvider>.value(value: _featureFlagProvider),
        ChangeNotifierProvider<ProgressionFeaturePolicyProvider>.value(value: _progressionFeaturePolicyProvider),
        
        // Live Infrastructure Data Pipelines (Passing the active dbClient directly)
        ChangeNotifierProvider(create: (_) => NotificationService(client: _dbClient)),
        ChangeNotifierProvider(create: (_) => MessageService(client: _dbClient)),
        ChangeNotifierProvider(create: (_) => PostService(client: _dbClient)),
        ChangeNotifierProvider(create: (_) => GroupService(client: _dbClient, localCache: createKeyValueStore())),
        ChangeNotifierProvider(create: (_) => PortfolioService(client: _dbClient, localCache: createKeyValueStore())),
        ChangeNotifierProvider(create: (_) => StoryService(client: _dbClient, localCache: createKeyValueStore())),
        ChangeNotifierProvider(create: (_) => OpportunityService(client: _dbClient, localCache: createKeyValueStore())),  
        ChangeNotifierProvider(create: (_) => MonetizationService(client: client)),
        ChangeNotifierProvider(create: (_) => ProgressionService(client: _dbClient)),
        
        // Stateless Operational Engine Services
        Provider(create: (_) => StudioService(client: _dbClient)),
        Provider(create: (_) => MissionComposerService(client: _dbClient)),
      ],
      child: MaterialApp.router(
        title: 'SPOTLIGHT Connect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          primaryColor: const Color(0xFF39FF14), // Spotlight Cyber Green
          colorScheme: const ColorScheme.dark( y
            primary: Color(0xFF39FF14),
            secondary: Color(0xFFD4AF37), // Brand Impact Gold
            surface: Color(0xFF1A1A1A),
          ),
        ),
        themeMode: ThemeMode.dark,
        routerConfig: _router,
      ),
    );
  }
}