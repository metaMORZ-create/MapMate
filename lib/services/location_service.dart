import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  // Erlaubnis auf Standort zugreifen
  static Future<bool> checkAndRequestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // Standortabfrage einmalig
  static Future<LatLng?> getCurrentLocation() async {
    if (!await checkAndRequestLocationPermission()) return null;

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  static Future<Stream<LatLng>?> getLocationStream({int distanceFilter = 10}) async {
    if (!await checkAndRequestLocationPermission()) return null;
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return Geolocator.getPositionStream().map((Position position) {
      return LatLng(position.latitude, position.longitude);
    });
  }
}
