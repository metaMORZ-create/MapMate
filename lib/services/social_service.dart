import "dart:convert";
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/cupertino.dart";
import "package:http/http.dart" as http;

class SocialService {
  // Login Verifizierung
  static Future<List<Map<String, dynamic>>> search(String search) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    String url = "https://map-mates-profile-api-production.up.railway.app/socials/search?query=$search&self_id=$userId";
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<Map<String, dynamic>> users = jsonList.cast<Map<String, dynamic>>();

        return users;

      } else {
        debugPrint("Suche fehlgeschlagen: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Fehler bei Suche: $e");
      return [];
    }
  }

  static Future<bool> sendFriendRequest(int receiverId) async {
    const url = "https://map-mates-profile-api-production.up.railway.app/socials/send_request";
    final prefs = await SharedPreferences.getInstance();
    final senderId = prefs.getInt("user_id");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender_id": senderId,
          "receiver_id": receiverId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("✅ Anfrage erfolgreich: ${data['message']}");
        return true;
      } else {
        final error = jsonDecode(response.body);
        debugPrint("⚠️ Fehler: ${error['detail']}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Ausnahme beim Senden der Anfrage: $e");
      return false;
    }
  }
}
