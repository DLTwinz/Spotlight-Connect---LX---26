import 'package:flutter/foundation.dart';

@immutable
class OpportunityApplicationModel {
  const OpportunityApplicationModel({
    required this.applicationId,
    required this.opportunityId,
    required this.applicantUserId,
    required this.applicantEmail,
    required this.applicantName,
    required this.pitch,
    required this.portfolioLinks,
    required this.availability,
    required this.businessNote,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String applicationId;
  final String opportunityId;
  final String applicantUserId;
  final String applicantEmail;
  final String applicantName;
  final String pitch;
  final List<String> portfolioLinks;
  final String availability;

  /// Business/admin internal note or request (used for needs_more_info loop).
  final String businessNote;

  /// submitted | needs_more_info | shortlisted | rejected
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  OpportunityApplicationModel copyWith({
    String? applicationId,
    String? opportunityId,
    String? applicantUserId,
    String? applicantEmail,
    String? applicantName,
    String? pitch,
    List<String>? portfolioLinks,
    String? availability,
    String? businessNote,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OpportunityApplicationModel(
      applicationId: applicationId ?? this.applicationId,
      opportunityId: opportunityId ?? this.opportunityId,
      applicantUserId: applicantUserId ?? this.applicantUserId,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      applicantName: applicantName ?? this.applicantName,
      pitch: pitch ?? this.pitch,
      portfolioLinks: portfolioLinks ?? this.portfolioLinks,
      availability: availability ?? this.availability,
      businessNote: businessNote ?? this.businessNote,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'opportunityId': opportunityId,
      'applicantUserId': applicantUserId,
      'applicantEmail': applicantEmail,
      'applicantName': applicantName,
      'pitch': pitch,
      'portfolioLinks': portfolioLinks,
      'availability': availability,
      'businessNote': businessNote,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory OpportunityApplicationModel.fromJson(Map<String, dynamic> json) {
    final linksRaw = json['portfolioLinks'];
    return OpportunityApplicationModel(
      applicationId: (json['applicationId'] ?? '').toString(),
      opportunityId: (json['opportunityId'] ?? '').toString(),
      applicantUserId: (json['applicantUserId'] ?? '').toString(),
      applicantEmail: (json['applicantEmail'] ?? '').toString(),
      applicantName: (json['applicantName'] ?? '').toString(),
      pitch: (json['pitch'] ?? '').toString(),
      portfolioLinks: linksRaw is List
          ? linksRaw.map((e) => e.toString()).toList()
          : const <String>[],
      availability: (json['availability'] ?? '').toString(),
      businessNote: (json['businessNote'] ?? '').toString(),
      status: (json['status'] ?? 'submitted').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
