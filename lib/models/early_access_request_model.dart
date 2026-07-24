class EarlyAccessRequestModel {
  const EarlyAccessRequestModel({
    required this.id,
    required this.email,
    required this.name,
    required this.desiredRole,
    required this.status,
    this.note,
    this.reviewNote,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String name;
  final String desiredRole;
  final String status;
  final String? note;
  final String? reviewNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  EarlyAccessRequestModel copyWith({
    String? id,
    String? email,
    String? name,
    String? desiredRole,
    String? status,
    String? note,
    String? reviewNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EarlyAccessRequestModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      desiredRole: desiredRole ?? this.desiredRole,
      status: status ?? this.status,
      note: note ?? this.note,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseDt(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (v is DateTime) return v;
    if (v is String) {
      return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory EarlyAccessRequestModel.fromSupabase(Map<String, dynamic> json) {
    return EarlyAccessRequestModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      desiredRole: (json['desired_role'] ?? 'audience').toString(),
      status: (json['status'] ?? 'pending').toString(),
      note: json['note']?.toString(),
      reviewNote: json['review_note']?.toString(),
      createdAt: _parseDt(json['created_at']),
      updatedAt: _parseDt(json['updated_at']),
    );
  }

  Map<String, dynamic> toSupabaseInsert() {
    return {
      'email': email.toLowerCase().trim(),
      'name': name.trim(),
      'desired_role': desiredRole,
      'status': status,
      'note': note,
    };
  }
}
