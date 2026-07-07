// Minimal temporary compatibility shims for compilation.
// Replace with the full, authoritative models when available.

class UserBadgeView {
  final String name;
  UserBadgeView({required this.name});
  factory UserBadgeView.fromJson(Map<String, dynamic> json) => UserBadgeView(name: json['name']?.toString() ?? '');
}

class ProofEventView {
  final DateTime at;
  final String title;
  final String subtitle;
  final ProofEventKind kind;
  ProofEventView({required this.at, required this.title, required this.subtitle, required this.kind});
  factory ProofEventView.fromJson(Map<String, dynamic> json) {
    return ProofEventView(
      at: DateTime.tryParse(json['at']?.toString() ?? '') ?? DateTime.now(),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      kind: ProofEventKind.values.firstWhere(
        (e) => e.toString().split('.').last == (json['kind']?.toString() ?? ''),
        orElse: () => ProofEventKind.mission,
      ),
    );
  }
}

enum ProofEventKind {
  mission,
  campaign,
  purchase,
  subscription,
  tip,
  attendance,
  milestone,
}

class CampaignListItemModel {
  final String id;
  CampaignListItemModel({required this.id});
}

enum MissionStatus { notStarted, inProgress, completed }

class PostModel {
  final String id;
  final String title;
  PostModel({required this.id, required this.title});
  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(id: json['id']?.toString() ?? '', title: json['title']?.toString() ?? '');
}
