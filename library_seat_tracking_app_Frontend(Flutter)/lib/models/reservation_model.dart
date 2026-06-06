class ReservationModel {
  final int id;
  final int userId;
  final String userFullName;
  final int studyTableId;
  final String studyTableCode;
  final DateTime? startTime;
  final DateTime? endTime;
  final int status;
  final String? staffNote;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.studyTableId,
    required this.studyTableCode,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.staffNote,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      userFullName: json['userFullName'] ?? '',
      studyTableId: json['studyTableId'] ?? 0,
      studyTableCode: json['studyTableCode'] ?? '',
      startTime: json['startTime'] == null
          ? null
          : DateTime.tryParse(json['startTime'].toString())?.toLocal(),
      endTime: json['endTime'] == null
          ? null
          : DateTime.tryParse(json['endTime'].toString())?.toLocal(),
      status: _parseStatus(json['status']),
      staffNote: json['staffNote'],
    );
  }

  static int _parseStatus(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'active':
          return 1;
        case 'completed':
          return 2;
        case 'cancelled':
          return 3;
        case 'expired':
          return 4;
        default:
          return int.tryParse(value) ?? 0;
      }
    }

    return 0;
  }

  bool get isActive => status == 1;

  bool get isCompleted => status == 2;

  bool get isCancelled => status == 3;

  bool get isExpired => status == 4;

  String get statusText {
    switch (status) {
      case 1:
        return 'Aktif';
      case 2:
        return 'Tamamlandı';
      case 3:
        return 'İptal Edildi';
      case 4:
        return 'Süresi Doldu';
      default:
        return 'Bilinmiyor';
    }
  }
}