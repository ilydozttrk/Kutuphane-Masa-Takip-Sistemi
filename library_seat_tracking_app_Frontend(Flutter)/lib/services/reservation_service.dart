import '../models/reservation_model.dart';
import 'api_client.dart';

class ReservationService {
  Future<List<ReservationModel>> getMyReservations() async {
    final response = await ApiClient.get('/reservations/my');

    final data = response['data'];

    if (data is List) {
      return data
          .map((item) => ReservationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<ReservationModel> createReservation({
    required String qrCode,
    required double userLatitude,
    required double userLongitude,
    int durationMinutes = 60,
  }) async {
    final response = await ApiClient.post(
      '/reservations',
      body: {
        'qrCode': qrCode,
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
        'durationMinutes': durationMinutes,
      },
    );

    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return ReservationModel.fromJson(data);
    }

    throw ApiException(
      message: response['message']?.toString() ??
          'Rezervasyon oluşturulurken beklenmeyen bir cevap alındı.',
    );
  }

  Future<ReservationModel> renewReservation({
    required String qrCode,
    required double userLatitude,
    required double userLongitude,
    int extraMinutes = 60,
  }) async {
    final response = await ApiClient.post(
      '/reservations/renew',
      body: {
        'qrCode': qrCode,
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
        'extraMinutes': extraMinutes,
      },
    );

    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return ReservationModel.fromJson(data);
    }

    throw ApiException(
      message: response['message']?.toString() ??
          'Rezervasyon yenilenirken beklenmeyen bir cevap alındı.',
    );
  }

  Future<void> completeReservation({
    required int reservationId,
  }) async {
    await ApiClient.put('/reservations/$reservationId/complete');
  }

  Future<ReservationModel?> getActiveReservation() async {
    final reservations = await getMyReservations();

    for (final reservation in reservations) {
      if (reservation.isActive) {
        return reservation;
      }
    }

    return null;
  }
}