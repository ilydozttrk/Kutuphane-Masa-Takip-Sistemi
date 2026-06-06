class LocationAreaModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool isActive;
  final DateTime? createdAt;

  LocationAreaModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.isActive,
    required this.createdAt,
  });

  factory LocationAreaModel.fromJson(Map<String, dynamic> json) {
    return LocationAreaModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      radiusMeters: _toDouble(json['radiusMeters']),
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  String get statusText {
    return isActive ? 'Aktif' : 'Pasif';
  }
}