import "dart:convert";
import "package:map_mates/services/location_tracker.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/cupertino.dart";
import "package:http/http.dart" as http;

class LoginRegisterService {
  // Login Verifizierung
  static Future<bool> login(String username, String password) async {
    const url =
        "https://map-mates-profile-api-production.up.railway.app/users/login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final username = json["user"];
        final userId = json["user_id"];

        // Eingeloggt sein merken
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.setBool('loggedIn', true);
        await prefs.setString('username', username);
        await prefs.setInt('user_id', userId);

        // Tracking Starten nach Login
        await LocationTracker().startBatchTracking();
        await LocationTracker().updatePolygonOnce(userId);
        LocationTracker().startAutoPolygonUpdate(userId);


        return true;
      } else {
        debugPrint("Login Fehlgeschlagen");
        return false;
      }
    } catch (e) {
      debugPrint("Fehler beim Login: $e");
      return false;
    }
  }

  // Login Verifizierung
  static Future<bool> register(
    String email,
    String username,
    String password,
  ) async {
    const url =
        "https://map-mates-profile-api-production.up.railway.app/users/register";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "disabled": false,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final username = json["user"];
        final userId = json["user_id"];

        // Eingeloggt sein merken
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.setBool('loggedIn', true);
        await prefs.setString('username', username);
        await prefs.setInt('user_id', userId);

        // Tracking Starten nach Login
        await LocationTracker().startBatchTracking();
        await LocationTracker().updatePolygonOnce(userId);
        LocationTracker().startAutoPolygonUpdate(userId);

        return true;
      } else {
        debugPrint("Login Fehlgeschlagen");
        return false;
      }
    } catch (e) {
      debugPrint("Fehler beim Login: $e");
      return false;
    }
  }

  Future<void> logout() async {
    // Standort-Tracking & Polygon-Update stoppen
    LocationTracker().stop();

    // SharedPreferences leeren
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
