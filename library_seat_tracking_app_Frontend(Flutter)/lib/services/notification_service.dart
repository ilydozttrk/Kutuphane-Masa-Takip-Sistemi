import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'device_token_service.dart';

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('Web platformunda FCM token alma işlemi atlandı.');
      return;
    }

    await _requestNotificationPermission();

    final token = await getFcmToken();

    if (token != null && token.isNotEmpty) {
      debugPrint('FCM Token: $token');
    } else {
      debugPrint('FCM token alınamadı.');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Ön planda bildirim alındı.');
      debugPrint('Başlık: ${message.notification?.title}');
      debugPrint('Mesaj: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Kullanıcı bildirime tıkladı.');
      debugPrint('Bildirim data: ${message.data}');
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM token yenilendi: $newToken');

      await DeviceTokenService.registerDeviceToken(
        token: newToken,
      );
    });
  }

  static Future<void> _requestNotificationPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Bildirim izin durumu: ${settings.authorizationStatus}');
  }

  static Future<String?> getFcmToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (e) {
      debugPrint('FCM token alınırken hata oluştu: $e');
      return null;
    }
  }

  static Future<void> registerCurrentDeviceToken() async {
    if (kIsWeb) {
      debugPrint('Web platformunda cihaz token kaydı atlandı.');
      return;
    }

    final token = await getFcmToken();

    if (token == null || token.isEmpty) {
      debugPrint('FCM token boş olduğu için backend kaydı yapılmadı.');
      return;
    }

    await DeviceTokenService.registerDeviceToken(
      token: token,
    );
  }
}