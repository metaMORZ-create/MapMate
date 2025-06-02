import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:map_mates/services/location_tracker.dart';
import 'package:latlong2/latlong.dart';

class LoginRegisterService {
  final http.Client client;

  LoginRegisterService(this.client);

  Future<bool> login(
    String username,
    String password, {
    bool skipTracking = false,
  }) async {
    const url =
        "https://map-mates-profile-api-production.up.railway.app/users/login";

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final username = json["user"];
        final userId = json["user_id"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.setBool('loggedIn', true);
        await prefs.setString('username', username);
        await prefs.setInt('user_id', userId);

        if (!skipTracking) {
          await LocationTracker().startBatchTracking();
          await LocationTracker().updatePolygonOnce(userId);
          LocationTracker().startAutoPolygonUpdate(userId);
        }

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

  Future<bool> register(
    String email,
    String username,
    String password, {
    bool skipTracking = false,
  }) async {
    const url =
        "https://map-mates-profile-api-production.up.railway.app/users/register";

    try {
      final response = await client.post(
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

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.setBool('loggedIn', true);
        await prefs.setString('username', username);
        await prefs.setInt('user_id', userId);

        if (!skipTracking) {
          await LocationTracker().startBatchTracking();
          await LocationTracker().updatePolygonOnce(userId);
          LocationTracker().startAutoPolygonUpdate(userId);
        }

        return true;
      } else {
        debugPrint("Registrierung fehlgeschlagen");
        return false;
      }
    } catch (e) {
      debugPrint("Fehler bei Registrierung: $e");
      return false;
    }
  }

  Future<void> logout({bool skipTracking = false}) async {
    if (!skipTracking) {
      LocationTracker().stop();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
