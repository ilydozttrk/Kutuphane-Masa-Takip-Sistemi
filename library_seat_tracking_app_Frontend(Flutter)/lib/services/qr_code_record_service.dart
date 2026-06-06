import 'dart:typed_data';

import '../models/qr_code_record_model.dart';
import 'api_client.dart';

class QrCodeRecordService {
  Future<List<QrCodeRecordModel>> getQrCodeRecords() async {
    final response = await ApiClient.get('/qr-code-records');

    final data = response['data'];

    if (data is List) {
      return data
          .map(
            (item) => QrCodeRecordModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<List<QrCodeRecordModel>> getQrCodes() async {
    return getQrCodeRecords();
  }

  Future<QrCodeRecordModel?> updateQrCodeRecordStatus({
    required int qrCodeRecordId,
    required bool isActive,
  }) async {
    final response = await ApiClient.put(
      '/qr-code-records/$qrCodeRecordId/status',
      body: {
        'isActive': isActive,
      },
    );

    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return QrCodeRecordModel.fromJson(data);
    }

    if (data is Map) {
      return QrCodeRecordModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    return null;
  }

  Future<void> updateQrStatus({
    required int qrCodeId,
    required bool isActive,
  }) async {
    await ApiClient.put(
      '/qr-code-records/$qrCodeId/status',
      body: {
        'isActive': isActive,
      },
    );
  }

  Future<void> createQrCode({
    required String code,
    required int studyTableId,
  }) async {
    await ApiClient.post(
      '/qr-code-records',
      body: {
        'code': code,
        'studyTableId': studyTableId,
      },
    );
  }

  Future<Uint8List> getQrCodeImageBytes({
    required int qrCodeRecordId,
  }) async {
    return ApiClient.getBytes(
      '/qr-code-records/$qrCodeRecordId/image',
    );
  }

  Future<Uint8List> downloadQrCodeBytes({
    required int qrCodeRecordId,
  }) async {
    return ApiClient.getBytes(
      '/qr-code-records/$qrCodeRecordId/download',
    );
  }

  Future<String> getQrCodePrintHtml({
    required int qrCodeRecordId,
  }) async {
    return ApiClient.getText(
      '/qr-code-records/$qrCodeRecordId/print',
    );
  }
}