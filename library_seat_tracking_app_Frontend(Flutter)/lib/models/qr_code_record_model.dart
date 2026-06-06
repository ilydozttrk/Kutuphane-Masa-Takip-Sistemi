class QrCodeRecordModel {
  final int id;
  final String code;
  final int studyTableId;
  final String studyTableCode;
  final bool isActive;
  final DateTime? createdAt;

  QrCodeRecordModel({
    required this.id,
    required this.code,
    required this.studyTableId,
    required this.studyTableCode,
    required this.isActive,
    required this.createdAt,
  });

  factory QrCodeRecordModel.fromJson(Map<String, dynamic> json) {
    return QrCodeRecordModel(
      id: json['id'] ?? 0,
      code: json['code']?.toString() ?? '',
      studyTableId: json['studyTableId'] ?? 0,
      studyTableCode: json['studyTableCode']?.toString() ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }

  String get statusText {
    return isActive ? 'Aktif' : 'Pasif';
  }
}