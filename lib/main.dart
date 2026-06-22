import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
import 'package:spotlight_connect/services/monetization_service.dart';
import 'package:spotlight_connect/services/progression_service.dart';
import 'package:spotlight_connect/storage/key_value_store.dart';
import 'supabase/supabase_config.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  primaryColor: const Color(0xFF39FF14),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF39FF14),
    secondary: Color(0xFFD4AF37),
    surface: Color(0xFF1A1A1A),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
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

  @override
  void initState() {
    super.initState();
    _authProvider = SupabaseAuthProvider();
    _featureFlagProvider = FeatureFlagProvider(store: createKeyValueStore());
    _progressionFeaturePolicyProvider = ProgressionFeaturePolicyProvider(authProvider: _authProvider);
    Future.microtask(_featureFlagProvider.ensureInitialized);
    _router = AppRouter.createRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppAuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<FeatureFlagProvider>.value(value: _featureFlagProvider),
        ChangeNotifierProvider<ProgressionFeaturePolicyProvider>.value(value: _progressionFeaturePolicyProvider),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => MessageService()),
        ChangeNotifierProvider(create: (_) => PostService()),
        ChangeNotifierProvider(create: (_) => GroupService(store: createKeyValueStore())),
        ChangeNotifierProvider(create: (_) => PortfolioService(store: createKeyValueStore())),
        ChangeNotifierProvider(create: (_) => StoryService(store: createKeyValueStore())),
        Provider(create: (_) => StudioService()),
        Provider(create: (_) => MissionComposerService()),
        ChangeNotifierProvider(create: (_) => OpportunityService(createKeyValueStore())),  
        ChangeNotifierProvider(create: (_) => MonetizationService()),
        ChangeNotifierProvider(create: (_) => ProgressionService()),
      ],
      child: MaterialApp.router(
        title: 'SPOTLIGHT Connect',
        debugShowCheckedModeBanner: false,
        theme: darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: _router,
      ),
    );
  }
}
