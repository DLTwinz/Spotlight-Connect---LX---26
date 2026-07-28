import 'package:spotlight_connect/models/user_model.dart';
import 'package:spotlight_connect/nav.dart';

class RoleCapabilities {
  final UserModel user;

  RoleCapabilities(this.user);

  bool get hasKnownActiveRole => user.parsedActiveRole != UserRole.unknown;
  bool get hasAudienceApproval => user.approvedRoles.contains('audience');
  bool get hasTalentApproval => user.approvedRoles.contains('talent');
  bool get hasBusinessApproval => user.approvedRoles.contains('business');

  bool get hasValidProfile =>
      user.userId.isNotEmpty &&
      user.approvedRoles.isNotEmpty &&
      hasAudienceApproval &&
      hasKnownActiveRole;

  bool get isBlockedState =>
      user.isRejected || user.isRestricted || user.isSuspended;

  bool get activeRoleApproved {
    switch (user.parsedActiveRole) {
      case UserRole.talent:
        return hasTalentApproval;
      case UserRole.business:
        return hasBusinessApproval;
      case UserRole.admin:
        return user.isAdmin;
      case UserRole.audience:
        return hasAudienceApproval;
      case UserRole.unknown:
        return false;
    }
  }

  String get defaultDashboardRoute {
    if (user.isAdmin) {
      switch (user.parsedActiveRole) {
        case UserRole.talent:
          return AppRoutes.talent;
        case UserRole.business:
          return AppRoutes.business;
        case UserRole.audience:
          return AppRoutes.audience;
        case UserRole.admin:
        case UserRole.unknown:
          return AppRoutes.admin;
      }
    }

    switch (user.parsedActiveRole) {
      case UserRole.talent:
        return hasTalentApproval ? AppRoutes.talent : AppRoutes.audience;
      case UserRole.business:
        return hasBusinessApproval ? AppRoutes.business : AppRoutes.audience;
      case UserRole.audience:
      case UserRole.admin:
      case UserRole.unknown:
        return AppRoutes.audience;
    }
  }

  bool canAccessRoute(String location) {
    switch (location) {
      case AppRoutes.admin:
      case AppRoutes.adminMissions:
      case AppRoutes.adminCampaigns:
        return user.isAdmin;
      case AppRoutes.talent:
        return hasTalentApproval;
      case AppRoutes.business:
        return hasBusinessApproval;
      case AppRoutes.audience:
        return hasAudienceApproval;
      default:
        return true;
    }
  }
}
