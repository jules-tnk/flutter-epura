import 'scan_folder_grant.dart';

class FolderProfile {
  final String uri;
  final String name;
  final String? nickname;
  final DateTime? lastReviewedAt;

  const FolderProfile({
    required this.uri,
    required this.name,
    this.nickname,
    this.lastReviewedAt,
  });

  String get displayName {
    final trimmed = nickname?.trim();
    return trimmed == null || trimmed.isEmpty ? name : trimmed;
  }

  ScanFolderGrant get grant => ScanFolderGrant(uri: uri, name: name);

  FolderProfile copyWith({
    String? name,
    String? nickname,
    bool clearNickname = false,
    DateTime? lastReviewedAt,
  }) {
    return FolderProfile(
      uri: uri,
      name: name ?? this.name,
      nickname: clearNickname ? null : nickname ?? this.nickname,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  Map<String, Object?> toJson() => {
    'uri': uri,
    'name': name,
    'nickname': nickname,
    'lastReviewedAt': lastReviewedAt?.toIso8601String(),
  };

  factory FolderProfile.fromGrant(ScanFolderGrant grant) {
    return FolderProfile(uri: grant.uri, name: grant.name);
  }

  factory FolderProfile.fromJson(Map<String, dynamic> json) {
    final lastReviewedRaw = json['lastReviewedAt'] as String?;
    return FolderProfile(
      uri: json['uri'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      lastReviewedAt: lastReviewedRaw == null
          ? null
          : DateTime.tryParse(lastReviewedRaw),
    );
  }
}
