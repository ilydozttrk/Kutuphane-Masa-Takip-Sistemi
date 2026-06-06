class BlockRecordModel {
  final int id;
  final int userId;
  final String userFullName;
  final String userEmail;
  final String reason;
  final DateTime? blockedAt;
  final DateTime? endsAt;
  final bool isActive;

  BlockRecordModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    required this.reason,
    required this.blockedAt,
    required this.endsAt,
    required this.isActive,
  });

  factory BlockRecordModel.fromJson(Map<String, dynamic> json) {
    return BlockRecordModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      userFullName: json['userFullName']?.toString() ?? '',
      userEmail: json['userEmail']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      blockedAt: json['blockedAt'] != null
          ? DateTime.tryParse(json['blockedAt'].toString())
          : null,
      endsAt: json['endsAt'] != null
          ? DateTime.tryParse(json['endsAt'].toString())
          : null,
      isActive: json['isActive'] ?? false,
    );
  }

  String get statusText {
    return isActive ? 'Aktif Bloke' : 'Bloke Kaldırıldı';
  }
}
