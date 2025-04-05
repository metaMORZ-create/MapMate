import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import "package:http/http.dart" as http;
import "dart:convert";
import "package:flutter/cupertino.dart";

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

  static Future<Stream<LatLng>?> getLocationStream({
    int distanceFilter = 10,
  }) async {
    if (!await checkAndRequestLocationPermission()) return null;
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings).map(
      (Position position) {
        return LatLng(position.latitude, position.longitude);
      },
    );
  }

  // Service zum Speichern der Standortdaten in der DB
  static Future<bool> addLocation(int userId, LatLng pos) async {
    const url =
        "https://map-mates-profile-api-production.up.railway.app/locations/add_location";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "latitude": pos.latitude,
          "longitude": pos.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final username = json["user"];
        debugPrint("Added Location for: $username");

        return true;
      } else {
        debugPrint("Adding Location failed");
        return false;
      }
    } catch (e) {
      debugPrint("Error during Adding of location: $e");
      return false;
    }
  }

  static Future<bool> markVisitedZone(int userId, LatLng pos) async {
    const url =
        "https://map-mates-profile-api-production.up.railway.app/locations/visited_zone";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "latitude": pos.latitude,
          "longitude": pos.longitude,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Fehler beim Speichern der Visited Zone: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getVisitedZones(int userId) async {
    String url = "https://map-mates-profile-api-production.up.railway.app/locations/visited_zones/$userId";
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<Map<String, dynamic>> visitedZones = jsonList.cast<Map<String, dynamic>>();

        return visitedZones;

      } else {
        debugPrint("Suche fehlgeschlagen: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Fehler bei Suche: $e");
      return [];
    }
  }
}
