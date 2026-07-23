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
import 'package:spotlight_connect/services/monetization_service.dart';
import 'package:spotlight_connect/storage/key_value_store.dart';

abstract class EnvConfig {
  static const String _placeholderUrl =
      'https://mdwvokenmehdfybgujpa.supabase.co';
  static const String _placeholderAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kd3Zva2VubWVoZGZ5Ymd1anBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyODAzMzUsImV4cCI6MjA5MTg1NjMzNX0.tds2VeVEl05jd3cbaC4vutxnLRtTF6i2d5MMAJS3KJk';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _placeholderUrl,
  );

  static const String supabaseKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: _placeholderAnonKey,
  );

  static void validate() {
    final url = supabaseUrl.trim();
    final key = supabaseKey.trim();

    final badUrl =
        url.isEmpty ||
        url == _placeholderUrl ||
        !url.startsWith('https://') ||
        !url.contains('.supabase.co');

    final badKey =
        key.isEmpty ||
        key == _placeholderAnonKey ||
        key.startsWith('<') ||
        key.endsWith('>') ||
        key.length < 100;

    if (badUrl || badKey) {
      throw Exception(
        'PRODUCTION BOOT DENIED: Live Supabase credentials are empty or misconfigured. '
        'Pass real values with --dart-define=SUPABASE_URL=... and '
        '--dart-define=SUPABASE_ANON_KEY=...',
      );
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.validate();

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
    _dbClient = Supabase.instance.client;
    _authProvider = SupabaseAuthProvider();
    _featureFlagProvider = FeatureFlagProvider(store: createKeyValueStore());
    _progressionFeaturePolicyProvider = ProgressionFeaturePolicyProvider(
      authProvider: _authProvider,
    );
    _router = AppRouter.createRouter(_authProvider);

    Future.microtask(() async {
      await _authProvider.ensureInitialized();
      await _featureFlagProvider.ensureInitialized();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppAuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<FeatureFlagProvider>.value(
          value: _featureFlagProvider,
        ),
        ChangeNotifierProvider<ProgressionFeaturePolicyProvider>.value(
          value: _progressionFeaturePolicyProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationService(client: _dbClient),
        ),
        ChangeNotifierProvider(
          create: (_) => MessageService(client: _dbClient),
        ),
        ChangeNotifierProvider(create: (_) => PostService(client: _dbClient)),
        ChangeNotifierProvider(
          create: (_) => GroupService(
            client: _dbClient,
            localCache: createKeyValueStore(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PortfolioService(
            client: _dbClient,
            localCache: createKeyValueStore(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => StoryService(
            client: _dbClient,
            localCache: createKeyValueStore(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OpportunityService(
            client: _dbClient,
            localCache: createKeyValueStore(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MonetizationService(client: _dbClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ProgressionService(client: _dbClient),
        ),
        Provider(create: (_) => StudioService(client: _dbClient)),
        Provider(create: (_) => MissionComposerService(client: _dbClient)),
      ],
      child: MaterialApp.router(
        title: 'SPOTLIGHT Connect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
        routerConfig: _router,
      ),
    );
  }
}
