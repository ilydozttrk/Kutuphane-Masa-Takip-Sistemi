import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException({
    this.statusCode,
    required this.message,
  });

  @override
  String toString() {
    return message;
  }
}

class ApiClient {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5024/api';
    }

    // Telefon APK için bilgisayarın Wi-Fi IPv4 adresi.
    // Backend şu komutla çalışmalı:
    // dotnet run --urls "http://0.0.0.0:5024"
    return 'http://10.211.247.182:5024/api';

    // Emülatörde tekrar test etmek istersen üstteki satır yerine bunu kullan:
    // return 'http://10.0.2.2:5024/api';
  }

  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  static Future<Map<String, String>> authHeaders({
    bool useAuth = true,
    bool jsonContent = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (jsonContent) {
      headers['Content-Type'] = 'application/json';
    }

    if (useAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<Map<String, String>> _headers({
    bool useAuth = true,
  }) async {
    return authHeaders(
      useAuth: useAuth,
      jsonContent: true,
    );
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool useAuth = true,
  }) async {
    final response = await http.get(
      Uri.parse(buildUrl(endpoint)),
      headers: await _headers(useAuth: useAuth),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool useAuth = true,
  }) async {
    final response = await http.post(
      Uri.parse(buildUrl(endpoint)),
      headers: await _headers(useAuth: useAuth),
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool useAuth = true,
  }) async {
    final response = await http.put(
      Uri.parse(buildUrl(endpoint)),
      headers: await _headers(useAuth: useAuth),
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  static Future<Uint8List> getBytes(
    String endpoint, {
    bool useAuth = true,
  }) async {
    final response = await http.get(
      Uri.parse(buildUrl(endpoint)),
      headers: await authHeaders(
        useAuth: useAuth,
        jsonContent: false,
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }

    final decodedBody = _decodeBody(response);
    final message = decodedBody['message']?.toString() ??
        'İstek başarısız oldu. Durum kodu: ${response.statusCode}';

    throw ApiException(
      statusCode: response.statusCode,
      message: message,
    );
  }

  static Future<String> getText(
    String endpoint, {
    bool useAuth = true,
  }) async {
    final response = await http.get(
      Uri.parse(buildUrl(endpoint)),
      headers: await authHeaders(
        useAuth: useAuth,
        jsonContent: false,
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return utf8.decode(response.bodyBytes);
    }

    final decodedBody = _decodeBody(response);
    final message = decodedBody['message']?.toString() ??
        'İstek başarısız oldu. Durum kodu: ${response.statusCode}';

    throw ApiException(
      statusCode: response.statusCode,
      message: message,
    );
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final decodedBody = _decodeBody(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    final message = decodedBody['message']?.toString() ??
        'İstek başarısız oldu. Durum kodu: ${response.statusCode}';

    throw ApiException(
      statusCode: response.statusCode,
      message: message,
    );
  }

  static Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'success': true,
        'message': '',
        'data': decoded,
      };
    } catch (_) {
      return {
        'success': false,
        'message': utf8.decode(response.bodyBytes),
        'data': null,
      };
    }
  }
}