import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class AuthService {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final result = await ApiClient.post(
        '/auth/login',
        useAuth: false,
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          throw ApiException(
            message:
                'Sunucuya bağlanılamadı. Backend adresini ve bağlantıyı kontrol edin.',
          );
        },
      );

      debugPrint('LOGIN SONUCU: $result');

      if (result['success'] == true) {
        final rawData = result['data'];

        if (rawData is! Map) {
          debugPrint('LOGIN DATA FORMATI HATALI: $rawData');
          return result;
        }

        final userData = Map<String, dynamic>.from(rawData);

        final prefs = await SharedPreferences.getInstance();

        await prefs.setInt('userId', _toInt(userData['userId']));
        await prefs.setString(
          'fullName',
          userData['fullName']?.toString() ?? '',
        );
        await prefs.setString(
          'email',
          userData['email']?.toString() ?? '',
        );
        await prefs.setString(
          'role',
          userData['role']?.toString() ?? '',
        );
        await prefs.setString(
          'accessToken',
          userData['accessToken']?.toString() ?? '',
        );
        await prefs.setString(
          'refreshToken',
          userData['refreshToken']?.toString() ?? '',
        );

        debugPrint('KULLANICI BİLGİLERİ KAYDEDİLDİ');
        debugPrint('Ad Soyad: ${userData['fullName']}');
        debugPrint('Email: ${userData['email']}');
        debugPrint('Rol: ${userData['role']}');

        return result;
      }

      debugPrint('LOGIN BAŞARISIZ');
      debugPrint('Backend cevabı: $result');
      return result;
    } catch (e) {
      debugPrint('AUTH SERVICE HATASI: $e');
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fullName');
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    debugPrint('KULLANICI ÇIKIŞ YAPTI, KAYITLI BİLGİLER TEMİZLENDİ');
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}