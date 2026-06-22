enum UserRole {
  audience,
  talent,
  business,
  admin,
  unknown,
}

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
  final String email;
  final String displayName;
  final String username;
  final String? profilePhoto;
  final String? coverPhoto;
  final String baseRole; // default: 'audience'
  final List<String> approvedRoles; // e.g. ['audience', 'talent']
  final String activeRole;
  final bool onboardingComplete;
  final String applicationStatusSummary; // 'none', 'pending', 'approved', 'rejected'

  UserModel({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.username,
    this.profilePhoto,
    this.coverPhoto,
    required this.baseRole,
    required this.approvedRoles,
    required this.activeRole,
    required this.onboardingComplete,
    required this.applicationStatusSummary,
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
      applicationStatusSummary: applicationStatusSummary ?? this.applicationStatusSummary,
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
      parsedActiveRole == UserRole.admin ||
      parsedApprovedRoles.contains(UserRole.admin);

  bool get hasApprovedRole =>
      parsedApprovedRoles.isNotEmpty ||
      applicationStatusSummary.trim().toLowerCase() == 'approved';

  bool get isOnboardingComplete => onboardingComplete == true;

  bool get isPendingReview {
    final status = applicationStatusSummary.trim().toLowerCase();
    return status == 'pending' || status == 'pending_review' || status == 'submitted';
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
  final String requestedRole; // 'talent' or 'business'
  final String status; // 'draft', 'submitted', 'pending_review', 'approved', 'rejected'
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

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'userId': userId,
      'applicantEmail': applicantEmail,
      'applicantName': applicantName,
      'requestedRole': requestedRole,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNote': reviewNote,
    };
  }

  factory RoleApplication.fromJson(Map<String, dynamic> json) {
    return RoleApplication(
      applicationId: (json['applicationId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      applicantEmail: (json['applicantEmail'] ?? '').toString(),
      applicantName: (json['applicantName'] ?? '').toString(),
      requestedRole: (json['requestedRole'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      submittedAt: DateTime.tryParse((json['submittedAt'] ?? '').toString()) ?? DateTime.now(),
      reviewedAt: DateTime.tryParse((json['reviewedAt'] ?? '').toString()),
      reviewNote: (json['reviewNote'] ?? '').toString().trim().isEmpty ? null : (json['reviewNote'] ?? '').toString(),
    );
  }
}
