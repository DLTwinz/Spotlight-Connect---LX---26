import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

// Your existing project imports (Keep these below the Flutter ones)
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/providers/feature_flag_provider.dart';
import 'package:spotlight_connect/providers/progression_feature_policy_provider.dart';
import 'package:spotlight_connect/models/user_model.dart';
import 'package:spotlight_connect/core/access/role_capabilities.dart';
import 'package:spotlight_connect/core/routing/app_routes.dart';
import 'package:spotlight_connect/core/routing/studio_route_contract.dart';
import 'package:spotlight_connect/models/studio_session_model.dart';
// ... Add any other necessary project-specific imports here ...
import 'package:provider/provider.dart';

// --- YOUR LOCAL PROJECT IMPORTS BELOW THIS LINE ---
// Add any other specific files that were showing "Target of URI doesn't exist" here

// Your existing project imports (Keep these below the Flutter ones)

import 'pages/auth/auth_callback_page.dart';
import 'pages/auth/early_access_gate_page.dart';
import 'pages/auth/landing_auth_page.dart';
import 'pages/landing/spotlight_marketing_landing_page.dart';
import 'pages/auth/onboarding_page.dart';
import 'pages/auth/permission_denied_page.dart';
import 'pages/auth/reset_password_page.dart';
import 'pages/auth/waiting_approval_page.dart';
import 'pages/dashboards/admin_dashboard.dart';
import 'pages/dashboards/audience_dashboard.dart';
import 'pages/dashboards/talent_business_dashboards.dart';
import 'pages/dashboards/creator_studio_shell.dart';
import 'pages/dashboards/creator_analytics_economics_page.dart';
import 'pages/dashboards/creator_identity_control_page.dart';
import 'pages/dashboards/creator_community_page.dart';
import 'pages/debug/qa_harness_page.dart';
import 'pages/progression/admin/admin_campaigns_page.dart';
import 'pages/progression/admin/admin_missions_page.dart';
import 'pages/progression/campaign_detail_page.dart';
import 'pages/progression/campaigns_page.dart';
import 'pages/progression/mission_detail_page.dart';
import 'pages/progression/missions_page.dart';
import 'pages/progression/progress_page.dart';
import 'pages/progression/rewards_page.dart';
import 'pages/shared/feature_disabled_page.dart';
import 'pages/studio/livekit_room_page.dart';

// ... Add any other necessary project-specific imports here ...

class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static void validate() {
    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      throw Exception(
        'Missing required environment variables: SUPABASE_URL or SUPABASE_ANON_KEY',
      );
    }
  }
}

