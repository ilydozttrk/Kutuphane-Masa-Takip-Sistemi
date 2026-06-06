import 'package:flutter/foundation.dart';

import 'api_client.dart';

class DeviceTokenService {
  DeviceTokenService._();

  static Future<void> registerDeviceToken({
    required String token,
  }) async {
    if (token.isEmpty) {
      debugPrint('FCM token boş olduğu için backend kaydı yapılmadı.');
      return;
    }

    final deviceName = _getDeviceName();

    try {
      await ApiClient.post(
        '/device-tokens/register',
        body: {
          'token': token,
          'deviceName': deviceName,
        },
      );

      debugPrint('FCM token backend’e başarıyla kaydedildi.');
    } catch (e) {
      debugPrint('FCM token backend’e kaydedilemedi: $e');
    }
  }

  static String _getDeviceName() {
    if (kIsWeb) {
      return 'Web Browser';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android Device';
      case TargetPlatform.iOS:
        return 'iOS Device';
      case TargetPlatform.windows:
        return 'Windows Device';
      case TargetPlatform.macOS:
        return 'macOS Device';
      case TargetPlatform.linux:
        return 'Linux Device';
      case TargetPlatform.fuchsia:
        return 'Fuchsia Device';
    }
  }
}