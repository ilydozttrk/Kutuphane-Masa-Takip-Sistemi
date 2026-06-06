class AppNotificationModel {
  final int id;
  final int userId;
  final int? reservationId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;

  AppNotificationModel({
    required this.id,
    required this.userId,
    required this.reservationId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      reservationId: json['reservationId'],
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isRead: json['isRead'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}