class AppRouter {
  static GoRouter createRouter(AppAuthProvider authProvider) {
    final initial = _computeInitialLocation(fallback: fallback);

    // TEMPORARY OVERRIDE FOR TESTING: Force admin dashboard to test new analytics UI
    // Remove this line once you're satisfied with the admin dashboard design
    final finalInitialLocation = initial; // Set to 'initial' to revert

    return GoRouter(
      initialLocation: finalInitialLocation,
      refreshListenable: authProvider,
      errorPageBuilder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          try {
            final baseUri = Uri.base;
            final fragRaw = baseUri.fragment;
            final qp = <String, String>{
              ...state.uri.queryParameters,
              ...baseUri.queryParameters,
            };
            final hasSupabaseFragmentTokens =
                fragRaw.contains('access_token=') ||
                fragRaw.contains('refresh_token=') ||
                fragRaw.contains('type=recovery');
            final hasSupabaseError =
                fragRaw.contains('error=') ||
                qp.containsKey('error') ||
                qp.containsKey('error_code') ||
                qp.containsKey('error_description');
            final hasSupabasePkceCode = (qp['code'] ?? '').isNotEmpty;
            final hasSupabaseRecoveryType =
                (qp['type'] ?? '').toLowerCase() == 'recovery';
            final hasSupabaseAuthParams =
                hasSupabaseFragmentTokens ||
                hasSupabasePkceCode ||
                hasSupabaseRecoveryType ||
                hasSupabaseError;
            if (hasSupabaseAuthParams) {
              context.go(
                Uri(
                  path: AppRoutes.authCallback,
                  queryParameters: qp,
                  fragment: fragRaw,
                ).toString(),
              );
              return;
            }
          } catch (e) {
            debugPrint('AppRouter: errorPageBuilder recovery failed: $e');
          }
          context.go(AppRoutes.root);
        });
        return _fadeSlidePage(
          const Scaffold(body: Center(child: CircularProgressIndicator())),
          state,
        );
      },
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final user = authProvider.currentUser;
        final isAuthLoading = authProvider.isLoading;
        final location = state.uri.path;
        final isAuthRoute = location == AppRoutes.login;
        final isWelcomeRoute = location == AppRoutes.welcome;
        final isAuthCallbackRoute = location == AppRoutes.authCallback;
        final isEarlyAccessRoute = location == AppRoutes.earlyAccess;
        final isOnboardingRoute = location == AppRoutes.onboarding;
        final isResetPasswordRoute = location == AppRoutes.resetPassword;
        final isAccessDeniedRoute =
            location == AppRoutes.accessDenied ||
            location == AppRoutes.permissionDenied;
        final isWaitingApprovalRoute = location == AppRoutes.waitingApproval;
        final isLiveKitRoute = location == AppRoutes.livekit;
        final isFeatureDisabledRoute = location == AppRoutes.featureDisabled;

        bool canAccessQaHarness() {
          if (kReleaseMode) return false;
          if (authProvider.isAdmin) return true;
          try {
            final flags = context.read<FeatureFlagProvider>();
            return flags.isEnabled(AppFeature.qaHarness);
          } catch (_) {
            return false;
          }
        }

        bool liveKitConfigured() {
          try {
            final flags = context.read<FeatureFlagProvider>();
            if (!flags.isEnabled(AppFeature.streams)) return false;
          } catch (_) {}
          const liveKitUrl = String.fromEnvironment('SPOTLIGHT_LIVEKIT_URL');
          return liveKitUrl.trim().isNotEmpty;
        }

        void logRedirect(String target) {
          if (!kDebugMode) return;
          debugPrint(
            'Router redirect: $location -> $target (loggedIn=$isLoggedIn loading=$isAuthLoading onboarding=${user?.onboardingComplete} role=${user?.activeRole} launch=$launchEnabled)',
          );
        }

        final baseUri = Uri.base;
        final fragRaw = baseUri.fragment.isNotEmpty
            ? baseUri.fragment
            : state.uri.fragment;
        final qp = <String, String>{
          ...state.uri.queryParameters,
          ...baseUri.queryParameters,
        };
        final hasSupabaseFragmentTokens =
            fragRaw.contains('access_token=') ||
            fragRaw.contains('refresh_token=') ||
            fragRaw.contains('type=recovery');
        final hasSupabaseError =
            fragRaw.contains('error=') ||
            qp.containsKey('error') ||
            qp.containsKey('error_code') ||
            qp.containsKey('error_description');
        final hasSupabasePkceCode = (qp['code'] ?? '').isNotEmpty;
        final hasSupabaseRecoveryType =
            (qp['type'] ?? '').toLowerCase() == 'recovery';
        final hasSupabaseAuthParams =
            hasSupabaseFragmentTokens ||
            hasSupabasePkceCode ||
            hasSupabaseRecoveryType ||
            hasSupabaseError;

        if (hasSupabaseAuthParams &&
            !isAuthCallbackRoute &&
            !isResetPasswordRoute) {
          final target = Uri(
            path: AppRoutes.authCallback,
            queryParameters: qp,
            fragment: fragRaw,
          ).toString();
          logRedirect(target);
          return target;
        }

        if (isAuthLoading) return null;
        if (isAuthCallbackRoute) return null;
        if (isResetPasswordRoute) return null;

        String accessDenied({required String missing, String? requiredRole}) {
          final qp = <String, String>{'missing': missing, 'from': location};
          if (requiredRole != null) qp['role'] = requiredRole;
          return Uri(
            path: AppRoutes.permissionDenied,
            queryParameters: qp,
          ).toString();
        }

        String featureDisabled({
          required String featureKey,
          required String title,
          required String message,
        }) {
          return Uri(
            path: AppRoutes.featureDisabled,
            queryParameters: <String, String>{
              'feature': featureKey,
              'title': title,
              'message': message,
              'from': location,
            },
          ).toString();
        }

        if (location == AppRoutes.qa) {
          if (kReleaseMode) {
            logRedirect(AppRoutes.login);
            return AppRoutes.login;
          }
          if (canAccessQaHarness()) return null;
          if (isLoggedIn) {
            final target = Uri(
              path: AppRoutes.accessDenied,
              queryParameters: <String, String>{
                'missing': 'qa',
                'from': location,
                'role': 'admin',
              },
            ).toString();
            logRedirect(target);
            return target;
          }
          logRedirect(AppRoutes.login);
          return AppRoutes.login;
        }

        if (isLoggedIn && user == null) {
          if (isAuthRoute) return null;
          if (location == AppRoutes.root) return null;
          logRedirect(AppRoutes.root);
          return AppRoutes.root;
        }

        if (!isLoggedIn) {
          if (!launchEnabled) {
            if (isEarlyAccessRoute) return null;
            if (isAuthRoute) return null;
            logRedirect(AppRoutes.earlyAccess);
            return AppRoutes.earlyAccess;
          }
          if (isEarlyAccessRoute) {
            logRedirect(AppRoutes.welcome);
            return AppRoutes.welcome;
          }
          if (isWelcomeRoute ||
              isAuthRoute ||
              isResetPasswordRoute ||
              isAccessDeniedRoute) {
            return null;
          }
          logRedirect(AppRoutes.welcome);
          return AppRoutes.welcome;
        }

        final currentUser = user!;
        final caps = RoleCapabilities(currentUser);
        if (currentUser.activeRole == "admin") {
          if (location.startsWith("/admin")) return null;
          logRedirect(AppRoutes.admin);
          return AppRoutes.admin;
        }
        if (!currentUser.onboardingComplete) {
          if (currentUser.activeRole == "admin") {
            if (location.startsWith("/admin")) return null;
            logRedirect(AppRoutes.admin);
            return AppRoutes.admin;
          }
          if (isOnboardingRoute) return null;
          if (currentUser.activeRole == "admin") {
            if (location.startsWith("/admin")) return null;
            logRedirect(AppRoutes.admin);
            return AppRoutes.admin;
          }
          final role = state.uri.queryParameters['role'];
          final onboardingTarget = (role != null && role.isNotEmpty)
              ? Uri(
                  path: AppRoutes.onboarding,
                  queryParameters: {'role': role},
                ).toString()
              : AppRoutes.onboarding;
          logRedirect(onboardingTarget);
          return onboardingTarget;
        }

        if (currentUser.isPendingReview) {
          if (isWaitingApprovalRoute || isAccessDeniedRoute) return null;
          if (location == AppRoutes.audience ||
              location.startsWith('${AppRoutes.audience}/')) {
            return null;
          }
          if (location == AppRoutes.talent ||
              location == AppRoutes.business ||
              AppRoutes.isStudioLocation(location) ||
              location.startsWith('/talent') ||
              location.startsWith('/business') ||
              location.startsWith('/admin')) {
            logRedirect(AppRoutes.waitingApproval);
            return AppRoutes.waitingApproval;
          }
          if (location == AppRoutes.root || location == '/') {
            logRedirect(AppRoutes.audience);
            return AppRoutes.audience;
          }
          return null;
        }
        if (currentUser.isRejected ||
            currentUser.isRestricted ||
            currentUser.isSuspended) {
          if (isAccessDeniedRoute) return null;
          final target = accessDenied(
            missing: currentUser.isRejected
                ? 'rejected'
                : (currentUser.isSuspended ? 'suspended' : 'restricted'),
          );
          logRedirect(target);
          return target;
        }

        if (isLiveKitRoute && !liveKitConfigured()) {
          if (isAccessDeniedRoute) return null;
          final target = accessDenied(missing: 'livekit');
          logRedirect(target);
          return target;
        }

        if (!caps.hasValidProfile) {
          if (isAccessDeniedRoute) return null;
          final target = accessDenied(missing: 'profile');
          logRedirect(target);
          return target;
        }

        if (currentUser.parsedActiveRole == UserRole.talent &&
            !caps.activeRoleApproved) {
          if (isAccessDeniedRoute) return null;
          final target = accessDenied(
            missing: 'approval',
            requiredRole: 'talent',
          );
          logRedirect(target);
          return target;
        }
        if (currentUser.parsedActiveRole == UserRole.business &&
            !caps.activeRoleApproved) {
          if (isAccessDeniedRoute) return null;
          final target = accessDenied(
            missing: 'approval',
            requiredRole: 'business',
          );
          logRedirect(target);
          return target;
        }

        String defaultDashboardRouteFor(UserModel u) {
          return RoleCapabilities(u).defaultDashboardRoute;
        }

        if (isEarlyAccessRoute || isWelcomeRoute) {
          final target = defaultDashboardRouteFor(currentUser);
          logRedirect(target);
          return target;
        }

        if (isAuthRoute) {
          if (currentUser.onboardingComplete) {
            final target = defaultDashboardRouteFor(currentUser);
            if (target != AppRoutes.login) {
              logRedirect(target);
              return target;
            }
          }
          return null;
        }

        if (isOnboardingRoute) {
          final target = defaultDashboardRouteFor(currentUser);
          logRedirect(target);
          return target;
        }

        if (location == AppRoutes.root) {
          final target = defaultDashboardRouteFor(currentUser);
          logRedirect(target);
          return target;
        }

        final roleDashPaths = <String>{
          AppRoutes.audience,
          AppRoutes.talent,
          AppRoutes.studio,
          AppRoutes.studioAnalytics,
          AppRoutes.studioIdentity,
          AppRoutes.studioCommunity,
          AppRoutes.business,
          AppRoutes.admin,
        };
        if (roleDashPaths.contains(location)) {
          if (caps.canAccessRoute(location)) {
            if (location == AppRoutes.audience &&
                (caps.hasTalentApproval || caps.hasBusinessApproval)) {
              final target = defaultDashboardRouteFor(currentUser);
              if (target != location) {
                logRedirect(target);
                return target;
              }
            }
            return null;
          }
          final target = defaultDashboardRouteFor(currentUser);
          if (target != location) {
            logRedirect(target);
            return target;
          }
        }

        final knownPaths = <String>{
          AppRoutes.root,
          AppRoutes.welcome,
          AppRoutes.earlyAccess,
          AppRoutes.login,
          AppRoutes.onboarding,
          AppRoutes.authCallback,
          AppRoutes.resetPassword,
          AppRoutes.waitingApproval,
          AppRoutes.accessDenied,
          AppRoutes.permissionDenied,
          AppRoutes.audience,
          AppRoutes.talent,
          AppRoutes.studio,
          AppRoutes.studioAnalytics,
          AppRoutes.studioIdentity,
          AppRoutes.studioCommunity,
          AppRoutes.business,
          AppRoutes.admin,
          AppRoutes.audienceDashboard,
          AppRoutes.talentDashboard,
          AppRoutes.businessDashboard,
          AppRoutes.livekit,
          AppRoutes.missions,
          AppRoutes.rewards,
          AppRoutes.campaigns,
          AppRoutes.progress,
          AppRoutes.adminMissions,
          AppRoutes.adminCampaigns,
          AppRoutes.featureDisabled,
          if (!kReleaseMode) AppRoutes.qa,
        };
        final knownPrefixes = <String>{
          '${AppRoutes.missions}/',
          '${AppRoutes.campaigns}/',
          '${AppRoutes.studio}/',
        };
        final isKnownByPrefix = knownPrefixes.any(
          (p) => location.startsWith(p),
        );
        if (!knownPaths.contains(location) && !isKnownByPrefix) {
          final target = defaultDashboardRouteFor(currentUser);
          logRedirect(target);
          return target;
        }
        if ((location == AppRoutes.talent ||
                AppRoutes.isStudioLocation(location) ||
                AppRoutes.isLegacyTalentLocation(location)) &&
            !caps.canAccessRoute(location)) {
          final target = accessDenied(missing: 'role', requiredRole: 'talent');
          logRedirect(target);
          return target;
        }
        if (AppRoutes.isLegacyTalentLocation(location)) {
          final target = StudioRouteContract.talentCompatibilityTarget(
            state.uri.queryParameters,
          );
          logRedirect(target);
          return target;
        }
        if (location == AppRoutes.studio) {
          logRedirect(AppRoutes.studioAnalytics);
          return AppRoutes.studioAnalytics;
        }
        if (StudioRouteContract.isUnknownStudioChild(location)) {
          final target = accessDenied(missing: 'route', requiredRole: 'talent');
          logRedirect(target);
          return target;
        }
        if (location == AppRoutes.business && !caps.canAccessRoute(location)) {
          final target = accessDenied(
            missing: 'role',
            requiredRole: 'business',
          );
          logRedirect(target);
          return target;
        }
        if (location == AppRoutes.admin && !caps.canAccessRoute(location)) {
          final target = accessDenied(missing: 'role', requiredRole: 'admin');
          logRedirect(target);
          return target;
        }

        final isAdminTooling =
            location == AppRoutes.adminMissions ||
            location == AppRoutes.adminCampaigns;
        if (isAdminTooling && !caps.canAccessRoute(location)) {
          final target = accessDenied(missing: 'role', requiredRole: 'admin');
          logRedirect(target);
          return target;
        }

        final isProgressionRoute =
            location == AppRoutes.missions ||
            location.startsWith('${AppRoutes.missions}/') ||
            location == AppRoutes.rewards ||
            location == AppRoutes.campaigns ||
            location.startsWith('${AppRoutes.campaigns}/') ||
            location == AppRoutes.progress;
        if (isProgressionRoute && !isFeatureDisabledRoute) {
          try {
            final policyProvider = context
                .read<ProgressionFeaturePolicyProvider>();
            if (!policyProvider.isLoading) {
              final policy = policyProvider.policy;
              final roleKey = policyProvider.roleKey;

              bool blocked = false;
              String feature = 'progression';
              String title = 'Feature unavailable';
              String message = 'This feature is currently unavailable.';

              if (!policy.progressionEnabled) {
                blocked = true;
                title = 'Progression is disabled';
                message = 'Progression is currently turned off.';
              } else if (location == AppRoutes.missions ||
                  location.startsWith('${AppRoutes.missions}/')) {
                if (!policy.missionsEnabled ||
                    !policy.roleMissionsEnabled(roleKey)) {
                  blocked = true;
                  feature = 'missions';
                  title = 'Missions are disabled';
                  message = 'Missions are currently unavailable for your role.';
                }
              } else if (location == AppRoutes.campaigns ||
                  location.startsWith('${AppRoutes.campaigns}/')) {
                if (!policy.campaignsEnabled) {
                  blocked = true;
                  feature = 'campaigns';
                  title = 'Campaigns are disabled';
                  message = 'Campaigns are currently unavailable.';
                }
              } else if (location == AppRoutes.rewards) {
                if (!policy.redemptionsEnabled) {
                  blocked = true;
                  feature = 'rewards';
                  title = 'Rewards are disabled';
                  message = 'Rewards are currently unavailable.';
                }
              } else if (location == AppRoutes.progress) {
                if (!policy.progressionEnabled) {
                  blocked = true;
                  feature = 'progress';
                  title = 'Progress is disabled';
                  message = 'Progress tracking is currently unavailable.';
                }
              }

              if (blocked) {
                final target = featureDisabled(
                  featureKey: feature,
                  title: title,
                  message: message,
                );
                logRedirect(target);
                return target;
              }
            }
          } catch (e) {
            debugPrint('AppRouter: progression route guard failed open: $e');
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.root,
          builder: (context, state) =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
        GoRoute(
          path: AppRoutes.authCallback,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const AuthCallbackPage(), state),
        ),
        GoRoute(
          path: AppRoutes.earlyAccess,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const EarlyAccessGatePage(), state),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const SpotlightMarketingLandingPage(), state),
        ),
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (context, state) {
            final email = state.uri.queryParameters['email'];
            final ea = state.uri.queryParameters['ea'] == '1';
            return _fadeSlidePage(
              LandingAuthPage(initialEmail: email, earlyAccessFlow: ea),
              state,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const OnboardingPage(), state),
        ),
        GoRoute(
          path: AppRoutes.waitingApproval,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const WaitingApprovalPage(), state),
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          pageBuilder: (context, state) {
            final email = state.uri.queryParameters['email'];
            final step = state.uri.queryParameters['step'];
            return _fadeSlidePage(
              ResetPasswordPage(initialEmail: email, initialStep: step),
              state,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.accessDenied,
          pageBuilder: (context, state) =>
              _fadeSlidePage(PermissionDeniedPage(uri: state.uri), state),
        ),
        GoRoute(
          path: AppRoutes.permissionDenied,
          pageBuilder: (context, state) =>
              _fadeSlidePage(PermissionDeniedPage(uri: state.uri), state),
        ),
        GoRoute(
          path: AppRoutes.audience,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const AudienceDashboard(), state),
        ),
        GoRoute(
          path: AppRoutes.audienceDashboard,
          redirect: (context, state) => AppRoutes.audience,
        ),
        GoRoute(
          path: AppRoutes.studio,
          redirect: (context, state) {
            if (state.uri.path == AppRoutes.studio) {
              return AppRoutes.studioAnalytics;
            }
            return null;
          },
        ),
        GoRoute(
          path: AppRoutes.studioAnalytics,
          pageBuilder: (context, state) => _fadeSlidePage(
            const CreatorStudioShell(child: CreatorAnalyticsEconomicsPage()),
            state,
          ),
        ),
        GoRoute(
          path: AppRoutes.studioIdentity,
          pageBuilder: (context, state) => _fadeSlidePage(
            const CreatorStudioShell(child: CreatorIdentityControlPage()),
            state,
          ),
        ),
        GoRoute(
          path: AppRoutes.studioCommunity,
          pageBuilder: (context, state) => _fadeSlidePage(
            const CreatorStudioShell(child: CreatorCommunityPage()),
            state,
          ),
        ),
        GoRoute(
          path: AppRoutes.talent,
          redirect: (context, state) => AppRoutes.studio,
        ),
        GoRoute(
          path: AppRoutes.talentDashboard,
          redirect: (context, state) => AppRoutes.studio,
        ),
        GoRoute(
          path: AppRoutes.business,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const BusinessDashboard(), state),
        ),
        GoRoute(
          path: AppRoutes.businessDashboard,
          redirect: (context, state) => AppRoutes.business,
        ),
        GoRoute(
          path: AppRoutes.admin,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const AdminDashboard(), state),
        ),
        GoRoute(
          path: AppRoutes.featureDisabled,
          pageBuilder: (context, state) {
            final title =
                (state.uri.queryParameters['title'] ?? 'Feature unavailable')
                    .trim();
            final message =
                (state.uri.queryParameters['message'] ??
                        'This feature is currently unavailable.')
                    .trim();
            final feature = (state.uri.queryParameters['feature'] ?? '').trim();
            final icon = switch (feature) {
              'missions' => Icons.task_alt,
              'campaigns' => Icons.campaign,
              'rewards' => Icons.card_giftcard,
              'progress' => Icons.insights,
              _ => Icons.lock_outline,
            };
            return _fadeSlidePage(
              FeatureDisabledPage(title: title, message: message, icon: icon),
              state,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.missions,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const MissionsPage(), state),
          routes: [
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return _fadeSlidePage(MissionDetailPage(missionId: id), state);
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.rewards,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const RewardsPage(), state),
        ),
        GoRoute(
          path: AppRoutes.campaigns,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const CampaignsPage(), state),
          routes: [
            GoRoute(
              path: ':campaignId',
              pageBuilder: (context, state) {
                final id = (state.pathParameters['campaignId'] ?? '').trim();
                return _fadeSlidePage(
                  CampaignDetailPage(campaignId: id),
                  state,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.progress,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const ProgressPage(), state),
        ),
        GoRoute(
          path: AppRoutes.adminMissions,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const AdminMissionsPage(), state),
        ),
        GoRoute(
          path: AppRoutes.adminCampaigns,
          pageBuilder: (context, state) =>
              _fadeSlidePage(const AdminCampaignsPage(), state),
        ),
        GoRoute(
          path: AppRoutes.livekit,
          pageBuilder: (context, state) {
            final extra = state.extra;
            if (extra is Map) {
              final session = extra['session'];
              final hostMode = extra['hostMode'] == true;
              if (session is StudioSessionModel) {
                return _fadeSlidePage(
                  LiveKitRoomPage(session: session, hostMode: hostMode),
                  state,
                );
              }
            }
            return _fadeSlidePage(
              const Scaffold(
                body: Center(child: Text('Missing LiveKit session.')),
              ),
              state,
            );
          },
        ),
        if (!kReleaseMode)
          GoRoute(
            path: AppRoutes.qa,
            pageBuilder: (context, state) =>
                _fadeSlidePage(const QAHarnessPage(), state),
          ),
        GoRoute(
          path: '/:opaque',
          redirect: (context, state) {
            try {
              final baseUri = Uri.base;
              final fragRaw = baseUri.fragment.isNotEmpty
                  ? baseUri.fragment
                  : state.uri.fragment;
              final qp = <String, String>{
                ...state.uri.queryParameters,
                ...baseUri.queryParameters,
              };
              final hasSupabaseFragmentTokens =
                  fragRaw.contains('access_token=') ||
                  fragRaw.contains('refresh_token=') ||
                  fragRaw.contains('type=recovery');
              final hasSupabaseError =
                  fragRaw.contains('error=') ||
                  qp.containsKey('error') ||
                  qp.containsKey('error_code') ||
                  qp.containsKey('error_description');
              final hasSupabasePkceCode = (qp['code'] ?? '').isNotEmpty;
              final hasSupabaseRecoveryType =
                  (qp['type'] ?? '').toLowerCase() == 'recovery';
              final hasSupabaseAuthParams =
                  hasSupabaseFragmentTokens ||
                  hasSupabasePkceCode ||
                  hasSupabaseRecoveryType ||
                  hasSupabaseError;
              if (hasSupabaseAuthParams) {
                return Uri(
                  path: AppRoutes.authCallback,
                  queryParameters: qp,
                  fragment: fragRaw,
                ).toString();
              }
            } catch (e) {
              debugPrint(
                'AppRouter: opaque-path redirect failed to preserve auth params: $e',
              );
            }
            return AppRoutes.root;
          },
        ),
        GoRoute(
          path: '/:opaque/:rest(.*)',
          redirect: (context, state) {
            try {
              final baseUri = Uri.base;
              final fragRaw = baseUri.fragment.isNotEmpty
                  ? baseUri.fragment
                  : state.uri.fragment;
              final qp = <String, String>{
                ...state.uri.queryParameters,
                ...baseUri.queryParameters,
              };
              final hasSupabaseFragmentTokens =
                  fragRaw.contains('access_token=') ||
                  fragRaw.contains('refresh_token=') ||
                  fragRaw.contains('type=recovery');
              final hasSupabaseError =
                  fragRaw.contains('error=') ||
                  qp.containsKey('error') ||
                  qp.containsKey('error_code') ||
                  qp.containsKey('error_description');
              final hasSupabasePkceCode = (qp['code'] ?? '').isNotEmpty;
              final hasSupabaseRecoveryType =
                  (qp['type'] ?? '').toLowerCase() == 'recovery';
              final hasSupabaseAuthParams =
                  hasSupabaseFragmentTokens ||
                  hasSupabasePkceCode ||
                  hasSupabaseRecoveryType ||
                  hasSupabaseError;
              if (hasSupabaseAuthParams) {
                return Uri(
                  path: AppRoutes.authCallback,
                  queryParameters: qp,
                  fragment: fragRaw,
                ).toString();
              }
            } catch (e) {
              debugPrint(
                'AppRouter: deep-opaque redirect failed to preserve auth params: $e',
              );
            }
            return AppRoutes.root;
          },
        ),
      ],
    );
  }

  static String _computeInitialLocation({required String fallback}) {
    try {
      final uri = Uri.base;
      final path = uri.path;
      if (path.isNotEmpty && path != '/' && path.startsWith('/')) {
        return _pathWithQuery(path: path, queryParameters: uri.queryParameters);
      }
      final fragRaw = uri.fragment;
      final hasSupabaseFragmentTokens =
          fragRaw.contains('access_token=') ||
          fragRaw.contains('refresh_token=') ||
          fragRaw.contains('type=recovery');
      final hasSupabaseFragmentError = fragRaw.contains('error=');
      final hasSupabaseQueryCode =
          (uri.queryParameters['code'] ?? '').isNotEmpty;
      final hasSupabaseQueryRecoveryType =
          (uri.queryParameters['type'] ?? '').toLowerCase() == 'recovery';
      if ((path.isEmpty || path == '/') &&
          (hasSupabaseFragmentTokens ||
              hasSupabaseFragmentError ||
              hasSupabaseQueryCode ||
              hasSupabaseQueryRecoveryType)) {
        debugPrint(
          'AppRouter: detected Supabase email-link params at root; booting to ${AppRoutes.authCallback}',
        );
        return AppRoutes.authCallback;
      }
      final frag = uri.fragment;
      if (frag.startsWith('/')) {
        final parts = frag.split('?');
        final routeOnly = parts.first;
        if (routeOnly.isEmpty) return fallback;
        if (parts.length == 1) return routeOnly;
        return '$routeOnly?${parts.sublist(1).join('?')}';
      }
    } catch (e) {
      debugPrint(
        'AppRouter: failed to compute initialLocation from Uri.base: $e',
      );
    }
    return fallback;
  }

  static String _pathWithQuery({
    required String path,
    required Map<String, String> queryParameters,
  }) {
    if (queryParameters.isEmpty) return path;
    final query = Uri(queryParameters: queryParameters).query;
    if (query.isEmpty) return path;
    return '$path?$query';
  }

  static Page<void> _fadeSlidePage(Widget child, GoRouterState state) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }
}

final launchEnabled = true;
const fallback = "/";
