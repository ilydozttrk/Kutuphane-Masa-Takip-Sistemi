import '../models/app_notification_model.dart';
import 'api_client.dart';

class AppNotificationService {
  Future<List<AppNotificationModel>> getMyNotifications() async {
    final response = await ApiClient.get('/notifications/my');

    final data = response['data'];

    if (data is List) {
      return data
          .map(
            (item) => AppNotificationModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<void> markAsRead({
    required int notificationId,
  }) async {
    await ApiClient.put('/notifications/$notificationId/read');
  }
}