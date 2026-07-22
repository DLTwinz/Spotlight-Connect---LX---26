enum UserRole {
  audience,
  talent,
  business,
  admin,
  unknown,
}

const Object _unset = Object();

enum UserAccessState {
  loggedOut,
  registeredUnonboarded,
  onboardingInProgress,
  waitlistPending,
  rolePendingApproval,
  approvedActive,
  restricted,
  rejected,
  suspended,
  unknown,
}

class UserModel {
  final String userId;
  final String? email;
  final String displayName;
  final String username;
  final String? profilePhoto;
  final String? coverPhoto;
  final String baseRole;
  final List<String> approvedRoles;
  final String activeRole;
  final bool onboardingComplete;
  final String applicationStatusSummary;
  final bool isAdminFlag;
  final bool adminRoleEditEnabled;

  UserModel({
    required this.userId,
    this.email,
    required this.displayName,
    required this.username,
    this.profilePhoto,
    this.coverPhoto,
    required this.baseRole,
    required this.approvedRoles,
    required this.activeRole,
    required this.onboardingComplete,
    required this.applicationStatusSummary,
    required this.isAdminFlag,
    required this.adminRoleEditEnabled,
  });

  UserModel copyWith({
    String? userId,
    Object? email = _unset,
    String? displayName,
    String? username,
    String? profilePhoto,
    String? coverPhoto,
    String? baseRole,
    List<String>? approvedRoles,
    String? activeRole,
    bool? onboardingComplete,
    String? applicationStatusSummary,
    Object? isAdminFlag = _unset,
    Object? adminRoleEditEnabled = _unset,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: identical(email, _unset) ? this.email : email as String?,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      baseRole: baseRole ?? this.baseRole,
      approvedRoles: approvedRoles ?? this.approvedRoles,
      activeRole: activeRole ?? this.activeRole,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      applicationStatusSummary:
          applicationStatusSummary ?? this.applicationStatusSummary,
      isAdminFlag: identical(isAdminFlag, _unset)
          ? this.isAdminFlag
          : isAdminFlag as bool,
      adminRoleEditEnabled: identical(adminRoleEditEnabled, _unset)
          ? this.adminRoleEditEnabled
          : adminRoleEditEnabled as bool,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: (json['userId'] ?? json['user_id'] ?? json['id'] ?? '').toString(),
      email: json['email']?.toString(),
      displayName: (json['displayName'] ?? json['display_name'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      profilePhoto: json['profilePhoto'] ?? json['profile_photo'],
      coverPhoto: json['coverPhoto'] ?? json['cover_photo'],
      baseRole: (json['baseRole'] ?? json['base_role'] ?? 'audience').toString(),
      approvedRoles: json['approvedRoles'] != null
          ? List<String>.from(json['approvedRoles'])
          : json['approved_roles'] != null
              ? List<String>.from(json['approved_roles'])
              : ['audience'],
      activeRole: (json['activeRole'] ?? json['active_role'] ?? 'audience')
          .toString(),
      onboardingComplete:
          (json['onboardingComplete'] ?? json['onboarding_complete'] ?? false) ==
              true,
      applicationStatusSummary:
          (json['applicationStatusSummary'] ??
                  json['application_status_summary'] ??
                  'none')
              .toString(),
      isAdminFlag: (json['isAdmin'] ?? json['is_admin'] ?? false) == true,
      adminRoleEditEnabled:
          (json['adminRoleEditEnabled'] ??
                  json['admin_role_edit_enabled'] ??
                  false) ==
              true,
    );
  }

  UserRole get parsedBaseRole => _parseRole(baseRole);

  UserRole get parsedActiveRole => _parseRole(activeRole);

  List<UserRole> get parsedApprovedRoles => approvedRoles.map(_parseRole).toList();

  bool get isAudience => parsedActiveRole == UserRole.audience;

  bool get isTalent =>
      parsedActiveRole == UserRole.talent ||
      parsedApprovedRoles.contains(UserRole.talent);

  bool get isBusiness =>
      parsedActiveRole == UserRole.business ||
      parsedApprovedRoles.contains(UserRole.business);

  bool get isAdmin =>
      isAdminFlag ||
      parsedActiveRole == UserRole.admin ||
      parsedApprovedRoles.contains(UserRole.admin);

  bool get hasApprovedRole =>
      parsedApprovedRoles.isNotEmpty ||
      applicationStatusSummary.trim().toLowerCase() == 'approved';

  bool get isOnboardingComplete => onboardingComplete;

  bool get isPendingReview {
    final status = applicationStatusSummary.trim().toLowerCase();
    return status == 'pending' ||
        status == 'pending_review' ||
        status == 'submitted';
  }

  bool get isRejected {
    final status = applicationStatusSummary.trim().toLowerCase();
    return status == 'rejected';
  }

  bool get isRestricted {
    final status = applicationStatusSummary.trim().toLowerCase();
    return status == 'restricted';
  }

  bool get isSuspended {
    final status = applicationStatusSummary.trim().toLowerCase();
    return status == 'suspended';
  }

  UserAccessState get accessState {
    if (isSuspended) return UserAccessState.suspended;
    if (isRestricted) return UserAccessState.restricted;
    if (isRejected) return UserAccessState.rejected;
    if (isPendingReview) return UserAccessState.rolePendingApproval;
    if (!isOnboardingComplete) return UserAccessState.onboardingInProgress;
    if (hasApprovedRole) return UserAccessState.approvedActive;
    return UserAccessState.registeredUnonboarded;
  }

  static UserRole _parseRole(String? role) {
    switch ((role ?? '').trim().toLowerCase()) {
      case 'audience':
        return UserRole.audience;
      case 'talent':
        return UserRole.talent;
      case 'business':
        return UserRole.business;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.unknown;
    }
  }
}

class RoleApplication {
  final String applicationId;
  final String userId;
  final String applicantEmail;
  final String applicantName;
  final String requestedRole;
  final String status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewNote;

  RoleApplication({
    required this.applicationId,
    required this.userId,
    required this.applicantEmail,
    required this.applicantName,
    required this.requestedRole,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewNote,
  });

  RoleApplication copyWith({
    String? applicationId,
    String? userId,
    String? applicantEmail,
    String? applicantName,
    String? requestedRole,
    String? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewNote,
  }) {
    return RoleApplication(
      applicationId: applicationId ?? this.applicationId,
      userId: userId ?? this.userId,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      applicantName: applicantName ?? this.applicantName,
      requestedRole: requestedRole ?? this.requestedRole,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNote: reviewNote ?? this.reviewNote,
    );
  }

  factory RoleApplication.fromJson(Map<String, dynamic> json) {
    return RoleApplication(
      applicationId:
          (json['applicationId'] ?? json['application_id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      applicantEmail:
          (json['applicantEmail'] ?? json['applicant_email'] ?? '').toString(),
      applicantName:
          (json['applicantName'] ?? json['applicant_name'] ?? '').toString(),
      requestedRole:
          (json['requestedRole'] ?? json['requested_role'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      submittedAt: DateTime.tryParse(
            (json['submittedAt'] ?? json['submitted_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
      reviewedAt: json['reviewedAt'] != null || json['reviewed_at'] != null
          ? DateTime.tryParse(
              (json['reviewedAt'] ?? json['reviewed_at']).toString(),
            )
          : null,
      reviewNote: (json['reviewNote'] ?? json['review_note'])?.toString(),
    );
  }
}
