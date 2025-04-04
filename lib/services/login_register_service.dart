import "dart:convert";
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/cupertino.dart";
import "package:http/http.dart" as http;

class LoginRegisterService {
  // Login Verifizierung
  static Future<bool> login(String username, String password) async {
    const url = "https://map-mates-profile-api-production.up.railway.app/login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final username = json["user"];
        final message = json["message"];

        // Eingeloggt sein merken
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('loggedIn', true);
        await prefs.setString('username', username);

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
        "https://map-mates-profile-api-production.up.railway.app/register";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final username = json["user"];
        final message = json["message"];

        // Eingeloggt sein merken
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('loggedIn', true);
        await prefs.setString('username', username);

        debugPrint("Login erfolgreich $message ($username)");
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

  // Logout Funktion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
