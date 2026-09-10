class AppRoutes {
  static const String root = '/';
  static const String welcome = '/welcome';
  static const String earlyAccess = '/early-access';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String authCallback = '/auth/callback';
  static const String resetPassword = '/reset-password';
  static const String waitingApproval = '/waiting-approval';
  static const String accessDenied = '/access';
  static const String permissionDenied = '/permission-denied';
  static const String audience = '/audience';
  static const String talent = '/talent';
  static const String business = '/business';
  static const String admin = '/admin';
  static const String audienceDashboard = '/audience/dashboard';
  static const String talentDashboard = '/talent/dashboard';
  static const String businessDashboard = '/business/dashboard';
  static const String studio = '/studio';
  static const String studioAnalytics = '/studio/analytics';
  static const String livekit = '/livekit';
  static const String missions = '/missions';
  static const String rewards = '/rewards';
  static const String campaigns = '/campaigns';
  static const String progress = '/progress';
  static const String adminMissions = '/admin/missions';
  static const String adminCampaigns = '/admin/campaigns';
  static const String featureDisabled = '/feature-disabled';
  static const String qa = '/__qa';

  static bool isStudioLocation(String location) {
    return location == studio || location.startsWith('$studio/');
  }

  static bool isLegacyTalentLocation(String location) {
    return location == talent ||
        location == talentDashboard ||
        location.startsWith('$talent/');
  }
}
