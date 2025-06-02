import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:map_mates/services/social_service.dart';

class MockHTTPClient extends Mock implements Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockHTTPClient mockHTTPClient;
  late SocialService socialService;

  setUp(() {
    mockHTTPClient = MockHTTPClient();
    socialService = SocialService(mockHTTPClient);
    SharedPreferences.setMockInitialValues({'user_id': 42});
  });

  group("SocialService", () {
    // Test für Benutzersuche
    test("search returns users", () async {
      const query = "anna";
      final fakeResponse = [
        {"id": 1, "username": "Anna"},
        {"id": 2, "username": "Annabelle"},
      ];

      when(
        () => mockHTTPClient.get(
          Uri.parse(
            "https://map-mates-profile-api-production.up.railway.app/socials/search?query=$query&self_id=42",
          ),
          headers: any(named: "headers"),
        ),
      ).thenAnswer((_) async => Response(jsonEncode(fakeResponse), 200));

      final result = await socialService.search(query);
      expect(result.length, 2);
      expect(result[0]["username"], "Anna");
    });

    // Test für Senden einer Freundschaftsanfrage
    test("sendFriendRequest returns true", () async {
      when(
        () => mockHTTPClient.post(
          Uri.parse(
            "https://map-mates-profile-api-production.up.railway.app/socials/send_request",
          ),
          headers: any(named: "headers"),
          body: any(named: "body"),
        ),
      ).thenAnswer(
        (_) async => Response(jsonEncode({"message": "Erfolgreich"}), 200),
      );

      final result = await socialService.sendFriendRequest(99);
      expect(result, true);
    });

    // Test für Annehmen einer Freundschaftsanfrage
    test("acceptFriendRequest returns true", () async {
      when(
        () => mockHTTPClient.post(
          Uri.parse(
            "https://map-mates-profile-api-production.up.railway.app/socials/accept_request",
          ),
          headers: any(named: "headers"),
          body: any(named: "body"),
        ),
      ).thenAnswer(
        (_) async => Response(jsonEncode({"message": "Akzeptiert"}), 200),
      );

      final result = await socialService.acceptFriendRequest(5);
      expect(result, true);
    });

    // Test für Ablehnen einer Freundschaftsanfrage
    test("denyFriendRequest returns true", () async {
      when(
        () => mockHTTPClient.post(
          Uri.parse(
            "https://map-mates-profile-api-production.up.railway.app/socials/deny_request",
          ),
          headers: any(named: "headers"),
          body: any(named: "body"),
        ),
      ).thenAnswer(
        (_) async => Response(jsonEncode({"message": "Abgelehnt"}), 200),
      );

      final result = await socialService.denyFriendRequest(5);
      expect(result, true);
    });

    // Test für Auslesen ausgehender Anfragen
    test("getOutgoingRequests returns list", () async {
      final fakeResponse = [
        {"id": 10, "username": "Finn"},
      ];

      when(
        () => mockHTTPClient.get(
          Uri.parse(
            "https://map-mates-profile-api-production.up.railway.app/socials/outgoing_requests/42",
          ),
          headers: any(named: "headers"),
        ),
      ).thenAnswer((_) async => Response(jsonEncode(fakeResponse), 200));

      final result = await socialService.getOutgoingRequests();
      expect(result.length, 1);
      expect(result[0]["username"], "Finn");
    });

    // Test für Auslesen eingehender Anfragen
    test("getIncomingRequests returns list", () async {
      final fakeResponse = [
        {"id": 11, "username": "Raven"},
      ];

      when(
        () => mockHTTPClient.get(
          Uri.parse(
            "https://map-mates-profile-api-production.up.railway.app/socials/received_requests/42",
          ),
          headers: any(named: "headers"),
        ),
      ).thenAnswer((_) async => Response(jsonEncode(fakeResponse), 200));

      final result = await socialService.getIncomingRequests();
      expect(result.length, 1);
      expect(result[0]["username"], "Raven");
    });

    // Test für Auslesen der Freundesliste
    test("getFriends returns list", () async {
      final fakeResponse = [
        {"id": 12, "username": "Finno"},
      ];

      when(
        () => mockHTTPClient.get(
          Uri.parse(
            "https://map-mates-profile-api-production.up.railway.app/socials/get_friends/42",
          ),
          headers: any(named: "headers"),
        ),
      ).thenAnswer((_) async => Response(jsonEncode(fakeResponse), 200));

      final result = await socialService.getFriends();
      expect(result.length, 1);
      expect(result[0]["username"], "Finno");
    });
  });
}
