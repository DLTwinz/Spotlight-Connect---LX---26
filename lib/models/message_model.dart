class MessageModel {
  const MessageModel({
    required this.messageId,
    required this.threadId,
    required this.senderUserId,
    required this.senderName,
    required this.body,
    required this.createdAt,
  });

  final String messageId;
  final String threadId;
  final String senderUserId;
  final String senderName;
  final String body;
  final DateTime createdAt;

  MessageModel copyWith({
    String? messageId,
    String? threadId,
    String? senderUserId,
    String? senderName,
    String? body,
    DateTime? createdAt,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      threadId: threadId ?? this.threadId,
      senderUserId: senderUserId ?? this.senderUserId,
      senderName: senderName ?? this.senderName,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'threadId': threadId,
      'senderUserId': senderUserId,
      'senderName': senderName,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: (json['messageId'] ?? '').toString(),
      threadId: (json['threadId'] ?? '').toString(),
      senderUserId: (json['senderUserId'] ?? '').toString(),
      senderName: (json['senderName'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
