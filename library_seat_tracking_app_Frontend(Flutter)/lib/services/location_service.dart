import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;

  LocationResult({
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Konum servisi kapalı. Rezervasyon yapabilmek için konum servisini açmalısın.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'Konum izni verilmedi. Rezervasyon yapabilmek için konum izni gerekli.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Konum izni kalıcı olarak reddedilmiş. Ayarlardan uygulama konum iznini açmalısın.',
      );
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );

    final position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}