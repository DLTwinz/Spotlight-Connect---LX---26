class MessageThreadModel {
  const MessageThreadModel({
    required this.threadId,
    required this.participantUserIds,
    required this.participantNames,
    required this.participantEmails,
    required this.updatedAt,
    this.opportunityId,
    this.lastMessagePreview,
    this.lastSenderUserId,
    this.unreadCounts = const {},
    this.lastReadAtByUserId = const {},
  });

  final String threadId;
  final String? opportunityId;
  final List<String> participantUserIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantEmails;
  final DateTime updatedAt;
  final String? lastMessagePreview;
  final String? lastSenderUserId;
  final Map<String, int> unreadCounts;
  /// Tracks the last time each participant read the thread.
  /// Used for lightweight "seen" indicators without per-message receipts.
  final Map<String, DateTime> lastReadAtByUserId;

  MessageThreadModel copyWith({
    String? threadId,
    String? opportunityId,
    List<String>? participantUserIds,
    Map<String, String>? participantNames,
    Map<String, String>? participantEmails,
    DateTime? updatedAt,
    String? lastMessagePreview,
    String? lastSenderUserId,
    Map<String, int>? unreadCounts,
    Map<String, DateTime>? lastReadAtByUserId,
  }) {
    return MessageThreadModel(
      threadId: threadId ?? this.threadId,
      opportunityId: opportunityId ?? this.opportunityId,
      participantUserIds: participantUserIds ?? this.participantUserIds,
      participantNames: participantNames ?? this.participantNames,
      participantEmails: participantEmails ?? this.participantEmails,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastSenderUserId: lastSenderUserId ?? this.lastSenderUserId,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      lastReadAtByUserId: lastReadAtByUserId ?? this.lastReadAtByUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'threadId': threadId,
      'opportunityId': opportunityId,
      'participantUserIds': participantUserIds,
      'participantNames': participantNames,
      'participantEmails': participantEmails,
      'updatedAt': updatedAt.toIso8601String(),
      'lastMessagePreview': lastMessagePreview,
      'lastSenderUserId': lastSenderUserId,
      'unreadCounts': unreadCounts,
      'lastReadAtByUserId': lastReadAtByUserId.map((k, v) => MapEntry(k, v.toIso8601String())),
    };
  }

  factory MessageThreadModel.fromJson(Map<String, dynamic> json) {
    final rawReads = (json['lastReadAtByUserId'] as Map? ?? const {});
    final reads = <String, DateTime>{
      for (final e in rawReads.entries)
        e.key.toString(): DateTime.tryParse(e.value.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
    };

    return MessageThreadModel(
      threadId: (json['threadId'] ?? '').toString(),
      opportunityId: json['opportunityId']?.toString(),
      participantUserIds: (json['participantUserIds'] as List? ?? const []).map((e) => e.toString()).toList(),
      participantNames: (json['participantNames'] as Map? ?? const {}).map((k, v) => MapEntry(k.toString(), v.toString())),
      participantEmails: (json['participantEmails'] as Map? ?? const {}).map((k, v) => MapEntry(k.toString(), v.toString())),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      lastMessagePreview: json['lastMessagePreview']?.toString(),
      lastSenderUserId: json['lastSenderUserId']?.toString(),
      unreadCounts: (json['unreadCounts'] as Map? ?? const {}).map((k, v) => MapEntry(k.toString(), (v is num) ? v.toInt() : int.tryParse(v.toString()) ?? 0)),
      lastReadAtByUserId: reads,
    );
  }
}
