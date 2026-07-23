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
  pendingApproval,
  approved,
  rejected,
  restricted,
  suspended,
}

UserRole parseRole(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
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
  final String? requestedRolePending;
  final bool approved;
  final bool isAdminFlag;
  final bool adminRoleEditEnabled;

  const UserModel({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.username,
    required this.profilePhoto,
    required this.coverPhoto,
    required this.baseRole,
    required this.approvedRoles,
    required this.activeRole,
    required this.onboardingComplete,
    required this.applicationStatusSummary,
    required this.requestedRolePending,
    required this.approved,
    required this.isAdminFlag,
    required this.adminRoleEditEnabled,
  });

  UserModel copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? username,
    String? profilePhoto,
    String? coverPhoto,
    String? baseRole,
    List<String>? approvedRoles,
    String? activeRole,
    bool? onboardingComplete,
    String? applicationStatusSummary,
    String? requestedRolePending,
    bool? approved,
    Object? isAdminFlag = _unset,
    Object? adminRoleEditEnabled = _unset,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
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
      requestedRolePending: requestedRolePending ?? this.requestedRolePending,
      approved: approved ?? this.approved,
      isAdminFlag: identical(isAdminFlag, _unset)
          ? this.isAdminFlag
          : isAdminFlag as bool,
      adminRoleEditEnabled: identical(adminRoleEditEnabled, _unset)
          ? this.adminRoleEditEnabled
          : adminRoleEditEnabled as bool,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> parseApprovedRoles(dynamic value) {
      if (value == null) return ['audience'];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return ['audience'];
    }

    final activeRole =
        (json['activeRole'] ?? json['active_role'] ?? 'audience').toString();

    final pendingRoleRaw =
        (json['requestedRolePending'] ?? json['requested_role_pending'])
            ?.toString();

    return UserModel(
      userId: (json['userId'] ?? json['user_id'] ?? json['id'] ?? '').toString(),
      email: json['email']?.toString(),
      displayName: (json['displayName'] ?? json['display_name'] ?? 'User')
          .toString(),
      username: (json['username'] ?? '').toString(),
      profilePhoto: (json['profilePhoto'] ?? json['profile_photo'])?.toString(),
      coverPhoto: (json['coverPhoto'] ?? json['cover_photo'])?.toString(),
      baseRole: (json['baseRole'] ?? json['base_role'] ?? 'audience').toString(),
      approvedRoles: parseApprovedRoles(
        json['approvedRoles'] ?? json['approved_roles'],
      ),
      activeRole: activeRole,
      onboardingComplete:
          (json['onboardingComplete'] ?? json['onboarding_complete'] ?? false) ==
              true,
      applicationStatusSummary:
          (json['applicationStatusSummary'] ??
                  json['application_status_summary'] ??
                  'none')
              .toString(),
      requestedRolePending:
          pendingRoleRaw == null || pendingRoleRaw.trim().isEmpty
              ? null
              : pendingRoleRaw,
      approved: (json['approved'] ?? false) == true,
      isAdminFlag: (json['isAdmin'] ?? json['is_admin'] ?? false) == true,
      adminRoleEditEnabled:
          (json['adminRoleEditEnabled'] ??
                  json['admin_role_edit_enabled'] ??
                  false) ==
              true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'username': username,
      'profilePhoto': profilePhoto,
      'coverPhoto': coverPhoto,
      'baseRole': baseRole,
      'approvedRoles': approvedRoles,
      'activeRole': activeRole,
      'onboardingComplete': onboardingComplete,
      'applicationStatusSummary': applicationStatusSummary,
      'requestedRolePending': requestedRolePending,
      'approved': approved,
      'isAdmin': isAdminFlag,
      'adminRoleEditEnabled': adminRoleEditEnabled,
    };
  }

  UserRole get parsedActiveRole => parseRole(activeRole);

  List<UserRole> get parsedApprovedRoles =>
      approvedRoles.map(parseRole).toList();

  bool get isLoggedOut => userId.trim().isEmpty;

  bool get isPendingReview =>
      applicationStatusSummary.trim().toLowerCase() == 'pending';

  bool get isRejected =>
      applicationStatusSummary.trim().toLowerCase() == 'rejected';

  bool get isRestricted =>
      applicationStatusSummary.trim().toLowerCase() == 'restricted';

  bool get isSuspended =>
      applicationStatusSummary.trim().toLowerCase() == 'suspended';

  bool get isAdmin =>
      isAdminFlag ||
      approvedRoles.map((r) => r.toLowerCase()).contains('admin') ||
      activeRole.trim().toLowerCase() == 'admin';
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

  const RoleApplication({
    required this.applicationId,
    required this.userId,
    required this.applicantEmail,
    required this.applicantName,
    required this.requestedRole,
    required this.status,
    required this.submittedAt,
    required this.reviewedAt,
    required this.reviewNote,
  });

  factory RoleApplication.fromJson(Map<String, dynamic> json) {
    final reviewNoteRaw =
        (json['reviewNote'] ?? json['review_note'])?.toString();

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
      reviewNote:
          reviewNoteRaw == null || reviewNoteRaw.trim().isEmpty
              ? null
              : reviewNoteRaw,
    );
  }
}
