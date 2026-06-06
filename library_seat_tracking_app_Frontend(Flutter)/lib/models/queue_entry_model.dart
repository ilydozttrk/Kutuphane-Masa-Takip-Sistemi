class QueueEntryModel {
  final int id;
  final int userId;
  final String userFullName;
  final int studyTableId;
  final String studyTableCode;
  final int status;
  final DateTime? createdAt;

  QueueEntryModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.studyTableId,
    required this.studyTableCode,
    required this.status,
    required this.createdAt,
  });

  factory QueueEntryModel.fromJson(Map<String, dynamic> json) {
    return QueueEntryModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      userFullName: json['userFullName']?.toString() ?? '',
      studyTableId: json['studyTableId'] ?? 0,
      studyTableCode: json['studyTableCode']?.toString() ?? '',
      status: json['status'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  String get statusText {
    switch (status) {
      case 1:
        return 'Bekliyor';
      case 2:
        return 'Bildirim Gönderildi';
      case 3:
        return 'Tamamlandı';
      case 4:
        return 'İptal Edildi';
      default:
        return 'Bilinmiyor';
    }
  }

  bool get isWaiting => status == 1;
  bool get isNotified => status == 2;
  bool get isCompleted => status == 3;
  bool get isCancelled => status == 4;
}