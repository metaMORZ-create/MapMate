import "dart:convert";
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SocialService {
  final http.Client client;

  SocialService(this.client);

  // Suche nach Nutzern
  Future<List<Map<String, dynamic>>> search(String search) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    final url = "https://map-mates-profile-api-production.up.railway.app/socials/search?query=$search&self_id=$userId";

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        debugPrint("Suche fehlgeschlagen: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Fehler bei Suche: $e");
      return [];
    }
  }

  // Freundschaftsanfrage senden
  Future<bool> sendFriendRequest(int receiverId) async {
    const url = "https://map-mates-profile-api-production.up.railway.app/socials/send_request";
    final prefs = await SharedPreferences.getInstance();
    final senderId = prefs.getInt("user_id");

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender_id": senderId,
          "receiver_id": receiverId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Anfrage erfolgreich: ${data['message']}");
        return true;
      } else {
        final error = jsonDecode(response.body);
        debugPrint("Fehler: ${error['detail']}");
        return false;
      }
    } catch (e) {
      debugPrint("Ausnahme beim Senden der Anfrage: $e");
      return false;
    }
  }

  // Freundschaftsanfrage annehmen
  Future<bool> acceptFriendRequest(int senderUserId) async {
    const url = "https://map-mates-profile-api-production.up.railway.app/socials/accept_request";
    final prefs = await SharedPreferences.getInstance();
    final selfUserId = prefs.getInt("user_id");

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "self_user_id": selfUserId,
          "sender_user_id": senderUserId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Anfrage erfolgreich: ${data['message']}");
        return true;
      } else {
        final error = jsonDecode(response.body);
        debugPrint("Fehler: ${error['detail']}");
        return false;
      }
    } catch (e) {
      debugPrint("Ausnahme beim Annehmen: $e");
      return false;
    }
  }

  // Freundschaftsanfrage ablehnen
  Future<bool> denyFriendRequest(int senderUserId) async {
    const url = "https://map-mates-profile-api-production.up.railway.app/socials/deny_request";
    final prefs = await SharedPreferences.getInstance();
    final selfUserId = prefs.getInt("user_id");

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "self_user_id": selfUserId,
          "sender_user_id": senderUserId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Anfrage erfolgreich: ${data['message']}");
        return true;
      } else {
        final error = jsonDecode(response.body);
        debugPrint("Fehler: ${error['detail']}");
        return false;
      }
    } catch (e) {
      debugPrint("Ausnahme beim Ablehnen: $e");
      return false;
    }
  }

  // Ausgehende Anfragen abrufen
  Future<List<Map<String, dynamic>>> getOutgoingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    final url = "https://map-mates-profile-api-production.up.railway.app/socials/outgoing_requests/$userId";

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        debugPrint("Anfragen holen fehlgeschlagen: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Fehler beim Abrufen ausgehender Anfragen: $e");
      return [];
    }
  }

  // Eingehende Anfragen abrufen
  Future<List<Map<String, dynamic>>> getIncomingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    final url = "https://map-mates-profile-api-production.up.railway.app/socials/received_requests/$userId";

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        debugPrint("Empfangene Anfragen fehlgeschlagen: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Fehler beim Abrufen eingehender Anfragen: $e");
      return [];
    }
  }

  // Freundesliste abrufen
  Future<List<Map<String, dynamic>>> getFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    final url = "https://map-mates-profile-api-production.up.railway.app/socials/get_friends/$userId";

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        debugPrint("Freundesliste fehlgeschlagen: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Fehler beim Abrufen der Freunde: $e");
      return [];
    }
  }
}
