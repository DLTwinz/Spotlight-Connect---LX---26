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
import 'package:spotlight_connect/services/monetization_service.dart';

// Production Environment Guard Rails
abstract class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mdwvokenmehdfybgujpa.supabase.co',
  );
  static const String supabaseKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kd3Zva2VubWVoZGZ5Ymd1anBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyODAzMzUsImV4cCI6MjA5MTg1NjMzNX0.tds2VeVEl05jd3cbaC4vutxnLRtTF6i2d5MMAJS3KJk',
  );

  static void validate() {
    if (supabaseUrl.isEmpty ||
        supabaseKey.isEmpty ||
        supabaseUrl == 'https://mdwvokenmehdfybgujpa.supabase.co' ||
        supabaseKey == 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kd3Zva2VubWVoZGZ5Ymd1anBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyODAzMzUsImV4cCI6MjA5MTg1NjMzNX0.tds2VeVEl05jd3cbaC4vutxnLRtTF6i2d5MMAJS3KJk') {
      throw Exception(
        'PRODUCTION BOOT DENIED: Live Supabase credentials are empty or misconfigured.',
      );
    }
  }
}

void main() async {
  // Ensure engine bindings are alive before running async setups
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enforce credentials check before opening live Supabase connections
  EnvConfig.validate();

  // Initialize Supabase using the validated environment variables
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
    _featureFlag_provider = FeatureFlagProvider(store: createKeyValueStore());
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
        ChangeNotifierProvider(create: (_) => MonetizationService(client: _dbClient)),
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
          colorScheme: const ColorScheme.dark(
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
