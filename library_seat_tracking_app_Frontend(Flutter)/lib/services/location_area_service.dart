import '../models/location_area_model.dart';
import 'api_client.dart';

class LocationAreaService {
  Future<List<LocationAreaModel>> getLocationAreas() async {
    final response = await ApiClient.get('/location-areas');

    final data = response['data'];

    if (data is List) {
      return data
          .map(
            (item) => LocationAreaModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<void> createLocationArea({
    required String name,
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    await ApiClient.post(
      '/location-areas',
      body: {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radiusMeters': radiusMeters,
      },
    );
  }
}