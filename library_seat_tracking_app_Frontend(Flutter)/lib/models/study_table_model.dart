class StudyTableModel {
  final int id;
  final String code;
  final int status;
  final int locationAreaId;
  final String locationAreaName;
  final bool isActive;
  final DateTime? createdAt;

  StudyTableModel({
    required this.id,
    required this.code,
    required this.status,
    required this.locationAreaId,
    required this.locationAreaName,
    required this.isActive,
    required this.createdAt,
  });

  factory StudyTableModel.fromJson(Map<String, dynamic> json) {
    return StudyTableModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      status: _parseStatus(json['status']),
      locationAreaId: json['locationAreaId'] ?? 0,
      locationAreaName: json['locationAreaName'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }

  static int _parseStatus(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'available':
          return 1;
        case 'occupied':
          return 2;
        case 'reserved':
          return 3;
        case 'maintenance':
          return 4;
        default:
          return int.tryParse(value) ?? 0;
      }
    }

    return 0;
  }

  bool get isAvailable => status == 1;

  bool get isOccupied => status == 2;

  bool get isReserved => status == 3;

  bool get isMaintenance => status == 4;

  String get statusText {
    switch (status) {
      case 1:
        return 'Boş';
      case 2:
        return 'Dolu';
      case 3:
        return 'Rezerve';
      case 4:
        return 'Bakımda';
      default:
        return 'Bilinmiyor';
    }
  }
}