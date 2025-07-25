import "dart:io";

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
    final LocationSettings locationSettings =
        Platform.isAndroid
            ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
              foregroundNotificationConfig: const ForegroundNotificationConfig(
                notificationTitle: 'MapMates Standort-Tracking',
                notificationText: 'Dein Standort wird im Hintergrund verfolgt',
                enableWakeLock: true,
              ),
            )
            : AppleSettings(
              accuracy: LocationAccuracy.high,
              activityType: ActivityType.fitness,
              pauseLocationUpdatesAutomatically: false,
              showBackgroundLocationIndicator: true,
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
    String url =
        "https://map-mates-profile-api-production.up.railway.app/locations/visited_zones/$userId";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<Map<String, dynamic>> visitedZones =
            jsonList.cast<Map<String, dynamic>>();

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

  // Get Polygon from visited areas
  static Future<List<List<LatLng>>> getVisitedPolygons(
    List<Map<String, dynamic>> zones,
  ) async {
    final url = Uri.parse(
      "https://map-mates-profile-api-production.up.railway.app/locations/visited_polygons",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(zones),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final features = data["features"] as List;
      return features.map<List<LatLng>>((feature) {
        final coords = feature["geometry"]["coordinates"][0];
        return coords
            .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
            .toList();
      }).toList();
    } else {
      throw Exception(
        "Failed to load polygons from zones. Status Code: ${response.statusCode}",
      );
    }
  }

  static Future<void> uploadBatchVisitedZones(
    List<Map<String, dynamic>> zones,
  ) async {
    final url = Uri.parse(
      "https://map-mates-profile-api-production.up.railway.app/locations/batch_visited_zones",
    );
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"locations": zones}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to upload visited zones. Status Code: ${response.statusCode}",
      );
    }
  }

  static Future<void> uploadBatchLocations(
    List<Map<String, dynamic>> zones,
  ) async {
    final url = Uri.parse(
      "https://map-mates-profile-api-production.up.railway.app/locations/batch_add_locations",
    );
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"locations": zones}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to upload visited zones. Status Code: ${response.statusCode}",
      );
    }
  }

  static Future<Map<String, dynamic>?> getLastLocation(int userId) async {
    final url = Uri.parse(
      "https://map-mates-profile-api-production.up.railway.app/locations/last_location/$userId",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "userId": data["user_id"],
          "position": LatLng(data["latitude"], data["longitude"]),
          "altitude": data["altitude"],
          "timestamp": DateTime.parse(data["timestamp"]),
        };
      } else {
        debugPrint(
          "Fehler beim Abrufen des letzten Standorts: ${response.statusCode}",
        );
        return null;
      }
    } catch (e) {
      debugPrint("Exception bei getLastLocation: $e");
      return null;
    }
  }

  static Future<void> extendVisitedPolygon(
    int userId,
    List<Map<String, dynamic>> zones,
  ) async {
    final url = Uri.parse(
      "https://map-mates-profile-api-production.up.railway.app/locations/extend_visited_polygon/$userId",
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(zones),
      );

      if (response.statusCode != 200) {
        debugPrint("Polygon-Extension fehlgeschlagen: ${response.statusCode}");
        throw Exception("Polygon extension failed");
      } else {
        debugPrint("Polygon erfolgreich erweitert");
      }
    } catch (e) {
      debugPrint("Fehler bei extendVisitedPolygon: $e");
      throw Exception("Fehler beim Aufruf von extendVisitedPolygon");
    }
  }

  static Future<List<List<LatLng>>> getStoredVisitedPolygon(int userId) async {
    final url = Uri.parse(
      "https://map-mates-profile-api-production.up.railway.app/locations/stored_polygon/$userId",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data["features"] as List;

        return features.map<List<LatLng>>((feature) {
          final coords = feature["geometry"]["coordinates"][0];
          return coords
              .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
              .toList();
        }).toList();
      } else {
        debugPrint(
          "Fehler beim Abrufen des gespeicherten Polygons: ${response.statusCode}",
        );
        return [];
      }
    } catch (e) {
      debugPrint("Exception bei getStoredVisitedPolygon: $e");
      return [];
    }
  }
}
