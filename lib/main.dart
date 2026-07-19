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
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static void validate() {
    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      throw Exception(
        'PRODUCTION BOOT DENIED: SUPABASE_URL and SUPABASE_ANON_KEY must be provided via --dart-define.',
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
    _progressionFeaturePolicyProvider =
        ProgressionFeaturePolicyProvider(authProvider: _authProvider);
    _router = AppRouter.createRouter(_authProvider);

    Future.microtask(_featureFlagProvider.ensureInitialized);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SupabaseClient>.value(value: _dbClient),

        ChangeNotifierProvider<AppAuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<FeatureFlagProvider>.value(
          value: _featureFlagProvider,
        ),
        ChangeNotifierProvider<ProgressionFeaturePolicyProvider>.value(
          value: _progressionFeaturePolicyProvider,
        ),

        ChangeNotifierProxyProvider<SupabaseClient, NotificationService>(
          create: (context) =>
              NotificationService(client: context.read<SupabaseClient>()),
          update: (context, client, previous) =>
              previous ?? NotificationService(client: client),
        ),
        ChangeNotifierProxyProvider<SupabaseClient, MessageService>(
          create: (context) =>
              MessageService(client: context.read<SupabaseClient>()),
          update: (context, client, previous) =>
              previous ?? MessageService(client: client),
        ),
        ChangeNotifierProxyProvider<SupabaseClient, PostService>(
          create: (context) => PostService(client: context.read<SupabaseClient>()),
          update: (context, client, previous) =>
              previous ?? PostService(client: client),
        ),
        ChangeNotifierProxyProvider<SupabaseClient, GroupService>(
          create: (context) => GroupService(
            client: context.read<SupabaseClient>(),
            localCache: createKeyValueStore(),
          ),
          update: (context, client, previous) =>
              previous ??
              GroupService(
                client: client,
                localCache: createKeyValueStore(),
              ),
        ),
        ChangeNotifierProxyProvider<SupabaseClient, PortfolioService>(
          create: (context) => PortfolioService(
            client: context.read<SupabaseClient>(),
            localCache: createKeyValueStore(),
          ),
          update: (context, client, previous) =>
              previous ??
              PortfolioService(
                client: client,
                localCache: createKeyValueStore(),
              ),
        ),
        ChangeNotifierProxyProvider<SupabaseClient, StoryService>(
          create: (context) => StoryService(
            client: context.read<SupabaseClient>(),
            localCache: createKeyValueStore(),
          ),
          update: (context, client, previous) =>
              previous ??
              StoryService(
                client: client,
                localCache: createKeyValueStore(),
              ),
        ),
        ChangeNotifierProxyProvider<SupabaseClient, OpportunityService>(
          create: (context) => OpportunityService(
            client: context.read<SupabaseClient>(),
            localCache: createKeyValueStore(),
          ),
          update: (context, client, previous) =>
              previous ??
              OpportunityService(
                client: client,
                localCache: createKeyValueStore(),
              ),
        ),
        ChangeNotifierProxyProvider<SupabaseClient, MonetizationService>(
          create: (context) =>
              MonetizationService(client: context.read<SupabaseClient>()),
          update: (context, client, previous) =>
              previous ?? MonetizationService(client: client),
        ),
        ChangeNotifierProxyProvider<SupabaseClient, ProgressionService>(
          create: (context) =>
              ProgressionService(client: context.read<SupabaseClient>()),
          update: (context, client, previous) =>
              previous ?? ProgressionService(client: client),
        ),

        ProxyProvider<SupabaseClient, StudioService>(
          update: (context, client, previous) =>
              previous ?? StudioService(client: client),
        ),
        ProxyProvider<SupabaseClient, MissionComposerService>(
          update: (context, client, previous) =>
              previous ?? MissionComposerService(client: client),
        ),
      ],
      child: MaterialApp.router(
        title: 'SPOTLIGHT Connect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          primaryColor: const Color(0xFF39FF14),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF39FF14),
            secondary: Color(0xFFD4AF37),
            surface: Color(0xFF1A1A1A),
          ),
        ),
        themeMode: ThemeMode.dark,
        routerConfig: _router,
      ),
    );
  }
}
