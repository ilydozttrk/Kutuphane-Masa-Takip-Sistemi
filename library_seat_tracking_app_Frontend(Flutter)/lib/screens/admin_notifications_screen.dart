import 'package:flutter/material.dart';

import '../models/app_notification_model.dart';
import '../services/app_notification_service.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final AppNotificationService _notificationService = AppNotificationService();

  List<AppNotificationModel> notifications = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final result = await _notificationService.getMyNotifications();

      setState(() {
        notifications = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("BİLDİRİM HATASI: $e");
    }
  }

  Future<void> markAsRead(AppNotificationModel notification) async {
    try {
      await _notificationService.markAsRead(notificationId: notification.id);

      await loadNotifications();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bildirim okundu olarak işaretlendi.")),
      );
    } catch (e) {
      debugPrint("BİLDİRİM OKUNDU HATASI: $e");
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return "-";
    }

    return "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Color getStatusColor(AppNotificationModel notification) {
    return notification.isRead ? Colors.grey : Colors.blue;
  }

  IconData getStatusIcon(AppNotificationModel notification) {
    return notification.isRead
        ? Icons.notifications_none
        : Icons.notifications_active;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bildirimlerim")),
      body: RefreshIndicator(
        onRefresh: loadNotifications,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
            ? const Center(child: Text("Bildirim bulunmuyor."))
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: getStatusColor(notification),
                                child: Icon(
                                  getStatusIcon(notification),
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(notification.message),
                          const SizedBox(height: 8),
                          Text("Tip: ${notification.type}"),
                          const SizedBox(height: 6),
                          Text("Tarih: ${formatDate(notification.createdAt)}"),
                          const SizedBox(height: 6),
                          Text(
                            notification.isRead
                                ? "Durum: Okundu"
                                : "Durum: Okunmadı",
                          ),
                          if (!notification.isRead) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  markAsRead(notification);
                                },
                                icon: const Icon(Icons.done),
                                label: const Text("Okundu Olarak İşaretle"),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
